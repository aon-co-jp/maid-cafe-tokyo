param(
    [string]$RepoRoot = $null
)

# Creates a desktop shortcut (.lnk) that launches open-english.
#
# NOTE (fixed 2026-08-21): This used to point the shortcut directly at
# index.html (file://), which was accurate back when open-english was a
# server-free static app. Since 2026-08-10 the recommended way to run it
# is via the Rust `server/` crate (see README.md "実行方法"), because
# some browsers block fetch() on file:// pages -- which silently breaks
# auto-update.js's polling and other fetch-based features. Opening
# index.html directly still "works" for basic viewing, but is degraded.
# This script now prefers generating a small launcher batch file that
# starts the built server binary and opens the served URL; it only falls
# back to the old file:// behavior if no server binary can be found, and
# it says so honestly instead of staying silent about the difference.

if (-not $RepoRoot) {
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } elseif ($MyInvocation.MyCommand.Path) { Split-Path -Path $MyInvocation.MyCommand.Path -Parent } else { $null }
    if ($scriptDir) {
        $RepoRoot = Split-Path -Path (Split-Path -Path $scriptDir -Parent) -Parent
    } else {
        Write-Error "Could not detect the script location. Pass -RepoRoot explicitly, e.g. .\create-shortcut.ps1 -RepoRoot 'F:\runo\open-english'"
        exit 1
    }
}
$repoRoot = $RepoRoot
$indexHtml = Join-Path $repoRoot "index.html"
$iconPath = Join-Path $repoRoot "icons\open-english.ico"

if (-not (Test-Path $indexHtml)) {
    Write-Error "index.html not found at: $indexHtml"
    exit 1
}

# Look for a built server binary in the usual places: a local dev build
# (server\target\release\open-english-server.exe) or an installed copy
# next to this repo checkout (open-english-server.exe alongside index.html,
# which is how the Inno Setup installer lays it out).
$candidateServerPaths = @(
    (Join-Path $repoRoot "server\target\release\open-english-server.exe"),
    (Join-Path $repoRoot "open-english-server.exe")
)
$serverExe = $candidateServerPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "open-english.lnk"
$shell = New-Object -ComObject WScript.Shell

if ($serverExe) {
    # Generate a tiny launcher batch file next to the server binary that
    # starts the server (bound to 127.0.0.1:4601 by default, see
    # server/src/main.rs / OPEN_ENGLISH_SERVER_BIND) and then opens the
    # served URL in the default browser, instead of opening the raw file.
    $launcherBat = Join-Path (Split-Path -Path $serverExe -Parent) "open-english-launch.bat"
    $bindHost = "127.0.0.1"
    $bindPort = "4601"
    $serverUrl = "http://${bindHost}:${bindPort}/"
    @"
@echo off
start "" "$serverExe"
timeout /t 1 /nobreak >nul
start "" "$serverUrl"
"@ | Set-Content -Path $launcherBat -Encoding ASCII

    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $launcherBat
    $shortcut.WorkingDirectory = (Split-Path -Path $serverExe -Parent)
    $shortcut.IconLocation = "$iconPath,0"
    $shortcut.Description = "open-english: Maid Cafe English Trainer (via local server)"
    $shortcut.Save()
    Write-Host "Created: $shortcutPath (launches $serverExe and opens $serverUrl)"
} else {
    Write-Warning "No built server binary found (looked in server\target\release\ and next to this script). Falling back to opening index.html directly via file:// -- note this disables auto-update.js polling and some fetch-based features in browsers that block fetch() on file:// pages. Build the server first (cd server && cargo build --release) for the full experience."
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $indexHtml
    $shortcut.WorkingDirectory = $repoRoot
    $shortcut.IconLocation = "$iconPath,0"
    $shortcut.Description = "open-english: Maid Cafe English Trainer (file:// fallback, degraded)"
    $shortcut.Save()
    Write-Host "Created: $shortcutPath (file:// fallback)"
}
