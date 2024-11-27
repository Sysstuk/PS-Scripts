$adCreds = Get-Credential -Message "Enter la credentials with full email address"
import-module azureadpreview

try{
    Get-AzureADCurrentSessionInfo -ErrorAction Stop > $null
} catch {
    Connect-AzureAD
}

#This is the file that the list of computers will be pulled from
$path = "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\Checked Out Computers.xlsx"

$finalList = [System.Collections.ArrayList]@() #List that will be acted upon after the date is filtered for blank spaces, etc
$logSuccess = [System.Collections.ArrayList]@() #List of items successfully acted upon
$logFail = [System.Collections.ArrayList]@() #List of items failed to act upon

#Change the number for ImportColumns to the Column you need (1 = A) and change the OutVariable value to what you want it called
#Imports and cleans up data from specified column
Import-Excel -Path $path -ImportColumns @(9) -HeaderName "name" -OutVariable compNames
$compNames.Count
for ($a=1;$a -lt $compNames.count;$a++) {
    if(($compNames[$a].name) -ne $null) {
        #Write-Host $item.toString()
        $finalList.add($compNames[$a])
    }
}

$testDate = (get-date).addyears(-1) #Get the date for one year back from the day this is run

#Checks if the last logon was within the past year and disables the computer object if it fails the test. Catches fails and sorts successes and failures into log lists
foreach ($item in $finalList){
    $test = $item.name
    try {
        $comp = get-adcomputer -identity $test
        if((get-adcomputer $test -properties lastlogondate).lastlogondate -lt $testDate) {
            Disable-AdAccount -identity $comp 
            Write-Host "$test Disabled"
        }
    } catch {
        Write-Host "Object doesn't exist in AD or is already disabled"
        Write-Host $_.ScriptStackTrace
    }
}

foreach ($item in $finalList){
    $test = $item.name
    $comp = get-adcomputer -identity $test
    if((get-adcomputer $test -properties enabled).enabled -eq $false) {
        $logSuccess.add($item.name)
        Write-Host "$test Disabled"    
    } else {
        Write-Host "Object active"
        $logFail.add($item.name)
    }
}

$logFail.count
$logSuccess.count

$logfail
$logsuccess[6]

$ExcelPkg = Open-ExcelPackage -Path $path
$workSheet = $excelpkg.Workbook.Worksheets["test3"]
$workCells = $excelpkg.Workbook.Worksheets["test3"].Cells

$a=2
foreach($item in $logSuccess){
    $workCells[$a,11].value = $item
    $a++
}
$a=2
foreach($item in $logFail){
    $workCells[$a,12].value = $item
    $a++
}

$end1=($logSuccess.Count)+1
$end2=($logFail.Count)+1

Add-ExcelTable -Range $workSheet.cells["K1:K$end1"] -TableName "Disabled (Over 1yr Last Login)" -TableStyle Medium14
Add-ExcelTable -Range $workSheet.cells["L1:L$end2"] -TableName "Not Disabled (Under 1yr Last Login)" -TableStyle Medium12

Close-ExcelPackage $excelpkg