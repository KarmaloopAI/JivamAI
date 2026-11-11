# Jivam installer for Windows
# Usage (run in PowerShell as a normal user - admin rights are not required):
#   irm https://jivamai.com/install.ps1 | iex
#
# Requires PowerShell 5.1+ (built into Windows 10/11). If Node.js needs to be
# installed and winget is available, it may show a one-time UAC prompt (its
# Node.js package installs machine-wide); if you can't approve that (no admin
# rights) or winget isn't available, this falls back to a portable, per-user
# Node.js install that needs no elevation at all.
#
# Mirrored from KarmaloopAI/Jivam's scripts/install.ps1. Do not edit here: change it in that
# repo and run scripts/sync-website-installers.js there.

$ErrorActionPreference = 'Stop'

# Plain Write-Host colours and ASCII markers: Windows PowerShell 5.1 (the one
# every Windows 10/11 PC has) does not understand the `u{...} escape, and its
# console does not always interpret raw ANSI codes.
function Log    { param($msg) Write-Host "> " -ForegroundColor Magenta -NoNewline; Write-Host $msg }
function Ok     { param($msg) Write-Host "OK " -ForegroundColor Green -NoNewline; Write-Host $msg }
function Warn   { param($msg) Write-Host "!  " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Header { param($msg) Write-Host ""; Write-Host $msg -ForegroundColor Magenta; Write-Host "" }

# -----------------------------------------------------------------------------
Header "Jivam Installer"
Write-Host "  This will install Jivam and add it to your Windows PC as an app."
Write-Host ""

# -- 1. Node.js ---------------------------------------------------------------
Header "Step 1 of 3 - Node.js"

function Get-NodeMajor {
    try {
        $v = (node --version 2>$null).TrimStart('v')
        return [int]($v.Split('.')[0])
    } catch { return 0 }
}

# jiva-core requires Node >=20 (see its package.json "engines" field) - this
# used to check >=18, which let an already-too-old Node quietly pass.
$nodeMajor = Get-NodeMajor

if ($nodeMajor -ge 20) {
    Ok "Node.js v$nodeMajor already installed"
} else {
    if ($nodeMajor -gt 0) {
        Warn "Node.js v$nodeMajor is too old (need >=20). Upgrading..."
    } else {
        Warn "Node.js not found. Installing..."
    }

    # Try winget first - fast and keeps Node on the system PATH the normal
    # way. NOTE: this can still trigger a UAC elevation prompt, since Node's
    # official winget package installs machine-wide (Program Files) rather
    # than declaring per-user scope. If winget isn't present, or its install
    # didn't actually succeed (e.g. the user can't elevate - no admin
    # rights, UAC prompt dismissed), fall through to a portable install that
    # needs no elevation at all: download the plain Node.js zip and unpack
    # it into the user's own AppData, then prepend it to the *User* PATH
    # (not Machine) - a pure per-user operation, no installer/UAC involved.
    $wingetOk = $false
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Log "Installing Node.js LTS via winget..."
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements --silent --scope user 2>$null
        if ($LASTEXITCODE -eq 0) {
            $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
                        [System.Environment]::GetEnvironmentVariable('Path','User')
            if ((Get-NodeMajor) -ge 20) { $wingetOk = $true }
        }
        if (-not $wingetOk) {
            Warn "winget install didn't take (often needs admin approval) - falling back to a portable install that needs no elevation."
        }
    }

    if (-not $wingetOk) {
        Log "Downloading a portable Node.js LTS build (no admin rights needed)..."
        $nodeDir = "$env:LOCALAPPDATA\Jivam\node"
        $zipPath = "$env:TEMP\node-lts.zip"
        # nodejs.org publishes a version-pinned "latest LTS" index; resolve it
        # so the zip filename (which embeds the version) is known up front.
        $ltsVersion = (Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json" |
            Where-Object { $_.lts } | Select-Object -First 1).version
        $zipUrl = "https://nodejs.org/dist/$ltsVersion/node-$ltsVersion-win-x64.zip"
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

        if (Test-Path $nodeDir) { Remove-Item $nodeDir -Recurse -Force }
        New-Item -ItemType Directory -Path $nodeDir -Force | Out-Null
        Expand-Archive -Path $zipPath -DestinationPath $nodeDir -Force
        Remove-Item $zipPath -Force

        # A zip downloaded via Invoke-WebRequest carries a Mark-of-the-Web
        # zone identifier; Windows can propagate it onto every extracted
        # file, causing AV/Smart App Control to silently block node.exe from
        # running the first time it's invoked. Unblock-File is the standard,
        # safe remediation - this is a file we just downloaded ourselves and
        # extracted, not third-party content the user asked us to run.
        Get-ChildItem -Path $nodeDir -Recurse | Unblock-File -ErrorAction SilentlyContinue

        # The zip extracts into a version-named subfolder - flatten it up one level.
        $extracted = Get-ChildItem $nodeDir -Directory | Select-Object -First 1
        Get-ChildItem $extracted.FullName | Move-Item -Destination $nodeDir -Force
        Remove-Item $extracted.FullName -Force

        # Prepend to the *User* PATH (not Machine - that would need admin).
        $userPath = [System.Environment]::GetEnvironmentVariable('Path','User')
        if ($userPath -notlike "*$nodeDir*") {
            [System.Environment]::SetEnvironmentVariable('Path', "$nodeDir;$userPath", 'User')
        }
        $env:Path = "$nodeDir;$env:Path"
    }

    $nodeMajor = Get-NodeMajor
    if ($nodeMajor -lt 20) {
        Write-Host ""
        Write-Host "  Node.js installation failed or PATH not updated yet." -ForegroundColor Red
        Write-Host "  Please install Node.js 20+ from https://nodejs.org, then re-run this script." -ForegroundColor Red
        exit 1
    }
}

