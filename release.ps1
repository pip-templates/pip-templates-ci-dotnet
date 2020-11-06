#!/usr/bin/env pwsh

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

# Get component data
$component = Get-Content -Path "component.json" | ConvertFrom-Json

# Check for nuget.conf existence
if (-not (Test-Path -Path "nuget.config")) {
    if (-not (Test-Path -Path "~/nuget.config")) {
        # Create nuget.conf
        $conf = @"
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <packageSources>
        <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
        <add key="github" value="https://$($env:GH_NUGET_REPO_URL)/index.json" />
    </packageSources>
    <packageSourceCredentials>
        <github>
            <add key="Username" value="$($env:GH_USER)" />
            <add key="ClearTextPassword" value="$($env:GH_TOKEN)" />
        </github>
    </packageSourceCredentials>
</configuration>
"@
        Set-Content -Path "~/nuget.config" -Value $conf
    }
    Copy-Item -Path "~/nuget.config" -Destination "./nuget.config"
}

# Verify versions of component.json and published nuget packages
if ($env:NUGET_PACKAGE_FILES_PATH -ne $null) {
    $nugetPackageFiles = $env:NUGET_PACKAGE_FILES_PATH -split ';'
    foreach ($package in $nugetPackageFiles) {
        # Get package version
        [xml]$xml = Get-Content -Path $package
        $version = $xml.Project.PropertyGroup.Version

        # Compare it with component.json file
        if ($component.version -ne $version) {
            throw "Versions in component.json and $package do not match"
        }
    }
}

# Release all packages
$packages = (Get-ChildItem -Path "dist/*.$version.nupkg")
foreach ($package in $packages) {
    $packagePath = $package.FullName
    # Push to nuget repo
    dotnet nuget push $packagePath -s "github" --skip-duplicate
}
