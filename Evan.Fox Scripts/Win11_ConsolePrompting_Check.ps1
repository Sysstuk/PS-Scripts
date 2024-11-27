$regpath = "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds"

##Enter the name of the registry key for example EnableLUA
$regname = "ConsolePrompting"

##Enter the value of the registry key we are checking for, for example 0
$regvalue = "True"


Try {
    $Registry = Get-ItemProperty -Path $regpath -Name $regname -ErrorAction Stop | Select-Object -ExpandProperty $regname
    If ($Registry -eq $regvalue){
        Write-Output "Compliant"
        Exit 0
    } 
    Write-Warning "Not Compliant"
    Exit 1
} 
Catch {
    Write-Warning "Not Compliant"
    Exit 1
}