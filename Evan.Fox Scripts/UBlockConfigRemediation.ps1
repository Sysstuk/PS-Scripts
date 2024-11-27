$path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\Extensions\odfafepnkmbhccpbejgmiehpchacaeak\policy"

$path2 = "HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\cjpalhdlnbpafiamejdnhcphjbkeiagm\policy"

$valueName = "disabledPopupPanelParts"
$requiredValue = '["globalStats","basicTools","extraTools","overviewPane"]'

if((Test-Path -Path $path) -ne $true) {  
    New-Item  $Path -force
    if((Get-ItemProperty -Path $path | Select-Object -ExpandProperty $valueName) -ne $requiredValue) {
        New-ItemProperty -Path $path -Name disabledPopupPanelParts -Value '["globalStats","basicTools","extraTools","overviewPane"]'  -PropertyType String    
    }
}

if((Test-Path -Path $path2) -ne $true) {
    New-Item  $Path2 -force
    if((Get-ItemProperty -Path $path2 | Select-Object -ExpandProperty $valueName) -ne $requiredValue) {
        New-ItemProperty -Path $path2 -Name disabledPopupPanelParts -Value '["globalStats","basicTools","extraTools","overviewPane"]'  -PropertyType String    
    }
}