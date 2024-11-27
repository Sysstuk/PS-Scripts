# Authenticate
Connect-MgGraph -ClientID "7381ac60-3e83-468f-aab1-c6a84fdf3824" -TenantId "e10751b6-9dfc-4faf-b37d-aa5bdca24fcf" -CertificateName "CN=Graph Certificate"

Write-Host "USERS:"
Write-Host "======================================================"
# List first 50 users
Get-MgUser -Property "id,displayName" -PageSize 50 | Format-Table DisplayName, Id

Write-Host "GROUPS:"
Write-Host "======================================================"
# List first 50 groups
Get-MgGroup -Property "id,displayName" -PageSize 50 | Format-Table DisplayName, Id

# Disconnect
Disconnect-MgGraph