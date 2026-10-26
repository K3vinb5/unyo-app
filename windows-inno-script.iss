; Unyo - Windows installer (Inno Setup 6)
;
; Layout follows spotube's packaging script (single file glob, optional tasks,
; runtime dependency handling) instead of the stock Inno IDE wizard output.
;
; Version is injected by CI and must stay the full release tag so the produced
; asset name matches the release assets:
;   iscc /dMyAppVersion=<tag> windows-inno-script.iss
;
; Silent install, for future Chocolatey / winget packaging:
;   Unyo-<tag>-windows-setup.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-

#define MyAppName "Unyo"
#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif
#define MyAppPublisher "Kevin Borges"
#define MyAppURL "https://github.com/K3vinb5/unyo-app"
#define MyAppExeName "unyo.exe"

; InnoDependencyInstaller (https://github.com/DomGries/InnoDependencyInstaller),
; cloned into build\inno-depend by the release workflow. The path is relative to
; this script, so it resolves to <repo>\build\inno-depend\CodeDependencies.iss.
; Only the VC++ 2015-2022 redistributable is used, so the .NET helpers (and the
; netcorecheck.exe they want) are deliberately not pulled in.
#include "build\inno-depend\CodeDependencies.iss"

[Setup]
; AppId identifies the application across upgrades - existing installs depend on
; this exact value, do not regenerate it.
AppId={{F90925D3-ED12-4E10-93DC-536BCA639295}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
AppCopyright=Copyright (C) 2024-2026 {#MyAppPublisher}
DefaultDirName={autopf}\Unyo
DisableProgramGroupPage=yes
; Administrative install mode is required: the VC++ redistributable installer
; (see [Code]) needs elevation. Do not lower this to "lowest".
; PrivilegesRequired=lowest
LicenseFile=windows-installer\LICENSE.txt
OutputDir=build\windows\x64\runner
OutputBaseFilename={#MyAppName}-{#MyAppVersion}-windows-setup
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; "x64compatible": native 64-bit Windows plus Windows 11 on Arm (x64 emulation).
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "launchAtStartup"; Description: "{cm:AutoStartProgram,{#MyAppName}}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; A single recursive glob of the Flutter release bundle - listing the exe
; separately on top of this would install it twice.
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userstartup}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; Tasks: launchAtStartup

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup: Boolean;
begin
  { Flutter's Windows build links against the MSVC runtime, which is not
    guaranteed to be present on a clean Windows install. }
  Dependency_AddVC2015To2022;
  Result := True;
end;