Ok "Node.js $(node --version) ready"

# A `prefix`/`globalconfig` override in ~/.npmrc (left over from a manual
# `npm config set prefix ...`, or another Node version manager) can silently
# redirect `npm install -g` to a directory that's not on PATH - the global
# install reports success but `jivam` is never found afterward. Same class
# of bug already fixed for nvm on macOS/Linux (sanitize_npmrc_for_nvm in
# install.sh); Windows never had an equivalent check.
function Repair-NpmrcForGlobalInstall {
    $npmrcPath = "$HOME\.npmrc"
    if (-not (Test-Path $npmrcPath)) { return }
    $lines = Get-Content $npmrcPath
    if ($lines | Where-Object { $_ -match '^\s*(prefix|globalconfig)\s*=' }) {
        Warn "Removing prefix/globalconfig from ~/.npmrc (can redirect global installs off PATH) - backed up to ~/.npmrc.bak"
        Copy-Item $npmrcPath "$npmrcPath.bak" -Force
        $lines | Where-Object { $_ -notmatch '^\s*(prefix|globalconfig)\s*=' } | Set-Content $npmrcPath
    }
}
Repair-NpmrcForGlobalInstall

# -- 2. Install jivam + jiva-core ---------------------------------------------
Header "Step 2 of 3 - Installing Jivam"
Log "Installing jivam and jiva-core globally..."
npm install -g jivamai jiva-core
Ok "jivam installed"
Ok "jiva-core installed"

# -- 3. The Jivam app ---------------------------------------------------------
# `jivam install` adds Jivam to the Start menu (and Desktop), using the
# Microsoft WebView2 runtime that ships with Windows 11 and current Edge for
# its window. If WebView2 is missing it offers to install Microsoft's signed
# runtime (no admin rights needed). It also removes the old background
# service and Edge web app shortcut if an earlier version left them, then
# opens Jivam. Same as running it by hand after `npm i -g jivamai jiva-core`.
Header "Step 3 of 3 - Setting up the Jivam app"
jivam install

# -- Done ---------------------------------------------------------------------
Write-Host ""
Write-Host "All done! Jivam is installed." -ForegroundColor Green
Write-Host ""
Write-Host "  Jivam is open. Next time, launch it from the Start menu or the Jivam icon on your Desktop."
Write-Host "  Jivam tells you when an update is available."
Write-Host ""
