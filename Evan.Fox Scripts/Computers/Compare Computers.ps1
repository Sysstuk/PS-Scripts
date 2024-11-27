Import-Excel -path "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\Computer Logons.xlsx" -ImportColumns @(1) -outvariable adName 
Import-Excel -path "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\Computer Logons.xlsx" -ImportColumns @(5) -endrow 356 -outvariable checkedOut
$remove = [System.Collections.ArrayList]@()
$keep = [system.collections.arraylist]@()
$other = [system.collections.arraylist]@()
$added = $null

foreach ($item in $adName) {
    $test = $item.name
    foreach ($comp in $checkedOut) {
        $test2 = $comp."Asset Tag ID"
        if ($test.contains($test2)) {
            $keep.add($item)
            $added = $true
        }
    }
    if ($added -ne $true) {
        $remove.Add($item)
    }
    $added = $null
}

foreach ($comp in $checkedOut) {
    $test = $comp."Asset Tag ID"
    foreach ($item in $adName) {
        $test2 = $item.name
        if ($test2.contains($test)) {
            $added=$true
        }
    }
    if($added -ne $true){
        $other.add($comp)
    }
    $added=$null
}

$path = 'C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\Computer Logons.xlsx'

#$keep | export-excel -path "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\Computer logons.xlsx" -Append -TableName "GoodComputers" -TableStyle Medium10 -StartColumn 9 -StartRow 1 -WorksheetName "test3" -NoNumberConversion *
$ExcelPkg = Open-ExcelPackage -Path $path
$workSheet = $excelpkg.Workbook.Worksheets["test3"]
$workCells = $excelpkg.Workbook.Worksheets["test3"].Cells

$a=2
foreach($item in $keep){
    $workCells[$a,7].value = $item.name
    $a++
}
$a=2
foreach($item in $other){
    $workCells[$a,8].value = $item."Asset Tag ID"
    $a++
}
$a=2
foreach($item in $remove){
    $workCells[$a,9].value = $item.name
    $a++
}
$end1=($keep.Count)+1
$end2=($other.Count)+1
$end3=($remove.Count)+1

Add-ExcelTable -Range $workSheet.cells["G1:G$end1"] -TableName "ADCheckedOut" -TableStyle Medium14
Add-ExcelTable -Range $workSheet.cells["H1:H$end2"] -TableName "CheckedOutNoAD" -TableStyle Medium12
Add-ExcelTable -Range $workSheet.cells["I1:I$end3"] -TableName "ADNotCheckedOut" -TableStyle Medium10

Close-ExcelPackage $excelpkg