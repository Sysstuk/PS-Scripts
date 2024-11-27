#And we'll make that a function
Function Get-ADUserLockouts {
    [CmdletBinding(
        DefaultParameterSetName = 'All'
    )]
    Param (
        [Parameter(
            ValueFromPipeline = $true,
            ParameterSetName = 'ByUser'
        )]
        [Microsoft.ActiveDirectory.Management.ADUser]$Identity
    )
    Begin{
        $LockOutID = 4740
        $PDCEmulator = (Get-ADDomain).PDCEmulator
    }
    Process {
        If($PSCmdlet.ParameterSetName -eq 'All'){
            #Query event log
            $events = Get-WinEvent -ComputerName $PDCEmulator -credential $cred -FilterHashtable @{
                LogName = 'Security'
                ID = $LockOutID
            }
        }ElseIf($PSCmdlet.ParameterSetName -eq 'ByUser'){
            $user = Get-ADUser $Identity
            #Query event log
            $events = Get-WinEvent -ComputerName $PDCEmulator -credential $cred -FilterHashtable @{
                LogName = 'Security'
                ID = $LockOutID
            } | Where-Object {$_.Properties[0].Value -eq $user.SamAccountName}
        }
        ForEach($event in $events){
            [pscustomobject]@{
                UserName = $event.Properties[0].Value
                CallerComputer = $event.Properties[1].Value
                TimeStamp = $event.TimeCreated
            }
	    $events
        }
    }
    End{}
}


$cred = Get-Credential
#Usage
Get-ADUserLockouts

#Single user

#Get-ADUser 'devin.test2' | Get-ADUserLockouts
Read-Host "Press any key to end"