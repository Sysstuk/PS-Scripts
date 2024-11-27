

$userList = get-aduser -Properties name,description -Filter * -searchbase "OU=Partners,OU=Users,OU=SEQ,DC=springeq,DC=local" | select-object name,description

$userList | export-csv -path "C:\Users\evan.fox\OneDrive - Spring EQ\Documents\ContractorNames.csv"




#Full Control
get-mailbox | get-mailboxpermission -user "email"
#Send on Behalf
get-mailbox | where-object {$_.GrantSendOnBehalfTo -match "name"}
#Send as
get-recipientpermission -trustee "First Last"

Connect-ExchangeOnline
get-mailbox | get-mailboxpermission -user "evan.fox@springeq.com"



$ccount = 0
$tcount = 0
$contractors = get-aduser -filter * -SearchBase "OU=Partners,OU=Users,OU=SEQ,DC=springeq,DC=local"
$total = get-aduser -filter * -SearchBase "OU=Users,OU=SEQ,DC=springeq,DC=local"

foreach ($user in $contractors) {
    $ccount++
}
foreach ($user in $total) {
    $tcount++
}
Write-Host "Contractors: $ccount"
Write-Host "Employees: $tcount"
$total = $tcount - $ccount
$total




#Find Contractors who haven't logged on in 3 months
$oldContractor = [System.Collections.ArrayList]@()
$oldContractorblank = [System.Collections.ArrayList]@()
$users = get-aduser -filter * -properties name, lastlogondate, whencreated -SearchBase "OU=Partners,OU=Users,OU=SEQ,DC=springeq,DC=local"
$today = Get-Date
#$users.lastlogondate
foreach ($obj in $users) { 
    if ((($obj).lastlogondate) -le (($today).AddDays(-90)) -and ((($obj).lastlogondate) -ne $null)) {
       $oldContractor.add($obj)
    }
    if ((($obj).lastlogondate) -eq $null) {
        $oldContractorblank.add($obj)
    }
}
$oldContractor | export-csv -path "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\contractorlogins.csv"
$oldContractorblank | export-csv -path "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\contractorloginsblank.csv"
get-aduser evan.fox -properties lastlogondate




#Get members of a DDL
Connect-AzureAD
Connect-ExchangeOnline
$members = get-dynamicdistributiongroupmember -identity "DL - Team Henderson (Loan Wolves)"
$members

get-dynamicdistributiongroup -identity "DL - Team Henderson (Loan Wolves)" | fl
get-dynamicdistributiongroup -identity "DL - Internal Staff" | fl

(get-aduser -filter "Manager -eq 'bhenderson'").name
Connect-ExchangeOnline
(get-dynamicdistributiongroupmember -identity "DL - Conshohocken - Internal").displayname



#pull members of a shared mailbox and output them to a txt file
Connect-ExchangeOnline
$users = get-mailboxpermission -identity "txclosings@springeq.com" | select-object user -expandproperty user | where {($_.User -like '*@*')} 
$user2 = [System.Collections.ArrayList]@()
$users
foreach ($user in $users) {
    $user2.add((get-mailbox -identity "$user").displayname)
}
$user2

$user2 | out-file -filepath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\txclosings.txt"




#set shared mailbox to keep sent emails in the sent folder
Connect-ExchangeOnline
set-mailbox "retailtitle@springeq.com" -messagecopyforsentasenabled $true
set-mailbox "retailtitle@springeq.com" -messagecopyforsendonbehalfenabled $true



#Get UserIDs from list of user actual names
Connect-AzureAD
$BrivoUsers = [System.Collections.ArrayList]@()
$BrivoIDs = [System.Collections.ArrayList]@()
$fail = [System.Collections.ArrayList]@()
$BrivoUsers = Get-Content -Path "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\Brivo.txt"
foreach ($User in $BrivoUsers) {
    $AADObj = Get-AzureADUser -Filter "DisplayName eq '$User'"
    $AADID = (Get-AzureADUser -Filter "DisplayName eq '$User'").ObjectID
    $BrivoIDs.add("$User - $aadid") 
}
$BrivoIDs | Out-File -filepath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\BrivoIDs.txt"


Connect-MgGraph -scopes 'Directory.Read.All'
get-mgcontext
Get-Module


$cred = Get-Credential
$temps = (get-aduser -Filter * -searchbase "OU=Partners,OU=Users,OU=SEQ,DC=springeq,DC=local" -Credential $cred).count
$all = (get-aduser -filter * -searchbase "OU=Users,OU=SEQ,DC=springeq,DC=local" -Credential $cred).count
$users = $all - $temps
Write-Host "Total Users: $all"
Write-Host "Temps: $temps"
Write-Host "Regular Users: $users"

install-module -name az -repository psgallery -force
import-module az
connect-azaccount
get-azaduser -displayname "Evan Fox" -properties *




Connect-AzureAD
$Underwriters = Get-AzureADGroupMember -ObjectID "de9bc63c-41f4-4b88-91cf-42b735cc99f8"
$DA = Get-AzureADGroupMember -ObjectID "68cc9251-a5ac-435e-92af-161325a1b51f"
$AA = Get-AzureADGroupMember -ObjectID "e6df8e40-ffd6-40d8-bf15-c95585e04dc4"
$PC = Get-AzureADGroupMember -ObjectID "40b2259f-1ea8-4cd9-8c06-760c87fdc8f9"

$underwriters

