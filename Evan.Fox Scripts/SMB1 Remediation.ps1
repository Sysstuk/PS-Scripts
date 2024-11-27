try {
	Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -norestart
} 
catch {
	Write-Error "Error disabling SMB1 on machine"
}