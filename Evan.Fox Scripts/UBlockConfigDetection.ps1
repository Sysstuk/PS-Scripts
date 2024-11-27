$path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\Extensions\odfafepnkmbhccpbejgmiehpchacaeak\policy"

$path2 = "HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\cjpalhdlnbpafiamejdnhcphjbkeiagm\policy"

$valueName = "disabledPopupPanelParts"
$requiredValue = '["globalStats","basicTools","extraTools","overviewPane"]'

if ((Test-Path -Path $path) -and (Test-Path -Path $path2)) {
    if ((get-itemproperty -path $path -Name disabledPopupPanelParts) -and (get-itemproperty -path $path2 -Name disabledPopupPanelParts)) {
        $currentValue = Get-ItemProperty -Path $path | Select-Object -ExpandProperty $valueName
        $currentValue2 = Get-ItemProperty -Path $path2 | Select-Object -ExpandProperty $valueName
        if (($currentValue -eq $requiredValue) -and ($currentValue2 -eq $requiredValue)) {
            exit 0
        }
    }
}
else {exit 1}