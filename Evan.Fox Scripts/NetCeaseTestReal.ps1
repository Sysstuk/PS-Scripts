Save-Module -Name NetCease -Repository PSGallery -Path C:\Users\Public
Import-Module C:\Users\Public\NetCease\1.0.3\NetCease.psd1 -Force -Verbose

$test = Get-NetSessionEnumPermission
if((($test).accessmask[0]) -ne 2032127) {
	Set-NetSessionEnumPermission -Confirm:$false
	Remove-Item C:\Users\Public\NetCease -recurse -force
	Exit
}
else {
	Remove-Item C:\Users\Public\NetCease -recurse -force
	Exit
}


