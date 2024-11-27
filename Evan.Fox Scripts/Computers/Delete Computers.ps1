$adCreds = Get-Credential -Message "Enter la credentials with full email address"
#import-module azureadpreview

$path = "C:\Users\evan.fox\Downloads\Remove.txt"

$computerList = Get-ADComputer -Filter * -Searchbase "OU=Disabled Computers,OU=Computers,OU=SEQ,DC=springeq,DC=local"
$computerList

#Use for deleting from a list pulled directly from disabled OU
foreach ($computer in $computerList) {
    Remove-ADObject -Identity (Get-ADComputer $computer).distinguishedname -recursive -Confirm: $false
}


$computerList = Get-Content -Path $path

#use for deleting from a list that wasn't pulled from an AD OU
foreach ($item in $computerList) {
    $name = "SEQ-$item$"
    $check = Get-ADComputer -Filter 'SAMAccountName -eq $name'
    if ($check -eq $null) {
        Write-Warning "$item is not in AD. Moving on"
    } else {
        $item = "SEQ-$item"
        Get-ADComputer -Identity "$item" | Remove-ADObject -Confirm: $false -Recursive -credential $adCreds
        
    }
}