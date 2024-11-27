##Enter the path to the registry key for example HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
$regpath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

##Enter the name of the registry key for example EnableLUA
$regname = "TaskbarAl"

##Enter the value of the registry key for example 0
$regvalue = "0"

##Enter the type of the registry key for example DWord
$regtype = "Dword"


New-ItemProperty -LiteralPath $regpath -Name $regname -Value $regvalue -PropertyType $regtype -Force -ea SilentlyContinue;