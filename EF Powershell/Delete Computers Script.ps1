$adCreds = Get-Credential -Message "Enter la credentials with full email address"
#import-module azureadpreview

$path = "C:\Users\evan.fox\Downloads\Remove.txt"

$computerList = Get-Content -Path $path
$computerList

foreach ($item in $computerList) {
    $name = "SEQ-$item$"
    $check = Get-ADComputer -Filter 'SAMAccountName -eq $name'
    if ($check -eq $null) {
        Write-Warning "$item is not in AD. Moving on"
    } else {
        $item = "SEQ-$item"
        Get-ADComputer -Identity "$item" | Remove-ADObject -Confirm: $false -Recursive -credential $adCreds
        
    }
    #$objID = (Get-AzureADDevice -SearchString "$item").objID
}



Get-ADComputer -Identity SEQ-E01955 | Remove-ADComputer -Confirm: $false

Remove-ADObject -Identity (Get-ADComputer -Identity SEQ-E01955).distinguishedname -credential $adCreds -recursive