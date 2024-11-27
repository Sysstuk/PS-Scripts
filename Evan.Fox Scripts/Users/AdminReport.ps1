Connect-MgGraph

$today = Get-Date -format "MM-dd-yy"

$excelPath = "\\springeq.local\DFS\office\IT\Script Logs\Admin Reports\Admin Report $today.xlsx"
#$excelPath = "C:\Users\evan.fox\onedrive - spring eq\Desktop\Admin Report $today.xlsx"


Export-Excel $excelPath -worksheetname "AAD Roles"
Export-Excel $excelPath -worksheetname "AD Admins"
$ExcelPkg = Open-ExcelPackage -Path $excelPath
$workSheet = $excelpkg.Workbook.Worksheets["AAD Roles"]
$workCells = $excelpkg.Workbook.Worksheets["AAD Roles"].Cells

$roles = get-mgdirectoryrole
$roles.displayname

$row = 2
$column = 1
$groupRow = 1
$groupColumn = 1

foreach ($role in $roles) {
    $groupName = $role.displayname
    $workCells[$groupRow,$groupColumn].value = $groupname
    $groupColumn++

    $userIDs = (get-mgdirectoryrolemember -directoryroleid $role.id).id
    foreach ($id in $userIDs) {
        $name = (get-mguser -userid $id).displayname
        $workCells[$row,$column].value = $name
        $row++
    }
    $column++
    $row = 2
}

$workSheet = $excelpkg.Workbook.Worksheets["AD Admins"]
$workCells = $excelpkg.Workbook.Worksheets["AD Admins"].Cells

$row = 2
$column = 1
$groupRow = 1
$groupColumn = 1

$BIGroups = get-adgroup -filter * -searchbase "CN=Builtin,DC=springeq,DC=local"
$adminGroups = get-adgroup -filter 'groupcategory -eq "Security" -and groupscope -eq "Global" -and Name -like "*Admin*"' -searchbase "OU=Security Delegation,OU=SEQ,DC=springeq,DC=local" 


foreach ($group in $BIGroups) {
    $groupName = $group.name
    $workCells[$groupRow,$groupColumn].value = $groupname
    $groupColumn++

    $users = (get-adgroupmember -identity $group)
    foreach ($user in $users) {
        if ($user.Name -eq "Domain Users"){
            $workCells[$row,$column].value = $user.name
            $row++
        }
        elseif($user.objectclass -eq "group"){
            $tempGroup = get-adgroupmember $user.name
            foreach ($user in $tempgroup) {
                if ($user.enabled -eq $false){
                    $workCells[$row,$column].value = "$($user.name) Disabled"
                    $row++
                }
                else{
                    $workCells[$row,$column].value = $user.name
                    $row++
                }
            }
        }
        else{
            if ($user.enabled -eq $false){
                $workCells[$row,$column].value = "$($user.name) Disabled"
                $row++
            }
            else{
                $workCells[$row,$column].value = $user.name
                $row++
            }
        }
    }
    $column++
    $row = 2
}

foreach ($group in $adminGroups) {
    $groupName = $group.name
    $workCells[$groupRow,$groupColumn].value = $groupname
    $groupColumn++

    $users = (get-adgroupmember -identity $group)
    foreach ($user in $users) {
        $workCells[$row,$column].value = $user.name
        $row++
    }
    $column++
    $row = 2
}
Close-ExcelPackage $ExcelPkg