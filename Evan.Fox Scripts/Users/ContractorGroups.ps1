$underwriters = [System.Collections.ArrayList]@()
$postClosers = [System.Collections.ArrayList]@()
$disclosureAnalysts = [System.Collections.ArrayList]@()
$applicationAnalysts = [System.Collections.ArrayList]@()

$underwriters = (get-adgroupmember -identity "Visionet - Underwriters").name
$postClosers = (get-adgroupmember "visionet group - post closers").name
$disclosureAnalysts = (get-adgroupmember "visionet group - disclosure analyst").name
$applicationAnalysts = (get-adgroupmember "visionet - app analysts").name

$disclosureAnalysts

$groups = "Underwriter","Post Closer","Disclosure Analyst","Application Analyst"

$excelPath = "C:\Users\evan.fox\onedrive - spring eq\Desktop\VisionetUserGroups.xlsx"
Export-Excel $excelPath -worksheetname "Groups"
$ExcelPkg = Open-ExcelPackage -Path $excelPath
$workSheet = $excelpkg.Workbook.Worksheets["Groups"]
$workCells = $excelpkg.Workbook.Worksheets["Groups"].Cells

$row = 2
$column = 1
$groupRow = 1
$groupColumn = 1
foreach ($group in $groups) {
    $workCells[$groupRow,$groupColumn].value = $group
    $groupColumn++
}
foreach ($underwriter in $underwriters) {
    $workCells[$row,$column].value = $underwriter
    $row++
}
$row = 2
$column++
foreach ($postcloser in $postClosers) {
    $workCells[$row,$column].value = $postcloser
    $row++
}
$row = 2
$column++
foreach ($disclosureanalyst in $disclosureAnalysts) {
    $workCells[$row,$column].value = $disclosureanalyst
    $row++
}
$row = 2
$column++
foreach ($applicationanalyst in $applicationAnalysts) {
    $workCells[$row,$column].value = $applicationanalyst
    $row++
}
Close-ExcelPackage $ExcelPkg