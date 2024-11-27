#Pulls a list of users for each specified license
Connect-MgGraph
$licenses = [System.Collections.ArrayList]@()
$skus = [System.Collections.ArrayList]@()
$users = [System.Collections.ArrayList]@()

$users = get-mguser -filter "accountEnabled eq true" -all

$licenses = Get-MgSubscribedSku | Where-Object {$_.CapabilityStatus -eq "Enabled"}
$licenses

$sku = foreach ($license in $licenses){
    Get-mgsubscribedsku | Select-Object skupartnumber
}

$excelPath = "C:\Users\evan.fox\onedrive - spring eq\Desktop\LicenseAudit.xlsx"
Export-Excel $excelPath -worksheetname "LicenseAudit"
$ExcelPkg = Open-ExcelPackage -Path $excelPath
$workSheet = $excelpkg.Workbook.Worksheets["LicenseAudit"]
$workCells = $excelpkg.Workbook.Worksheets["LicenseAudit"].Cells

$row = 1
$column = 1
$userRow = 2
foreach ($license in $licenses) {
    $workCells[$licenseRow,$licenseColumn].value = $license
}  
    foreach ($user in $users){
        if (((get-mguserlicensedetail -userid ($user).id).skupartnumber) -contains $license){
            $workCells[$userRow,$licenseColumn].value = $distro
        $userRow++
        }
    }
    $userRow = 2
    $licenseColumn++

Close-ExcelPackage $ExcelPkg







