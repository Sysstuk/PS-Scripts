#Pulls all Tableau groups
$tableauGroups = (get-adgroup -filter * -searchbase "OU=Tableau Groups,OU=Groups,OU=SEQ,DC=springeq,DC=local").name

$members = [System.Collections.ArrayList]@()

#specify the path for the report export
$excelPath = "C:\Users\evan.fox\onedrive - spring eq\Desktop\TableauUserGroups.xlsx"
#Prepares the Excel file for writing to it
Export-Excel $excelPath -worksheetname "Groups"
$ExcelPkg = Open-ExcelPackage -Path $excelPath
$workSheet = $excelpkg.Workbook.Worksheets["Groups"]
$workCells = $excelpkg.Workbook.Worksheets["Groups"].Cells

#Populates the Excel sheet with the groups and their members
$row = 2
$column = 1
$groupRow = 1
$groupColumn = 1
foreach ($group in $tableauGroups){
    $workCells[$groupRow,$groupColumn].value = $group
    $groupColumn++
    $members = (get-adgroupmember -identity $group).name
    foreach ($member in $members){
        $workCells[$row,$column].value = $member
        $row++
    }
    $column++
    $row = 2
    $members = [System.Collections.ArrayList]@()
}
Close-ExcelPackage $ExcelPkg