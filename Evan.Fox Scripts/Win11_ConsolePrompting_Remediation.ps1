##Enter the path to the registry key for example HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
$regpath = "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds"

##Enter the name of the registry key for example EnableLUA
$regname = "ConsolePrompting"

##Enter the value of the registry key for example 0
$regvalue = "True"

##Enter the type of the registry key for example DWord
$regtype = "String"


New-ItemProperty -LiteralPath $regpath -Name $regname -Value $regvalue -PropertyType $regtype -Force -ea SilentlyContinue;