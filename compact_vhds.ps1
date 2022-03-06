# before running, execute Set-ExecutionPolicy RemoteSigned so that your PowerShell will allow it to run
$DISTROS = @('Debian','Ubuntu','Kali', 'SUSE')
$PACKAGESDIR = $Env:LOCALAPPDATA+"\Packages"

do {
	$CONTINUEPROMPT = Read-Host -NoNewLine "WARNING! This script will terminate all running WSL2 virtual machines.  Continue? [y/n]"
	if(($CONTINUEPROMPT -eq "N") -or ($CONTINUEPROMPT -eq "n")) {
		exit
	}
	if(($CONTINUEPROMPT -eq "Y") -or ($CONTINUEPROMPT -eq "y")) {
		break
	}
} while (($CONTINUEPROMPT -ne "N") -or ($CONTINUEPROMPT -ne "n") -or ($CONTINUEPROMPT -ne "Y") -or ($CONTINUEPROMPT -ne "y"))

#shut down the WSL2 core
Write-Host "Shutting down the WSL2 core..."
wsl --shutdown

foreach ($DISTRO in $DISTROS) {
	Write-Host "Currently looking for distribution: "$DISTRO
	#Set up a command to search for the installed package name of the distrubtion"
	$DIRLISTCMD = "dir -Name "+$PACKAGESDIR+"\*"+$DISTRO+"*"
		
	$DISTRODIRS = Invoke-Expression -Command $DIRLISTCMD
	if(!$DISTRODIRS) {
		Write-Host "No installed distributions for "$DISTRO
	} else {
		Write-Host "Distrubtion located at "$PACKAGESDIR"\"$DISTRODIRS
		Write-Host "Starting distribution virtual disk compaction..."
		
$DISKPARTCMD = @"
select vdisk file="$PACKAGESDIR\$DISTRODIRS\LocalState\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
"@
	
	$DISKPARTCMD | diskpart
	}	
}

