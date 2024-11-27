function sync {
 
    if ((Get-AzureADCurrentSessionInfo) -ne $null) {
        Invoke-command -ComputerName 'uE1CIF-P003W' -ScriptBlock { start-adsyncsynccycle -policytype delta } -Credential $gCreds
        Write-Host "Waiting for sync... Please wait 120 seconds." -ForegroundColor Yellow 
        Start-Sleep -Seconds 120
        exo
    }
    else {
       Connect-AzureAD -Credential $aadCred
       sync
    }

    
}
 
function exo {
    $getsessions = Get-ConnectionInformation
    If ($getsessions -eq $null) {
        Connect-ExchangeOnline
    }    

    foreach ($obj in $table) {
        Do {
            Write-Host "Mailbox $($obj.UPN) still being created, please wait 30 seconds for refresh..."
            Start-Sleep -Seconds 30
        }
        Until ((get-mailbox -Identity $obj.UPN) -ne $null)
   
        Write-Host "Disabling focused inbox on $($obj.username)"
        Set-FocusedInbox -Identity $obj.UPN -FocusedInboxOn $false
        Write-Host "Enabling archiving and litigation hold on $($obj.username)"
        Set-Mailbox -Identity $obj.UPN -LitigationHoldEnabled $true -LitigationHoldDuration 2556
        Enable-Mailbox -Identity $obj.UPN -Archive   
    }
}
    
    
function new-user {
### Input Function Under Here if Script does not assign Licenses ###

    $xlsx = import-excel -Path $file.fullname -DataOnly 
    [system.collections.arraylist]$table = @{}

### begin of foreach loop ###
    $table = foreach ($obj in $xlsx) {
        ### Variables to split manager names and remove cost code from departments ### 
        $mgr = $obj.Supervisor
        $pos = $mgr.IndexOf(",")
        $mgrName = $mgr.Substring(0, $pos)
        $dept = $obj.'Department/ Cost Center'
        $deptpos = $dept.IndexOf("-")
        $fulldeptname = $dept.Substring($deptpos+1)

        ### find manager by displayname ###
        $adMgr = get-aduser -Filter {Name -eq $mgrName} 

        ### table contents ###
        $FName = $obj.'First Name'
        $LName = $obj.'Last Name'
        $user = "$(($FName).ToLower()).$(($LName).ToLower())" -replace "'", ""
        $strPass = ($FName.Substring(0, 1).ToUpper() + $LName.Substring(0, 1).ToUpper() + '@spring23!')
        $Path = "OU=New Hires,OU=Users,OU=SEQ,DC=springeq,DC=local" 
        $UPN = "$($user)@springeq.com"
        $DN = "$($FName) $($LName)"
        $Desc = $obj.'Job Title'
        $gAD = get-aduser -Identity $user -Credential $gCreds
        $Pass = ConvertTo-SecureString -String $strPass  -AsPlainText -Force 

        [pscustomobject]@{

            First       = $FName
            Last        = $LName
            DN          = $DN    
            Username    = $user
            Pass        = $Pass 
            Description = $Desc
            UPN         = $UPN
            Manager     = $mgrName
            MgrSAM = $adMgr.SAMAccountName
            Dept = $fulldeptname
            ResidingState = $obj.'Default: Addresses : State/Province'
            ReportingOffice = $obj.'Location : State/Province'
        }
    }

    $table 
    $rh = read-host "Does this information look correct? (Y/N)"
    if ($rh -eq "Y") {
        foreach ($obj in $table) {
            if (!(Get-ADUser -Filter "sAMAccountName -eq '$($user)'")) {        
                Write-Host "Creating AD Object - $($obj.Username)"            
                New-ADUser -Name $obj.DN -GivenName $obj.First -Surname $obj.Last -DisplayName $obj.DN -AccountPassword $obj.Pass -Description $obj.Description -Title $obj.Description -Company 'Spring EQ' -Department $obj.dept  -AccountNotDelegated $true -Server "springeq-dc03" -Path $Path -Enabled $true -SamAccountName $obj.username -UserPrincipalName $obj.UPN -Manager $obj.MgrSAM -Credential $gCreds 
                Write-Host "Searching for users with similar title for membership copy" -ForegroundColor Yellow  
                Start-Sleep -Seconds 20
            
                if (($obj.ReportingOffice -eq "") -or ($obj.ReportingOffice -eq "*Remote*")) {
                    set-aduser -Identity $obj.username -add @{extensionAttribute3 = "Remote"} -Credential $gCreds
                }
                else {
                    set-aduser -Identity $obj.username -add @{extensionAttribute3 = "$($obj.ReportingOffice)"} -Credential $gCreds
                }
                if($obj.Description -Like "*Loan Officer*"){
                    $proxy = get-aduser -identity $obj.username -properties *
                    Set-ADUser -Identity $proxy.SamAccountName -add @{proxyaddresses = "SMTP:$($proxy.SamAccountName)@springeq.com"} -Credential $gCreds
                    Set-ADUser -Identity $proxy.SamAccountName -add @{proxyaddresses = "smtp:$($proxy.SamAccountName).express@springeq.com"} -Credential $gCreds
                    Write-Host "Loan Officer proxies set"
                }
            
                set-aduser -Identity $obj.username -add @{extensionAttribute1 = "Internal"} -Credential $gCreds
                set-aduser -Identity $obj.username -add @{extensionAttribute4 = "$($obj.residingstate)"} -Credential $gCreds
                set-aduser -Identity $obj.username -add @{mail = "$($obj.UPN)"} -Credential $gCreds
            }    
            else {
                Write-Host "$($obj.username) exists, skipping..." -ForegroundColor Yellow 
            }
        }
        sync
    }    
    else {    
        Pause 
    }
    $Group = "CN=New Hire Passwords,OU=Groups,OU=SEQ,DC=springeq,DC=local"
    $newHires = get-aduser -filter * -searchbase "OU=New Hires,OU=Users,OU=SEQ,DC=springeq,DC=local" -Credential $gCreds
    foreach($user in $newHires) {
        Add-ADGroupMember -Identity $Group -Members $user.distinguishedName -Credential $gCreds
    }
}
    
$xlPath = "\\springeq.local\dfs\Office\IT\scripts\New Hire Reports (Test)\"

$file = get-childitem $xlPath | where-object {$_.name -like "*.xlsx"} | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1

$gCreds = get-credential 

import-module azureadpreview
Connect-AzureAD
Connect-ExchangeOnline -showbanner:$false

new-user 