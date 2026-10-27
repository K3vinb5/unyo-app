// ignore_for_file: avoid_print

// Boots a real JVM through the same call, on the same kind of thread, as the
// shipped app.
//
// windows_jvm_smoke.ps1 already boots the VM from a pwsh delegate on a
// 64MB-stack thread — that proves the loader from any native host. This
// script is the app-faithful boot: unyo-lib's "Aniyomi-JNI-Isolate" worker
// calls Jni.spawnIfNotExists -> SpawnJvm on a *spawned Dart isolate* thread,
// so the boot here runs inside Isolate.spawn too. Booting on dart.exe's main
// thread would not reproduce the app's thread context.
//
// SpawnJvm(NULL) is valid: dartjni.c builds default JNI_VERSION_1_6 args with
// classpath "." when initArgs is NULL. Exit 0 + "SMOKE OK" means the VM booted.

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

typedef _SpawnJvmNative = Int32 Function(Pointer<Void> initArgs);
typedef _SpawnJvmDart = int Function(Pointer<Void> initArgs);

Future<void> main(List<String> args) async {
  if (args.length != 2) {
    stderr.writeln(
      'usage: windows_jvm_smoke_boot.dart <jvm.dll path> <dartjni.dll path>',
    );
    exit(2);
  }
  final String jvmDll = args[0];
  final String dartjniDll = args[1];

  // 1. Preload the bundled JVM by absolute path, like unyo-lib's loadJvmDll
  //    (the app does this from the main isolate as well).
  try {
    DynamicLibrary.open(jvmDll);
  } catch (e) {
    stderr.writeln('failed to preload $jvmDll: $e');
    exit(1);
  }

  // 2. Load dartjni and spawn the VM on a spawned isolate — the app's path.
  final ReceivePort reply = ReceivePort();
  await Isolate.spawn(
    _bootOnIsolate,
    <Object>[reply.sendPort, dartjniDll],
    onError: reply.sendPort,
    errorsAreFatal: true,
  );
  final Object? result = await reply.first
      .timeout(const Duration(seconds: 120), onTimeout: () => 'timeout');

  if (result == 'ok') {
    print('SMOKE OK: Dart-host SpawnJvm returned JNI_OK');
    exit(0);
  }
  stderr.writeln('Dart-host VM boot failed: $result');
  exit(1);
}

void _bootOnIsolate(List<Object> message) {
  final SendPort reply = message[0] as SendPort;
  final String dartjniDll = message[1] as String;
  try {
    final DynamicLibrary dartjni = DynamicLibrary.open(dartjniDll);
    final _SpawnJvmDart spawn =
        dartjni.lookupFunction<_SpawnJvmNative, _SpawnJvmDart>('SpawnJvm');
    final int rc = spawn(Pointer<Void>.fromAddress(0));
    reply.send(rc == 0 ? 'ok' : 'rc: $rc (expected 0 = JNI_OK)');
  } catch (e) {
    reply.send('error: $e');
  }
}
