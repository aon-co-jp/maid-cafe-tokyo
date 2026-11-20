param(
    [string]$RepoRoot = $null,
    [string]$TargetUrl = $null,
    [string]$ServerHost = "127.0.0.1",
    [int]$ServerPort = 4601
)

# Creates a desktop shortcut (.lnk) that launches Google Chrome in
# Incognito mode, pointed at the open-english app itself (2026-08-27
# new, per user request "double-clicking an icon should force Chrome
# to open in incognito mode"; updated same day after a follow-up
# question clarified that opening vault.html standalone -- not
# embedded as an iframe in index.html -- breaks the GitHub push /
# Google Search postMessage features, since there is no parent window
# for vault.html to talk to. The shortcut now opens the main app so
# the vault iframe is properly embedded and functional).
#
# HONEST SCOPE: a web page cannot force the browser or its mode from
# JavaScript (browsers deliberately block this for privacy reasons --
# see vault.html's own on-page disclosure). What *is* possible, and is
# exactly what this script does, is create an OS-level shortcut whose
# target is chrome.exe with the --incognito flag and a URL as an
# argument -- this is a normal, documented Chrome command-line
# feature, not a workaround or exploit. Double-clicking the resulting
# icon always opens a fresh Incognito window at that URL. If Chrome is
# not installed, this script says so honestly and does not silently
# fall back to a different browser's private mode (behavior differs
# enough between browsers that a silent substitution would be
# misleading).
#
# SPECIFYING YOUR OWN LOCAL ADDRESS: the default assumes the server
# is running on this same machine at 127.0.0.1:4601 (open-english's
# default bind address, see server/src/main.rs). If you run the
# server on a different host/port -- e.g. a LAN IP so other devices on
# your network can reach it, or a non-default port -- override it:
#   .\create-vault-incognito-shortcut.ps1 -ServerHost 192.168.1.20 -ServerPort 4601
# Or pass a full URL directly if you want something other than the
# app's top-level page (e.g. to jump straight into a specific screen):
#   .\create-vault-incognito-shortcut.ps1 -TargetUrl "http://192.168.1.20:4601/"
# ローカルアドレスの指定方法: 既定はこの端末自身の127.0.0.1:4601
# (open-englishの既定バインドアドレス)を想定しています。別ホスト/
# ポートでサーバーを動かしている場合(例: 同一LAN内の他端末からも
# アクセスできるようLAN側IPで動かしている場合、既定と異なるポートを
# 使っている場合)は、上記のように-ServerHost/-ServerPortか、
# -TargetUrlで直接URLを指定して上書きしてください。

if (-not $RepoRoot) {
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } elseif ($MyInvocation.MyCommand.Path) { Split-Path -Path $MyInvocation.MyCommand.Path -Parent } else { $null }
    if ($scriptDir) {
        $RepoRoot = Split-Path -Path (Split-Path -Path $scriptDir -Parent) -Parent
    } else {
        Write-Error "Could not detect the script location. Pass -RepoRoot explicitly."
        exit 1
    }
}
$repoRoot = $RepoRoot

if (-not $TargetUrl) {
    # Opens the app's top-level page, NOT vault.html directly -- vault.html
    # only works correctly when embedded as an iframe inside this page
    # (the Freelance Dev Corner's GitHub section, or the Google Search
    # settings modal), since it talks to its parent window via
    # postMessage. Opening vault.html standalone would leave it with no
    # parent to talk to, breaking the GitHub push / Google Search
    # delegation features (key management alone would still work).
    $TargetUrl = "http://${ServerHost}:${ServerPort}/"
}

# Chrome's install location varies (per-machine vs per-user install).
# Check the usual places rather than assuming one.
$candidateChromePaths = @(
    (Join-Path ${env:ProgramFiles} "Google\Chrome\Application\chrome.exe"),
    (Join-Path ${env:ProgramFiles(x86)} "Google\Chrome\Application\chrome.exe"),
    (Join-Path ${env:LocalAppData} "Google\Chrome\Application\chrome.exe")
)
$chromeExe = $candidateChromePaths | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

$desktop = [Environment]::GetFolderPath("Desktop")
$shell = New-Object -ComObject WScript.Shell

if ($chromeExe) {
    $shortcutPath = Join-Path $desktop "open-english-incognito.lnk"
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $chromeExe
    # --incognito must be a separate argument, not appended inside the
    # quoted exe path -- see the Chrome shortcut guides this script's
    # approach was verified against (2026-08-27 web research).
    $shortcut.Arguments = "--incognito `"$TargetUrl`""
    $shortcut.WorkingDirectory = (Split-Path -Path $chromeExe -Parent)
    $shortcut.Description = "open-english (Chrome Incognito, forced via shortcut) / open-english(Chromeシークレットモード、ショートカット経由で強制)"
    $shortcut.Save()
    Write-Host "Created: $shortcutPath"
    Write-Host "  -> Double-clicking it always opens a fresh Chrome Incognito window at:"
    Write-Host "     $TargetUrl"
    Write-Host "  -> From there, open the Freelance Dev Corner or Google Search settings"
    Write-Host "     and load vault.html's URL there -- it needs to run as an embedded"
    Write-Host "     iframe of this page to work, not opened standalone."
} else {
    Write-Warning "Google Chrome was not found in the usual install locations."
    Write-Warning "Download it first, then re-run this script: https://www.google.com/chrome/ / Chromeが見つかりませんでした。先にダウンロードしてください: https://www.google.com/chrome/"
    Write-Warning "No shortcut was created (this script does not silently substitute another browser's private mode)."
}
