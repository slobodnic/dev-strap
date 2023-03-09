Param([string]$SDKVersion = "6")
$SDKPackage = $("Microsoft.DotNet.SDK." + $SDKVersion)

winget install $SDKPackage