$Underwriters.displayname | out-file -filepath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\underwriters.txt"
$DA.displayname | out-file -filepath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\da.txt"
$AA.displayname | out-file -filepath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\aa.txt"
$PC.displayname | out-file -filepath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\pc.txt"

$contractors = get-aduser -filter * -searchbase "OU=Partners,OU=Users,OU=SEQ,DC=springeq,DC=local"
$contractors
$contractors.name | out-file -filepath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\contractors1120.txt"

#control whether accounts can tie to new Outlook
connect-exchangeonline
Set-CASMailbox -Identity evan.fox@springeq.com -OneWinNativeOutlookEnabled $true
Get-CASMailbox -Identity dfarber@springeq.com | Format-List Name,OneWinNativeOutlookEnabled




#NetCease Test
Install-Module -Name NetCease -force -confirm:$false -scope CurrentUser
Set-NetSessionEnumPermission



get-aduser -filter "Department -eq 'Technology'" | Format-Table Name


get-aduser -identity ihernandez -property title
get-aduser -identity rilagan -property title

$users = get-content -path "C:\Users\evan.fox\Desktop\test.txt"
foreach($user in $users){
    if((get-aduser -filter "name -like '$user'").enabled -eq $true){
        #Write-Host "$user is active"
    }elseif((get-aduser -filter "name -like '$user'").enabled -eq $false){
        Write-Host "$user is not active"
    }else{
        Write-Host "$user does not exist"
    }
}



connect-azuread
$members = [System.Collections.ArrayList]@()
#$truelist = [System.Collections.ArrayList]@()
$users = (get-aduser -filter {(enabled -eq $true) -and (department -ne "Technology") -and (description -ne "test account")} -properties displayname).displayname
$licensed = (Get-AzureADGroupMember -ObjectID "9c31a721-cfcc-4e32-b8df-aaf2a0d3cd3c" -all $true).userprincipalname

foreach ($license in $licensed){
    #$members.add($license.displayname)
    $members.add((get-azureaduser -objectID "$license").displayname)
}
$members | out-file "C:\Users\evan.fox\desktop\O365E5.txt"
$users | out-file "C:\Users\evan.fox\desktop\ad.txt"






$path = "\\springeq.local\dfs\office\IT\Script Logs"
$tester = "*evan.fox*"
$list = Get-ChildItem -path $path -recurse | get-acl
foreach ($item in $list) {
    if ($item.access.identityreference.value -like $tester){
        Write-Host $item.Path
    }
}

$path = "\\springeq.local\dfs\management\human resources\emergency contacts"
$tester = "*FS-Human-Resources-Commission-Plans-Write*"
$list = Get-ChildItem -path $path | get-acl
$list
foreach ($item in $list) {
    if ($item.access.identityreference.value -like $tester){
        Write-Host $item.Path
    }
}

(Get-ADGroupMember -identity "AWS Workspaces MFA").name | out-file -filepath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\AWS MFA.txt"
(Get-ADGroupMember -identity AWS_DataWarehouse_UAT_Read).name | out-file -filepath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\DW Users.txt"

Get-ADUser -filter '(Enabled -eq "True") -and Department -like "Sales - 2nd Mortgages"' -properties Department,Description  | select-object Name,Description,Department


#Remove direct license assignment
connect-mggraph
$users = get-mguser -filter "accountEnabled eq true" -all




(get-aduser -filter "Department -eq 'Technology'" -Properties displayname).displayname | out-file -FilePath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\TechnologyUsers.txt"


get-aduser -identity evan.fox -properties *

$ou = "OU=Disabled Partners,OU=Disabled Users,OU=SEQ,DC=springeq,DC=local"
$contractors = get-aduser -filter 'Description -like "*Visionet*"' -searchbase $ou
$contractors
Add-AdGroupMember -Identity "Visionet Base Group" -Members $contractors
$contractors | set-aduser -Replace @{Description = "Visionet Contractor"}
$contractors | set-aduser -Replace @{Title = "Visionet Contractor"}

$date = [datetime]"3/15/24"
Get-ADObject -Filter '(whenChanged -gt $Date) -and (SamAccountName -eq "cjames")' -Properties *| select Name, sAMAccountName, whenChanged, whenCreated | Format-Table -AutoSize
Get-Eventlog -Log Security -After $Date -Newest 10| Where {$_.EventID -eq 4726}



Connect-ExchangeOnline
$test = ((get-mailboxstatistics -identity 'kevin.mcgrath@springeq.com').TotalItemSize.Value).tostring()
if($test -like "*GB*"){
    $test = $test.Split(' ')
    if($test[0] -gt "48"){
        Write-Host "True"
    }
}



$packages = @("*3d*","*maps*","*mixedreality*","*phone*","*skype*","*solitaire*","*windowscommunicationsapps*",
"Microsoft.XboxIdentityProvider","Microsoft.BingTravel","Microsoft.BingHealthAndFitness","Microsoft.BingFoodAndDrink",
"Microsoft.XboxApp","Microsoft.BingSports","Microsoft.WindowsPhone","*zune*","*OutlookForWindows*","Microsoft.XboxGamingOverlay","Microsoft.XboxGameOverlay","Microsoft.XboxSpeechToTextOverlay","Microsoft.XboxTCUI")

foreach ($package in $packages) {
    if ($null -ne (get-appxpackage $package)) {
        write-host "$package Detected"
        exit 1
    } else 
        {write-host "Bloatware $package NOT Detected"}
}
exit 0



(get-aduser -filter 'enabled -eq $true' -property manager | where-object {$_.manager -like "*aubrie nooney*"}).name



