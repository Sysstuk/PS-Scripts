Connect-AzureAD
Connect-ExchangeOnline

$users = (Get-AdUser -Filter 'Enabled -eq $false' -searchbase "Ou=Disabled Users,OU=SEQ,DC=springeq,DC=local").UserPrincipalName

foreach ($user in $users) {
    $objID = (Get-AzureADUser -ObjectID $user).objectID

    $groups = (Get-AzureADUserMembership -ObjectId $objID).ObjectID
    $groupNames = (Get-AzureADUserMembership -ObjectID $objID).displayName

    Add-Content -Path "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\Scrub Users2.txt" -Value "$user - $groupNames`n"
    
    foreach($group in $groups) {
        if ($group -ne "7b181853-5483-44f0-ab96-fc73261a73cc") {
            if(((Get-AzureADMSGroup -id $group).GroupTypes) -eq 'Unified') {
                remove-unifiedgrouplinks -identity $group -linktype Member -links $user -Confirm:$false
            } elseif ((Get-AzureADMSGroup -id $group).MailEnabled -eq $true) {
                Remove-DistributionGroupMember -Identity $group -Member $user -Confirm:$false
            } else {
                Remove-AzureADGroupMember -ObjectID $group -MemberID $objID
            }
        }
    }
}

#For removing AD groups from all users. It'll throw an error if you try to remove through AAD cmdlets
$users = (Get-AdUser -Filter 'Enabled -eq $false' -searchbase "Ou=Disabled Users,OU=SEQ,DC=springeq,DC=local")

foreach ($user in $users) {
    $groups = Get-ADPrincipalGroupMembership -identity $user
    foreach ($group in $groups) {
        if (($group).name -ne "Domain Users") {
            Write-Host $group
            Remove-AdGroupMember -Identity $group -Members $user -Confirm:$false
        }
    }
}
