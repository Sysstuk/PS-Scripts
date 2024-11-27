$cred = Get-Credential -Message "Enter la creds"
$ou = "OU=Partners,OU=Users,OU=SEQ,DC=springeq,DC=local"

$users = Get-ADUser -Filter 'Description -like "Visionet*"' -SearchBase $ou
$users | Set-ADUser -replace @{extensionattribute2="Visionet"}
#-Credential $cred

