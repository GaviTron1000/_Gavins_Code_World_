Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
$dlPath = "C:\Windows\Temp\jre-windows-x64.exe"
Function Invoke-JavaInstaller {
    Param(
		[Parameter(Mandatory=$true,Position=0)] 
		[ValidateNotNullOrEmpty()]
		[string]$InstallPath,
        [Parameter(Mandatory=$false,Position=1)] 
		[ValidateNotNullOrEmpty()]
		[string]$LogPath,
        [Parameter(Mandatory=$false,Position=2)] 
		[ValidateNotNullOrEmpty()]
		[switch]$NoUninstall,
        [Parameter(Mandatory=$false,Position=3)] 
		[ValidateNotNullOrEmpty()]
		[switch]$x64
    )

    function Get-InstalledApps {
        if ([IntPtr]::Size -eq 4) {
            $regpath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
        }
        else {
            $regpath = @(
                'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
                'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
            )
        }
        Get-ItemProperty $regpath | .{process{if($_.DisplayName -and $_.UninstallString) { $_ } }} | 
            Select-Object DisplayName, Publisher, InstallDate, DisplayVersion, UninstallString | 
            Sort-Object DisplayVersion
    }

    function Convert-ToFloat($version) {
        while (($version.ToCharArray() | Where-Object {$_ -eq '.'} | Measure-Object).Count -gt 1) {
                $aux = $version.Substring($version.LastIndexOf('.') + 1)
                $version = $version.Substring(0,$version.LastIndexOf('.')) + $aux
            }
            return [float]$version
    }

    if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
        if ($x64) {
            Start-Transcript -Path "$($LogPath)\$($env:COMPUTERNAME)_x64.log" | Out-Null
        }
        else {
            Start-Transcript -Path "$($LogPath)\$($env:COMPUTERNAME).log" | Out-Null
        }
    }

    if (-not [Environment]::Is64BitOperatingSystem -and $x64) {
        Write-Error "Error: 64 Bit version can not be installed on 32 Bit Operating System."
        if (-not [string]::IsNullOrWhiteSpace($LogPath)) {Stop-Transcript}
        Exit 1
    }

    $ErrorActionPreference = "Stop"
    $Install = $true

    try {
    $jreExeFile = Get-Item -Path $InstallPath
    } catch {
        Write-Error "Error accessing $($InstallPath)."
        Write-Error "$($Error[0])"
        if (-not [string]::IsNullOrWhiteSpace($LogPath)){Stop-Transcript}
        Exit 1
    }

    $jreExeVersion = Convert-ToFloat $jreExeFile.VersionInfo.ProductVersion

    Write-Verbose "JRE $($jreExeVersion) selected for installation."

    if ($x64) {
        $jreInstalledVersion = Get-InstalledApps | Where-Object {$_.DisplayName -like '*Java*(64-bit)'}
    }
    else {
        $jreInstalledVersion = Get-InstalledApps | Where-Object {$_.DisplayName -like '*Java*' -and $_.DisplayName -notlike '*Java*(64-bit)'}
    }

    if ($jreInstalledVersion) {

        foreach ($installation in $jreInstalledVersion) {

            $version = Convert-ToFloat $installation.DisplayVersion
        
            if (($version -lt $jreExeVersion)) {
                Write-Verbose "JRE $($version) detected."
                if (-not $NoUninstall) {
                    Write-Verbose "Unnistalling JRE $($version)."
                    if ($installation.UninstallString -like '*msiexec*') {
                        Start-Process -FilePath cmd.exe -ArgumentList '/c', $installation.UninstallString, '/qn /norestart' -Wait
                    }
                    else {
                        Start-Process -FilePath cmd.exe -ArgumentList '/c', $installation.UninstallString, '/verysilent' -Wait
                    }
                }
            }
            else {
                Write-Verbose "JRE $($version) or greater already installed."
                $Install = $false
            }
        }
    } 
    else {
        Write-Verbose "No JRE version detected."
    }

    if ($Install) {
        Write-Verbose "Starting installation of JRE $($jreExeVersion) and exiting."
        Start-Process $InstallPath -ArgumentList "/s SPONSORS=0"
    }

    if (-not [string]::IsNullOrWhiteSpace($LogPath)){Stop-Transcript}
}
Invoke-JavaInstaller -InstallPath $dlPath -x64 