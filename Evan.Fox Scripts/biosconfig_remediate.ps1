$enableList = "ThinkPad E15","ThinkPad E15 Gen 2","ThinkPad E15 Gen 3"
$internalList = "ThinkPad E15 Gen 4","ThinkPad E16 Gen 1"
$computerInfo = (get-computerinfo -property cssystemfamily).cssystemfamily

$path = "C:\bios.csv"

install-packageprovider -name nuget -minimumversion 2.8.5.201 -force
install-module getbios -force
install-module setbios -force

import-module getbios
import-module setbios

$bios = get-bios | select-object setting,value

if($enableList -contains $computerInfo){
	foreach($item in $bios) {
		if ($item.setting -like "MACAddressPassThrough"){
			if ($item.value -ne "Enable"){
				$item.value = "Enable"
			}
		}
		if ($item.setting -like "SecureBoot"){
			if($item.value -ne "Enable"){
				$item.value = "Enable"
			}
		}
	}
}

if($internalList -contains $computerInfo){
	foreach($item in $bios) {
		if ($item.setting -like "MACAddressPassThrough"){
			if ($item.value -ne "Internal"){
				$item.value = "Internal"
			}
		}
		if ($item.setting -like "SecureBoot"){
			if($item.value -ne "Enable"){
				$item.value = "Enable"
			}
		}
	}
}


$bios | export-csv -path $path
set-bios -csv $path

remove-item -Path $path

