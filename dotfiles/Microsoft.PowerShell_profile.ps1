function Get-Path {
    [CmdLetBinding()]
    Param()
    $PathFiles = @()
    $PathFiles += '/etc/paths'
    $PathFiles = Get-ChildItem -Path /private/etc/paths.d | Select-Object -Expand FullName
    $PathFiles | ForEach-Object {
        Get-Content -Path $PSItem | ForEach-Object {
            $_
        }
    }
    $Paths
}

function Add-Path {
    Param($Path)
    $env:PATH = "${env:PATH}:$Path"
}

function Update-Environment{
    [CmdLetBinding()]
    Param()
    $Paths = $env:PATH -split ':'
    # Ensure Homebrew path is added
    $homebrewPath = "/opt/homebrew/bin"
    if ($homebrewPath -notin $Paths) {
        Add-Path -Path $homebrewPath
    }
    # Add other paths from the system
    Get-Path | ForEach-Object {
        If ($PSItem -notin $Paths) {
            Add-Path -Path $PSItem
        }
    }
}

Update-Environment

oh-my-posh init pwsh --config (Join-Path (brew --prefix oh-my-posh) "themes/multiverse-neon.omp.json") | Invoke-Expression


