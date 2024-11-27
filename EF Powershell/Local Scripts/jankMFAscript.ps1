function 2MFA {


Write-Host "Checking for existing login session..." -ForegroundColor Yellow 


try {

Get-MsolDomain -ErrorAction Stop > $null 

}

catch {

connect-MsolService 

}


Write-Host "Session Found Skipping Login..." -ForegroundColor Yellow 


$mf = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement  
$mf.RelyingParty = "*"
$mfa = @($mf)

Clear-Host


Write-Host "1 Enable MFA"
Write-Host "2 Disable MFA"

$rh = read-host "(Enter Option)"


if ($rh -eq "1") {

"Enable MFA:"

$rh2 = read-host "Enter user's email/UPN"

"Enabling MFA for $rh2"

set-msoluser -UserPrincipalName $rh2 -StrongAuthenticationRequirements $mfa

2MFA

}

elseif ($rh -eq "2") {

"Disable MFA:"

$rh3 = read-host "Enter user's email/UPN"

"Disabling MFA for $rh3"

$dmfa = @()

set-msoluser -UserPrincipalName $rh3 -StrongAuthenticationRequirements $dmfa

2MFA

}

}

2MFA