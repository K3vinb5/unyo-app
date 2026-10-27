// Boots a real JVM through the same call the shipped app makes.
//
// windows_jvm_smoke.ps1 proves the Windows loader side: jvm.dll preloaded by
// absolute path (like unyo-lib's loadJvmDll), dartjni.dll mapped through its
// /DELAYLOAD:jvm.dll stub, SpawnJvm exported. The VM boot itself runs here, in
// a Dart host, for two reasons:
//   1. faithfulness — unyo-lib boots the JVM from a Dart isolate via
//      Jni.spawnIfNotExists -> SpawnJvm, so a Dart host replays the app's
//      actual call path;
//   2. pwsh.exe is a CoreCLR process — booting HotSpot across a managed to
//      native transition fail-fasts it (exit 0xC0000409) and no JNI status
//      ever comes back.
//
// SpawnJvm(NULL) is valid: dartjni.c builds default JNI_VERSION_1_6 args with
// classpath "." when initArgs is NULL. Exit 0 + "SMOKE OK" means the VM booted.

// ignore_for_file: avoid_print

import 'dart:ffi';
import 'dart:io';

typedef _SpawnJvmNative = Int32 Function(Pointer<Void> initArgs);
typedef _SpawnJvmDart = int Function(Pointer<Void> initArgs);

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln(
      'usage: windows_jvm_smoke_boot.dart <jvm.dll path> <dartjni.dll path>',
    );
    exit(2);
  }
  final String jvmDll = args[0];
  final String dartjniDll = args[1];

  // 1. Preload the bundled JVM by absolute path, like unyo-lib's loadJvmDll.
  DynamicLibrary.open(jvmDll);

  // 2. Load the JNI wrapper; its delay-load stub resolves jvm.dll by name
  //    against the module loaded above.
  final DynamicLibrary dartjni = DynamicLibrary.open(dartjniDll);

  // 3. SpawnJvm with NULL init args; 0 is JNI_OK (jni_constants.h).
  final _SpawnJvmDart spawn =
      dartjni.lookupFunction<_SpawnJvmNative, _SpawnJvmDart>('SpawnJvm');
  final int rc = spawn(Pointer<Void>.fromAddress(0));
  if (rc != 0) {
    stderr.writeln('SpawnJvm returned $rc (expected 0 = JNI_OK)');
    exit(1);
  }
  print('SMOKE OK: SpawnJvm returned JNI_OK');
}
