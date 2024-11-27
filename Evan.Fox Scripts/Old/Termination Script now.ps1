#Disables user, resets password, removes groups, removes organization info, and moves to disabled OU
function adterm {
    #Checks to see if user exists or is already disabled
    Do {
        $empName = Read-Host "Enter Terminated Employee's Username"
        $termEmp = Get-ADUser -Filter 'SAMAccountName -eq $empName'
        $empName = (($termEmp).SAMAccountName).toLower()
        if ($termEmp -eq $null) {
            $empName = $null
            Write-Warning "User object does not exist. Please try again"
        } elseif ((Get-ADUser $termEmp).Enabled -eq $False) {
            $empName = $null
            $termEmp = $null
            Write-Warning "User object is already disabled"
        }
    }
    Until ($termEmp -ne $null)

    
    #Resets password/disables account
    $NewPassword = (Read-Host -Prompt "Provide New Password" -AsSecureString)
    Set-ADAccountPassword -Identity $termEmp -NewPassword $NewPassword -Reset -Credential $adCreds
    Write-Host "Password Reset"
    Disable-AdAccount -Identity $termEmp -Credential $adCreds
    Write-Host "Account Disabled"
    
    #Retrieves the assigned manager of the user before info gets wiped. Will be used for Exchange delegations
    $mgr = (Get-ADUser ((Get-ADUser $termEmp -Properties Manager).Manager) -properties displayname).displayname
    $mgr = "Alyssa Burton"

    #Removes all groups from AD profile ("Member Of" tab)
    $groups = Get-ADPrincipalGroupMembership -identity $termEmp -Credential $adCreds
    foreach ($group in $groups) {
        if (($group).name -ne "Domain Users") {
            Write-Host $group
            Remove-AdGroupMember -Identity $group -Members $termEmp -Credential $adCreds
        }
    }
    Write-Host "Groups Removed"
    
    #Get description from user and sets it. Removes Organizational info
    $description = Read-Host -Prompt "Enter new description"
    Set-AdUser $termEmp -Title $null -Department $null -Company $null -Description $description -Clear Manager -Credential $adCreds
    Write-Host "Description set and Organization Info cleared"

    #Moves user to disabled OU
    Move-ADObject -Identity $termEmp -TargetPath "OU=Disabled Users,OU=SEQ,DC=springeq,DC=local" -Credential $adCreds
    Write-Host "User moved to Disabled Users OU"

    dcsync
    aadterm
}


#Runs the AD/AAD sync on DC-03. If it fails, it will try it again
function dcsync {
    try{
        Write-Host "Attempting DC03 sync. Please wait 30 seconds for sync"
        Invoke-Command -ComputerName 'springeq-dc03' -ScriptBlock {Start-AdSyncSyncCycle -Policytype Delta} -Credential $adCreds
        Start-Sleep -Seconds 30
        Write-Host "Sync Successful"
    } catch {
        Write-Host "Sync failed. Trying again..."
        dcsync
    }
}


#Connects to AAD and removes licenses, sessions, groups, converts the mailbox, and delegates/sets OOO for it
function aadterm {
    try{
        Get-AzureADCurrentSessionInfo -ErrorAction Stop > $null
    } catch {
        Connect-AzureAD
    }
    
    #set empName to full email address for pulling AzureAdUser account
    $empName = $termEmp.userprincipalname

    #Sets ObjectID and UPN variables from AD username
    $objId = (Get-AzureAdUser -ObjectId "$empName").ObjectID
    $upn = (Get-AzureAdUser -ObjectId "$empName").UserPrincipalName

    #Checks for an active Exchange Online connection
    $getsessions = Get-PSSession | Select-Object -Property State, Name
    $isconnected = (@($getsessions) -like '@{State=Opened; Name=ExchangeOnlineInternalSession*').Count -gt 0
    if ($isconnected -ne "True") {
        Connect-ExchangeOnline
    }

    #Revokes user sessions
    Revoke-AzureADUserAllRefreshToken -ObjectId $objId
    Write-Host "Azure session token revoked"

    #Pulls group memberships, logs them, then removes the user from them
    $roleGroups = (Get-AzureADUserMembership -ObjectId $objId).ObjectID
    #$roleGroups
    
    #If statement makes sure it's not removing them from All Users since it will throw a permission error for most of us
    foreach($item in $roleGroups) {
        if ($item -ne "7b181853-5483-44f0-ab96-fc73261a73cc") {
            if(((Get-AzureADMSGroup -id $item).GroupTypes) -eq 'Unified') {
                remove-unifiedgrouplinks -identity $item -linktype Member -links $upn
            } elseif ((Get-AzureADMSGroup -id $item).MailEnabled -eq $true) {
                Remove-DistributionGroupMember -Identity $item -Member $upn
            } else {
                Remove-AzureADGroupMember -ObjectID $item -MemberID $objId
            }
        }
    }
    Write-Host "User removed from assigned Azure and Exchange groups"
    

    #Sets mailbox to shared, adds manager delegate, and asks for/sets OOO message    
    Get-Mailbox -Identity $upn | Set-Mailbox -Type Shared
    Write-Host "Mailbox converted to shared"

    Add-MailboxPermission $upn -User $mgr -AccessRights FullAccess -InheritanceType All
    Write-Host "Manager set as delegate on mailbox"

    $ooo = Read-Host -Prompt "Please copy and paste OOO message from ticket"
    Set-MailboxAutoReplyConfiguration -Identity $upn -AutoReplyState Enabled -ExternalAudience All -ExternalMessage $ooo -InternalMessage $ooo
    Write-Host "OOO message enabled"

    #Removes all licenses for user
    $userList = Get-AzureADUser -ObjectID $upn
    $Skus = $userList | Select -ExpandProperty AssignedLicenses | Select SkuID
    if($userList.Count -ne 0) {
        if($Skus -is [array])
        {
            $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
            for ($i=0; $i -lt $Skus.Count; $i++) {
                $licenses.RemoveLicenses +=  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus[$i].SkuId -EQ).SkuID   
            }
            Set-AzureADUserLicense -ObjectId $upn -AssignedLicenses $licenses
        } else {
            $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
            $licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus.SkuId -EQ).SkuID
            Set-AzureADUserLicense -ObjectId $upn -AssignedLicenses $licenses
        }
    }
    Write-Host "Licenses removed from user"
}


$adCreds = Get-Credential -Message "Enter la credentials with full email address"
#$msCreds = Get-Credential -Message "Enter AAD credentials"
import-module azureadpreview

#Sets up variables for the do-while statement
$caption = "Continue?"
$message = "Employee terminated. Would you like to repeat the process?"
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)


Do{
    adterm
    
    $continue = $host.ui.promptforchoice($caption,$message,$options,1) #Defaults to No (1)
} While ($continue -eq 0)
