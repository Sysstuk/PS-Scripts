try {
	remove-item "C:\Program Files\Microsoft Office\root\Office16\lync.exe"
	remove-item "C:\Program Files\Microsoft Office\root\Office16\lync99.exe"
	remove-item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Skype for Business.lnk"
	remove-item "C:\Program Files\Microsoft Office\root\Office16\ocpubmgr.exe"
	remove-item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office Tools\Skype for Business Recording Manager.lnk"
}
catch {
	Write-Error "Error removing Skype for Business from machine"
}