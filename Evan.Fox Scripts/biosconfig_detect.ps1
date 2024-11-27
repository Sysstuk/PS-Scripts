install-packageprovider -name nuget -minimumversion 2.8.5.201 -force
install-module getbios -force
install-module setbios -force

import-module getbios
import-module setbios

$bios = get-bios | select-object setting,value

foreach($item in $bios) {
	if ($item.setting -like "MACAddressPassThrough"){
		if ($item.value -eq "Disable"){
			exit 1
		}
	}
	if ($item.setting -like "SecureBoot"){
		if($item.value -ne "Enable"){
			exit 1
		}
	}
}
exit 0