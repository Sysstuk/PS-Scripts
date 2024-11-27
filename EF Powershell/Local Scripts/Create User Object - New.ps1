function assign-role {
 
try {

 Get-AzureADCurrentSessionInfo  -ErrorAction Stop > $null 

}

catch {

   Connect-AzureAD -Credential $aadCred
   assign-role
}
       

    try {
        Invoke-command -ComputerName 'springeq-dc03' -ScriptBlock { start-adsyncsynccycle -policytype delta } -Credential $gCreds
        Write-Host "Waiting for sync... Please wait 75 seconds." -ForegroundColor Yellow 
        Start-Sleep -Seconds 75
        $objID = (Get-AzureADUser -ObjectId "$upn").objectID
    }
    catch {
        assign-role
    }

    Write-Host "Assiging E3 license to user..." -ForegroundColor Yellow 
    Set-AzureADUser -ObjectID $UPN -UsageLocation "US"
    $planName = "ENTERPRISEPACK"
    $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
    $License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $planName -EQ).SkuID
    $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    $LicensesToAssign.AddLicenses = $License
    Set-AzureADUserLicense -ObjectId $upn -AssignedLicenses $LicensesToAssign

    $getsessions = Get-PSSession | Select-Object -Property State, Name
    $isconnected = (@($getsessions) -like '@{State=Opened; Name=ExchangeOnlineInternalSession*').Count -gt 0
    If ($isconnected -ne "True") {
    Connect-ExchangeOnline
    }      
    Write-Host "Adding $user to Spring EQ Staff distribution group.  Please wait 75 seconds for mailbox setup to complete" -ForegroundColor Yellow 
    Start-Sleep -Seconds 75
    Add-DistributionGroupMember -Identity "Spring EQ Staff" -Member $UPN
    Write-Host "Is user local to the PHL office?" -ForegroundColor Yellow
    $sel2 = read-host "(Y/N)"
    
    if ($sel2 -eq "Y") {
        Add-DistributionGroupMember -Identity "Philadelphia Staff" -Member "$UPN"  
        New-User
    } 
    elseif ($sel2 -eq "N") {
        New-User
    }


    Write-Host "Enabling litigation hold on mailbox" -ForegroundColor Yellow
    Set-Mailbox -Identity $UPN -LitigationHoldEnabled $true -LitigationHoldDuration 2556
    Write-Host "Enabling archiving..." -ForegroundColor Yellow
    Enable-Mailbox -Identity $UPN -Archive 
    Write-Host "Disabling focused inbox..."
    Set-FocusedInbox -Identity $UPN -FocusedInboxOn $false


}


function New-User {

    [System.Collections.ArrayList]$table = @{}
    $FName = read-host "Enter User's First Name"
    $LName = read-host "Enter User's Last Name"
    $Desc = read-host "Enter Job Title"
    $Dept = read-host "Enter Department Name"
    $user = "$(($FName).ToLower()).$(($LName).ToLower())" -replace "'", ""
    $strPass = ($FName.Substring(0, 1).ToUpper() + $LName.Substring(0, 1).ToUpper() + '@spring23!')
    $Path = "OU=SpringEQ Users, DC=springeq, DC=local" 
    $UPN = "$($user)@springeq.com"
    $DN = "$($FName) $($LName)"
  
    
    Do {
        $Manager = read-host "Enter Manager Username"
         $mgr = get-aduser -Filter 'SamAccountName -eq $Manager'
        if ($mgr -eq $null) {
            Write-Warning "User account object not found, please try again"
        }
    }
    Until ($mgr -ne $null)
    
    
    $gAD = get-aduser -Identity $user
    $Pass = ConvertTo-SecureString -String $strPass  -AsPlainText -Force 

    if ($gAD -ne $null) {
        Write-Warning "User object [$($user)] already exists, restarting..."
        New-User 
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

    }

    $table 

    Write-Host "Is the above information correct?" -ForegroundColor Yellow 

    $sel = read-host "Y/N"

    if ($sel -eq 'Y') {

        
        New-ADUser -Name $DN -GivenName $FName -Surname $LName -DisplayName $DN -AccountPassword $Pass -Description $Desc -Title $Desc -Company 'Spring EQ' -Department $Dept  -AccountNotDelegated $true -Server "springeq-dc03" -Path $Path -Enabled $true -SamAccountName $user -UserPrincipalName $UPN -Manager $mgr.SamAccountName -Credential $gCreds
        Add-ADGroupMember -Identity 'CN=VPNAllowAll,OU=Security Groups,DC=springeq,DC=local' -Members $user -Server "SpringEQ-DC03" -Credential $gCreds
        Write-Host "Searching for users with similar title for membership copy" -ForegroundColor Yellow 
        
        $source = (Get-ADUser -Filter "Description -like '*$($desc)*'" -properties *) | where-object { $_.Enabled -eq $true } | select-object -first 1 
        Write-Host "Copying From - $source.name" 
        $group = (get-aduser -Identity $source.SamAccountName  -Properties *).memberof
        foreach ($item in $group) {
            Add-ADGroupMember -Identity $item -Members $user -server "SpringEQ-DC03" -Credential $gCreds

        } 
        
               
        Write-Host "Assigning role in FortiGate SSL app in AzureAD" -ForegroundColor Yellow
        assign-role
       
    }
}

$gCreds = get-credential 
import-module azureadpreview
new-user 