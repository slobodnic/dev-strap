$distros = wsl.exe --list --quiet

if ($distros -eq $null -Or -Not $distros.Contains("Ubuntu") {
    # Ubuntu distro not found
    wsl --install -d Ubuntu;
}