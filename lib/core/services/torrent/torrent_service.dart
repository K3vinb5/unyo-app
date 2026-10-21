import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:unyo/config/config.dart' as config;
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:system_info3/system_info3.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/empty_api_response.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/domain/entities/torrent/torrent_status.dart';

class TorrentService {
  static const String _servicesDir = "services";
  static const String _torrentServerName = "torrserver";
  static const String _packageAssetsDir = "assets";
  final HttpService _httpService = sl<HttpService>();
  final Logger _logger = sl<Logger>();
  Process? torrentProcess;

  TorrentService() {
    _initTorrentServer();
  }

  Future<void> _initTorrentServer() async {
    await stopServer();
    Directory supportDirectory = sl<Directory>(instanceName: config.applicationSupportDirectory);
    String torrServerPath = await _loadTorrServerIfNeeded(supportDirectory);
    _startServer(torrServerPath);
    await _wipeAllTorrents();
  }

  Future<String> _loadTorrServerIfNeeded(Directory supportDirectory) async {
    String torrentServerPath = path.join(
      supportDirectory.path,
      _torrentServerName,
      _torrentServerName + (Platform.isWindows ? ".exe" : ""),
    );
    File torrServer = File(torrentServerPath);
    bool needsCopy = false;
    if (!(await torrServer.exists())) {
      needsCopy = true;
    } else {
      String assetPath = "$_packageAssetsDir/$_servicesDir/$_torrentServerName/${SysInfo.kernelArchitecture == ProcessorArchitecture.x86_64 ? "amd64" : "arm64"}/${Platform.operatingSystem}/${_torrentServerName + (Platform.isWindows ? ".exe" : "")}";
      String existingFileHash = await _computeFileHash(torrServer);
      String assetHash = await _computeAssetHash(assetPath);
      if (existingFileHash != assetHash) {
        needsCopy = true;
      }
    }

    if (needsCopy) {
      _logger.i("Copying new torrent server binary to $torrentServerPath");
      await _copyAssetToFile(
        "$_packageAssetsDir/$_servicesDir/$_torrentServerName/${SysInfo.kernelArchitecture == ProcessorArchitecture.x86_64 ? "amd64" : "arm64"}/${Platform.operatingSystem}/${_torrentServerName + (Platform.isWindows ? ".exe" : "")}",
        torrentServerPath,
      );
    }

    if (!Platform.isWindows) {
      await Process.run('chmod', ['+x', torrentServerPath]);
    }
    return torrentServerPath;
  }

  Future<String> _computeFileHash(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> _computeAssetHash(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<File> _copyAssetToFile(String assetPath, String outPath) async {
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer.asUint8List();
    final file = File(outPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(buffer, flush: true);
    return file;
  }

  Future<void> _startServer(String torrServerPath) async {
    // Set working directory to the binary's location so generated files are created there
    final workingDir = path.dirname(torrServerPath);
    torrentProcess = await Process.start(
      torrServerPath,
      [],
      mode: ProcessStartMode.normal,
      workingDirectory: workingDir,
    );
  }

  Future<void> stopServer() async {
    try {
      ApiResponse<EmptyApiResponse> response = await _httpService.get("${config.torrentServiceEndpoint}/shutdown", fromJson: EmptyApiResponse.fromJson);
      if (response.statusCode == 200) {
        torrentProcess = null;
        return;
      }
    } catch (_) {
    }
    torrentProcess?.kill();
  }

  Future<void> _wipeAllTorrents() async {
    await Future.delayed(const Duration(milliseconds: 250));
    try {
      await _httpService.post<EmptyApiResponse>(
        "${config.torrentServiceEndpoint}/torrents",
        body: {"action": "wipe"},
        fromJson: EmptyApiResponse.fromJson,
        ignoreCache: true,
      );
      _logger.i("All torrents wiped from torrserver");
    } catch (e) {
      _logger.w("Failed to wipe torrents: $e");
    }
  }

  Future<TorrentStatus> addTorrent(
    String link, {
    String? title,
    String? poster,
    String? category,
    bool saveToDb = true,
  }) async {
    _logger.i("Adding torrent to torrserver: $link");
    final body = {
      "action": "add",
      "link": link,
      "title": ?title,
      "poster": ?poster,
      "category": ?category,
      "save_to_db": saveToDb,
    };
    final response = await _httpService.post<TorrentStatus>(
      "${config.torrentServiceEndpoint}/torrents",
      body: body,
      fromJson: TorrentStatusModel.fromJson,
      ignoreCache: true,
    );
    if (response.statusCode >= 300) {
      throw Exception("Failed to add torrent: ${response.statusCode}");
    }
    return response.data;
  }

  Future<TorrentStatus?> getTorrent(String hash) async {
    final body = {
      "action": "get",
      "hash": hash,
    };
    try {
      final response = await _httpService.post<TorrentStatus>(
        "${config.torrentServiceEndpoint}/torrents",
        body: body,
        fromJson: TorrentStatusModel.fromJson,
        ignoreCache: true,
      );
      if (response.statusCode >= 300) {
        return null;
      }
      return response.data;
    } catch (_) {
      return null;
    }
  }

  Future<void> removeTorrent(String hash) async {
    _logger.i("Removing torrent from torrserver: $hash");
    final body = {
      "action": "rem",
      "hash": hash,
    };
    try {
      await _httpService.post<EmptyApiResponse>(
        "${config.torrentServiceEndpoint}/torrents",
        body: body,
        fromJson: EmptyApiResponse.fromJson,
        ignoreCache: true,
      );
    } catch (e) {
      _logger.w("Failed to remove torrent $hash: $e");
    }
  }

  String getStreamUrl(String hash, int fileIndex) {
    return "${config.torrentServiceEndpoint}/play/$hash/$fileIndex";
  }
}
