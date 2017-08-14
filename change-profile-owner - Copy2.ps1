<#
.SYNOPSIS
   Takes ownership and sets permissions for user directories
.DESCRIPTION
   Uses the NTFSSecurity modual to set the permissions on directories
.PARAMETER <paramName>
   Requires the users samAccountName
.EXAMPLE
  PS C:\scripts\PS1\change-owner.ps1
   Type Sam Account name of user eg: cheryl.bach
.NOTES   

NMIProfiles Permissions

Account                             Access Rights  Applies to                Type            IsInherited
-------                             -------------  ----------                ----            -----------
CREATOR OWNER                       FullControl    SubfoldersAndFilesOnly    Allow           False
NT AUTHORITY\Authenticated Users    FullControl    ThisFolderSubfoldersAn... Allow           False                         
NT AUTHORITY\SYSTEM                 FullControl    ThisFolderSubfoldersAn... Allow           False                         
BUILTIN\Administrators              FullControl    ThisFolderSubfoldersAn... Allow           False                         

NMIProfiles\$Users Permissions

Account                             Access Rights   Applies to                Type            IsInherited     InheritedFrom 
-------                             -------------   ----------                ----            -----------     ------------- 
NT AUTHORITY\SYSTEM                 FullControl     ThisFolderSubfoldersAn... Allow           False                         
BUILTIN\Administrators              FullControl     ThisFolderSubfoldersAn... Allow           False                         
NMI\mfadmin                         FullControl     ThisFolderSubfoldersAn... Allow           False     

#>
   
#If (!(Test-path "X:\NMIProfiles")) { net use X: \\nmi.local\files }

$User = Read-host "gdadmin"

cd "X:\NMIProfiles\$User.NMI.V2"

$a = gci "X:\NMIProfiles\$User.NMI.V2"

foreach ($i in $a)			
{
    if(test-path $i)
  {
        write-host "Taking ownership of Directory $i" -fore Green 
        get-item $i | Set-NTFSowner -Account 'NMI.LOCAL\Domain Admins'
        get-item $i | Add-NTFSAccess -account 'Creator Owner' -AccessRights FullControl
		get-item $i | Add-NTFSAccess -account 'BUILTIN\Administrators' -AccessRights FullControl
        get-item $i | Add-NTFSAccess -Account 'NT AUTHORITY\System' -AccessRights FullControl
        get-item $i | Add-NTFSAccess -Account "NMI\$User" -AccessRights FullControl
 
        $items = @()
        $items = $null
        $path = $null
        $items = get-childitem $i -recurse -force
        foreach($item in $items)
            {
                $path = $item.FullName
                Write-Host "...Adding Permissions to $path" -Fore Green
                Get-item -force $path | Add-NTFSAccess -account 'Creator Owner' -AccessRights FullControl
				Get-Item -force $path | Add-NTFSAccess -Account 'BUILTIN\Administrators' -AccessRights FullControl
				Get-Item -force $path | Add-NTFSAccess -Account 'NT AUTHORITY\System' -AccessRights FullControl
				Get-Item -force $path | Add-NTFSAccess -Account 'NT AUTHORITY\Authenticated Users' -AccessRights FullControl 
				Get-Item -force $path | Add-NTFSAccess -Account "NMI\$User" -AccessRights FullControl

            }
			write-host "Giving ownership of Directory $i to $User" -fore Green
			get-item $i | set-NTFSowner -Account "NMI\$User"
		}
	}

D:



