$userList = get-aduser -filter * -properties *

foreach ($user in $userList) {
    set-aduser $user -state $null
    set-aduser $user -remove @{physicaldeliveryofficename = "Cira Centre"}
}

$userList = (get-aduser -filter * -searchbase "OU=Disabled Users, OU=SEQ, DC=springeq, DC=local")
foreach ($user in $userList) {
    set-aduser $user -replace @{msexchhidefromaddresslists=$true}
}

set-aduser daniel.degrande -remove @{extensionattribute1="Internal"}

get-aduser ctd -properties *
set-aduser ctd -replace @{extensionattribute1="Internal"}

$users | set-aduser -clear extensionattribute1,extensionattribute2,extensionattribute3,extensionattribute4

get-aduser -filter "extensionattribute3 -eq 'OH'" -Properties extensionattribute3 | Select-Object name