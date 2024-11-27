$exportList = [System.Collections.ArrayList]@()

$xlPath = "\\springeq.local\dfs\Office\IT\scripts\Visionet Reports\"

$newfile = get-childitem $xlPath | where-object {$_.name -like "*.xlsx"} | Sort-Object -Property LastWriteTime -Descending | select-object -Index 0
$oldfile = get-childitem $xlPath | where-object {$_.name -like "*.xlsx"} | Sort-Object -Property LastWriteTime -Descending | select-object -Index 1

$exportPath = [Environment]::GetFolderPath("Desktop") + "\BlueSage Change.txt"

$newcontractors = Import-Excel ($xlpath + $newfile)
$oldcontractors = Import-Excel ($xlPath + $oldfile)

$newcontractors[60]

foreach($ncontractor in $newcontractors){
    $name = $ncontractor.name
    $test = $oldcontractors | where-object {$_.Name -eq $name}
    if($test -eq $null){
        $exportlist += $ncontractor
    }
    elseif(($ncontractor.'user role in bluesage') -ne ($test.'user role in bluesage')) {
        $exportlist += $ncontractor
    }
    elseif(($ncontractor.'user status') -ne ($test.'user status')) {
        $exportlist += $ncontractor
    }
}

$roleCheck = @('Post Closer','Application Analyst','Disclosure Analyst')

foreach ($contractor in $newcontractors) {
    $email = $contractor.'seq email id'
    $user = get-aduser -filter {userprincipalname -eq $email} -properties MemberOf
    if(($contractor.'user status') -ne "Active"){
        $user | disable-adaccount
        $exportlist += "$($user.Name) Disabled"
    }
    elseif((($contractor).'user role in bluesage') -like "Underwriter") {
        if($user.memberof -notcontains "CN=Visionet Group - Underwriters,OU=Visionet Groups,OU=Groups,OU=SEQ,DC=springeq,DC=local"){
            add-adgroupmember -identity 'Visionet - Underwriters' -Members $user -Confirm:$false
            $exportList += "$($user.name) added to Underwriters"

        }
    }
    if((($contractor).'user role in bluesage') -in $rolecheck){
        if(($user.memberof) -contains "CN=Visionet Group - Underwriters,OU=Visionet Groups,OU=Groups,OU=SEQ,DC=springeq,DC=local"){
            remove-adgroupmember -identity 'Visionet - Underwriters' -Members $user -Confirm:$false
            $exportList += "$($user.name) removed from Underwriters"
        }
    }
}

$exportList | out-file -filepath $exportpath
