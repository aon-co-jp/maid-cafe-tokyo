# Rebuild the Android native binaries bundled in the APK (jniLibs/arm64-v8a):
#   libopenenglishserver.so (open-english-server), libaruarullm.so (aruaru-llm), libopen_cpu.so (open-cpu)
# Run from PowerShell 5.1 on Windows. Needs: rustup target aarch64-linux-android, cargo-ndk, NDK 27.1.12297006.
# Sibling clones expected next to this repo: ..\aruaru-llm (main, with the open-cpu [patch]), ..\open-cpu, ..\RPoem, ..\RS-JSON, ...
$ErrorActionPreference = "Stop"
$env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"
$env:ANDROID_NDK_HOME = "$env:LOCALAPPDATA\Android\Sdk\ndk\27.1.12297006"
$strip = "$env:ANDROID_NDK_HOME\toolchains\llvm\prebuilt\windows-x86_64\bin\llvm-strip.exe"
$repo = Split-Path -Parent $PSScriptRoot
$jni = Join-Path $repo "mobile\android\app\src\main\jniLibs\arm64-v8a"
function Build($dir, $target, $bin, $out) {
  $env:CARGO_TARGET_DIR = $target
  Push-Location $dir; cargo ndk -t arm64-v8a build --release; Pop-Location
  Copy-Item "$target\aarch64-linux-android\release\$bin" (Join-Path $jni $out) -Force
  & $strip (Join-Path $jni $out)
}
Build (Join-Path $repo "server")        "$repo\..\_oe-and-target"  "open-english-server" "libopenenglishserver.so"
Build (Join-Path $repo "..\aruaru-llm") "$repo\..\_llm-and-target" "aruaru-llm"          "libaruarullm.so"
Build (Join-Path $repo "..\open-cpu")   "$repo\..\_cpu-and-target" "libopen_cpu.so"      "libopen_cpu.so"
Get-ChildItem $jni | Select-Object Name, Length
