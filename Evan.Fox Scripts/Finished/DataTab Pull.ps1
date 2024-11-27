$AWS = "AWS_Datamart*"
#$Tableau = "Tableau*"
$date = Get-Date -Format "MM-dd-yy"
$path = "\\springeq.local\dfs\office\Platform\Data Team\Data Team (NEW)\ADMapping\Datamart Groups Report $date.xlsx"
Export-Excel $path -worksheetname "Info"
$awsGroups = (get-adgroup -filter {name -like $AWS}).name
#$tableauGroups = (get-adgroup -filter {name -like $Tableau}).name

#$AWSfinal = [System.Collections.ArrayList]@()
#$Tableaufinal = [System.Collections.ArrayList]@()

$awsGroups
#$tableauGroups

$ExcelPkg = Open-ExcelPackage -Path $path
$workSheet = $excelpkg.Workbook.Worksheets["Info"]
$workCells = $excelpkg.Workbook.Worksheets["Info"].Cells

$a=2
$b=1
foreach ($group in $awsGroups){
    $group
    $workCells[1,$b].value = $group
    $awsColumns = (Get-ADGroupMember -Identity $group).objectguid

    foreach ($member in $awsColumns) {
        if (((Get-ADObject -Identity $member).objectClass -eq "user") -and (Get-ADUser -identity $member).enabled -eq $true) {
            $workCells[$a,$b].value = (get-aduser -identity $member).name
            $a++
        }
        elseif ((Get-ADObject -Identity $member).objectClass -eq "group") {
            $nestGroup = (Get-ADGroupMember -Identity $member).objectguid
            foreach ($user in $nestGroup) {
                if((Get-ADUser -identity $user).enabled -eq $true){
                    $workCells[$a,$b].value = (get-aduser -identity $user).name
                    $a++
                }
            }
        }
    }
    $b++
    $a=2
}

#$a=2
#$b=12
#foreach ($group in $tableauGroups){
#    $group
#    $workCells[1,$b].value = $group
#    $tableauColumns = (Get-ADGroupMember -Identity $group).objectguid
#
#    foreach ($member in $tableauColumns) {
#        if (((Get-ADObject -Identity $member).objectClass -eq "user") -and (Get-ADUser -identity $member).enabled -eq $true) {
#            $workCells[$a,$b].value = (get-aduser -identity $member).name
#            $a++
#        }
#        elseif ((Get-ADObject -Identity $member).objectClass -eq "group") {
#            $nestGroup = (Get-ADGroupMember -Identity $member).objectguid
#            foreach ($user in $nestGroup) {
#                if((Get-ADUser -identity $user).enabled -eq $true){
#                    $workCells[$a,$b].value = (get-aduser -identity $user).name
#                    $a++
#                }
#            }
#        }
#    }
#    $b++
#    $a=2
#}

Close-ExcelPackage $excelpkg