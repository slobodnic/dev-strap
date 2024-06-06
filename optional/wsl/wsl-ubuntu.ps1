$distros = wsl.exe --list --quiet

if ($distros -eq $null -Or -Not $distros.Contains("Ubuntu")) {
    # Ubuntu distro not found
    wsl --install -d Ubuntu;
    wsl -s Ubuntu;
    wsl -e ./optional/wsl/strap.sh
}