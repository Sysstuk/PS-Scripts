Connect-MgGraph

Get-MgSubscribedSku | Select-Object -Property * | Format-List

$licenses = Get-MgSubscribedSku
Get-mgsubscribedsku | Select-Object skupartnumber

$licenses[11].serviceplans