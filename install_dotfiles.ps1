try {
    # Ensure the directory does not exist before proceeding.
    $nvimDir = Join-Path $HOME '.config/nvim'
    if (-Not (Test-Path $nvimDir)) {
        Write-Output "nvim directory does not exist. Proceeding with setup..."
        $currentPath = Get-Location
        New-Item -ItemType SymbolicLink -Path $nvimDir -Target "$($currentPath)/vim_setup"
        New-Item -ItemType SymbolicLink -Path "$HOME/.tmux.conf" -Target "$($currentPath)/dotfiles/.tmux.conf"
        New-Item -ItemType SymbolicLink -Path "$HOME/.zshrc" -Target "$($currentPath)/dotfiles/.zshrc"
        New-Item -ItemType SymbolicLink -Path "$HOME/openai_key" -Target "$($currentPath)/../openai_key"
    } else {
        Write-Output "nvim directory already exists. Aborting setup."
    }

    if (Test-Path $PROFILE) {
        Remove-Item $PROFILE -Force
    }
    New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$($currentPath)/dotfiles/Microsoft.PowerShell_profile.ps1"

} catch {
    Write-Output "Exception occurred! Error: $_"
    exit 1
}

Write-Output "All commands executed successfully!"

