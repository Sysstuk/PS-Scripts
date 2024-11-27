if($true -eq (test-path "C:\Program Files\Microsoft Office\root\Office16\lync.exe")) {
	exit 1
}
else {
	exit 0
}