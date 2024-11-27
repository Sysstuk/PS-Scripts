if ((Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol).state -ne "Disabled") {
	exit 1
}
else { exit 0}