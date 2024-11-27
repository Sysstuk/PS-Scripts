function sync {
    if ((Get-AzureADCurrentSessionInfo) -ne $null) {
        Invoke-command -ComputerName 'uE1CIF-P003W' -ScriptBlock { start-adsyncsynccycle -policytype delta } -Credential $gCreds
        Write-Host "Waiting for sync... Please wait 60 seconds." -ForegroundColor Yellow 
        Start-Sleep -Seconds 60
	Write-Host "Starting on the mailboxes..."
        exo
    }
    else {
       Connect-AzureAD
       sync
    }
}
    

function exo {
    $getsessions = Get-ConnectionInformation
    If ($getsessions -eq $null) {
        Connect-ExchangeOnline
    }

    Do {
        Write-Host "Mailbox $($obj.UPN) still being created, please wait 30 seconds for refresh..."
        Start-Sleep -Seconds 30
    }
    Until ((get-mailbox -Identity $obj.UPN) -ne $null)

    Write-Host "Enabling litigation hold on mailbox" -ForegroundColor Yellow
    Set-Mailbox -Identity $UPN -LitigationHoldEnabled $true -LitigationHoldDuration 2556
    Write-Host "Enabling archiving..." -ForegroundColor Yellow
    Enable-Mailbox -Identity $UPN -Archive 
    Write-Host "Disabling focused inbox..."
    Set-FocusedInbox -Identity $UPN -FocusedInboxOn $false   

    $aadID = (get-azureaduser -objectid $upn).objectid
    $aadGroupID = (get-azureadgroup -searchstring 'Managed Device for MFA Exemption').objectid
    Add-AzureAdGroupMember -ObjectId $aadGroupID -RefObjectID $aadID 
}    
    
function New-User {
    
    [System.Collections.ArrayList]$table = @{}
    $FName = read-host "Enter User's First Name"
    $LName = read-host "Enter User's Last Name"
    $Desc = read-host "Enter Job Title"
    $Dept = read-host "Enter Department Name"
    $user = "$(($FName).ToLower()).$(($LName).ToLower())" -replace "'", ""
    $strPass = ($FName.Substring(0, 1).ToUpper() + $LName.Substring(0, 1).ToUpper() + '@spring23!')
    $Path = "OU=New Hires,OU=Users,OU=SEQ,DC=springeq,DC=local" 
    $UPN = "$($user)@springeq.com"
    $DN = "$($FName) $($LName)"
    $rhReportOffice = read-host "What office will this user report to?"
    $rhState = read-host "What state is this user based in?"
    
    Do {
        $Manager = read-host "Enter Manager Username"
            $mgr = get-aduser -Filter 'SamAccountName -eq $Manager'
        if ($mgr -eq $null) {
            Write-Warning "User account object not found, please try again"
        }
    }
    Until ($mgr -ne $null)
    
    $Pass = ConvertTo-SecureString -String $strPass  -AsPlainText -Force 

    try {
        $gAD = get-aduser -Identity $user
        Write-Warning "User object [$($user)] already exists, restarting..."
        New-User
    }
    catch {
        Write-Host "User object [$($user)] doesn't exist. Continuing process..."
    }

    [pscustomobject]$table = @{

        First       = $FName
        Last        = $LName
        DN          = $DN    
        Username    = $user
        Pass        = $strPass 
        Description = $Desc
        UPN         = $UPN
        Manager     = $mgr.Name
        ReportingOffice = $rhReportOffice
        State = $rhState
    }

    $table 
    Write-Host "Is the above information correct?" -ForegroundColor Yellow 
    $sel = read-host "Y/N"

    if ($sel -eq 'Y') {
        New-ADUser -Name $DN -GivenName $FName -Surname $LName -DisplayName $DN -AccountPassword $Pass -Description $Desc -Title $Desc -Company 'Spring EQ' -Department $Dept  -AccountNotDelegated $true -Server "springeq-dc04" -Path $Path -Enabled $true -SamAccountName $user -UserPrincipalName $UPN -Manager $mgr.SamAccountName -Credential $gCreds
        set-aduser -Identity $table.username -add @{extensionAttribute1 = "Internal"}  -Credential $gCreds         
        set-aduser -Identity $table.username -add @{extensionAttribute3 = "$rhReportOffice"}  -Credential $gCreds         
        set-aduser -Identity $table.username -add @{extensionAttribute4 = "$rhState"} -Credential $gCreds 
        set-aduser -Identity $table.username -add @{mail = "$UPN"} -Credential $gCreds

        if($obj.Description -Like "*Loan Officer*"){
            $proxy = get-aduser -identity $obj.username -properties *
            Set-ADUser -Identity $proxy.SamAccountName -add @{proxyaddresses = "SMTP:$($proxy.SamAccountName)@springeq.com"} -Credential $gCreds
            Set-ADUser -Identity $proxy.SamAccountName -add @{proxyaddresses = "smtp:$($proxy.SamAccountName).express@springeq.com"} -Credential $gCreds
            Write-Host "Loan Officer proxies set"
        }
	$Group = "CN=New Hire Passwords,OU=Groups,OU=SEQ,DC=springeq,DC=local"
        Add-ADGroupMember -Identity $Group -Members $table.username -Credential $gCreds

	sync
    }
}
    
$gCreds = get-credential

import-module azureadpreview
Connect-AzureAD
Connect-ExchangeOnline -showbanner:$false

new-user 