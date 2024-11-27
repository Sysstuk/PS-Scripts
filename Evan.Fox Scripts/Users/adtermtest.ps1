$adCreds = Get-Credential

    Do {
        $empName = Read-Host "Enter Terminated Employee's Username"
        $termEmp = Get-ADUser -Filter 'SAMAccountName -eq $empName'
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

    #Sets username entry to all lower case for later user 
    $empName = (($termEmp).SAMAccountName).toLower()
    
    #Resets password/disables account
    $NewPassword = (Read-Host -Prompt "Provide New Password" -AsSecureString)
    Set-ADAccountPassword -Identity $termEmp -NewPassword $NewPassword -Reset -Credential $adCreds
    Write-Host "Password Reset"
    Disable-AdAccount -Identity $termEmp -Credential $adCreds
    Write-Host "Account Disabled"
    
    #Retrieves the assigned manager of the user before info gets wiped. Will be used for Exchange delegations
    $mgr = (Get-ADUser ((Get-ADUser $termEmp -Properties Manager).Manager) -properties displayname).displayname
    
    #Removes all groups from AD profile ("Member Of" tab)
    $groups = Get-ADPrincipalGroupMembership -identity $termEmp
    foreach ($group in $groups) {
        if (($group).name -ne "Domain Users") {
            Write-Host $group
            Remove-AdGroupMember -Identity $group -Members $termEmp
        }
    }
    Write-Host "Groups Removed"
    
    #Get description from user and sets it. Removes Organizational info
    $description = Read-Host -Prompt "Enter new description"
    Set-AdUser $termEmp -Title $null -Department $null -Company $null -Description $description -Clear Manager
    Write-Host "Description set and Organization Info cleared"

    #Moves user to disabled OU
    Move-ADObject -Identity $termEmp -TargetPath "OU=Disabled Users,OU=SEQ,DC=springeq,DC=local"
    Write-Host "User moved to Disabled Users OU"