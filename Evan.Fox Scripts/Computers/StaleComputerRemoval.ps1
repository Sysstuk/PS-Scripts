$staleDate = (get-date).adddays(-90)
$today = get-date -format filedate

$computers = [System.Collections.ArrayList]@()
$exportList = [System.Collections.ArrayList]@()

$computers = get-adcomputer -filter 'objectclass -eq "Computer"' -searchbase "OU=Computers,OU=SEQ,DC=springeq,DC=local" -searchscope 1 -Properties Name,lastlogondate,lastlogontimestamp | where-object {$_.lastlogondate -ne $null}
$DCs = Get-ADDomainController -Filter *

foreach ($computer in $computers) {
    $AccountName = $computer.name
    $LatestLogon = 0
    foreach ($DC in $DCs) {
        # Get the last logon date of the account from the current domain controller
        $LastLogon = Get-ADComputer $AccountName -Server $DC.HostName -Properties lastLogon | Select-Object -ExpandProperty lastLogon
      
        # If the last logon date is later than the latest logon date, update the latest logon date
        if ($LastLogon -gt $LatestLogon) {
          $LatestLogon = $LastLogon
        }
    }
      
    # Convert the latest logon date to a readable format
    $LatestLogonDate = [DateTime]::FromFileTime($LatestLogon)
    $latestLogonDate
    if($latestLogonDate -gt $staledate){
        write-host "Not Stale"
    }
  
    if ($latestLogonDate -lt $staledate) {
        $object = [PSCustomObject]@{
            Name = $computer.name
            Last_Logon = $computer.lastlogondate
        }
        $exportList.add($object)
        set-adcomputer -identity $computer -enabled $false
        Move-ADObject $computer -TargetPath "OU=Disabled Computers,OU=Computers,OU=SEQ,DC=springeq,DC=local"
   }
}
$exportList | Export-Excel "\\springeq.local\dfs\office\it\Script Logs\StaleComputers\Computers $today.xlsx"
