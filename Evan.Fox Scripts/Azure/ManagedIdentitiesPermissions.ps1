# Sign in to your Azure subscription
$sub = Get-AzSubscription -ErrorAction SilentlyContinue
if(-not($sub))
{
    Connect-AzAccount
}

# If you have multiple subscriptions, set the one to use
# Select-AzSubscription -SubscriptionId <SUBSCRIPTIONID>

#Provide an appropriate value for the variables below then execute the script
$resourceGroup = "HelpDesk_Automations"

# These values are used in this tutorial
$automationAccount = "HD-Automation"
#$userAssignedManagedIdentity = "UAMI"

#Use PowerShell cmdlet New-AzRoleAssignment to assign a role to the system-assigned managed identity
$role1 = "Contributor"

$SAMI = (Get-AzAutomationAccount -ResourceGroupName $resourceGroup -Name $automationAccount).Identity.PrincipalId
New-AzRoleAssignment -ObjectId $SAMI -ResourceGroupName $resourceGroup -RoleDefinitionName $role1

#Use this one if the managed identity is user-assigned 
#$UAMI = (Get-AzUserAssignedIdentity -ResourceGroupName $resourceGroup -Name $userAssignedManagedIdentity).PrincipalId
#New-AzRoleAssignment -ObjectId $UAMI -ResourceGroupName $resourceGroup -RoleDefinitionName $role1

$role2 = "Reader"
New-AzRoleAssignment -ObjectId $SAMI -ResourceGroupName $resourceGroup -RoleDefinitionName $role2