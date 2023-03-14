# Work in progress ![](https://geps.dev/progress/10)
# Introduction 
Script to bootsrap the installation of the tools needed for development

# Getting Started
0.  Pre-requisites
1.	Installation process
2.	Software dependencies
3.	Latest releases


# Using the scripts
In powershell execute the following:

`Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Command -ScriptBlock ([scriptblock]::Create([System.Text.Encoding]::UTF8.GetString((New-Object System.Net.WebClient).DownloadData('https://raw.githubusercontent.com/slobodnic/dev-strap/main/setup.ps1')))) -ArgumentList -Online`

To install the optional tools as well, execute the following command:

`Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Command -ScriptBlock ([scriptblock]::Create([System.Text.Encoding]::UTF8.GetString((New-Object System.Net.WebClient).DownloadData('https://raw.githubusercontent.com/slobodnic/dev-strap/main/setup.ps1')))) -ArgumentList -InstallOptional -Online`

# Contribute
Please add installation scripts for tools under the scripts folder
