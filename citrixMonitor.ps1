﻿

###########################################################
#
#	Script Name: 	CitrixMonUserLogon
#
#	Build:		2015.02.19 revision 1
#
#	Author:		Bryan Zanoli
#			@BryanZanoli
#	
#	Date Created:	02-19-2015
#
#	Description: 	Connects to a XenDesktop 7.x site, collects 
#			User and Session data, and returns the total 
#			number of user logons per user, based
#			on a specified date.
#
###########################################################

#Obtains the user credentials needed for accessing the XenDesktop Site monitoring information
$cred = Get-Credential

#Grab 'Users' data from XenDesktop site
#Replace localhost with FQDN of DDC if not running on DDC
$userdata = Invoke-RestMethod -uri "http://vmd-xd-ddc1.ds.usfca.edu/Citrix/Monitor/Odata/v1/Data/Users" -Credential $cred

#Populate User objects in $users variable
$users = $userdata.content.properties

#Obtain 'Sessions' data from XenDesktop Site
#Replace localhost with FQDN of DDC if not running on DDC
$sessiondata = Invoke-RestMethod -uri "http://vmd-xd-ddc1.ds.usfca.edu/Citrix/Monitor/Odata/v1/Data/Sessions" -Credential $cred

#Populate Session objects in $sessions variable
$sessions = $sessiondata.content.properties

#Create $date variable and set date to a temporary value
$date = "2015-01-06"

#Query the user for an updated date value, in specified format
$date = read-host "Please enter the date you wish to search (YYYY-MM-DD): "

#Returns the sessions for the specified date and populatess them into the $sessionDate1 variable
$sessionDate1 = $sessions | where {$_.startdate.InnerText -like "$($date)*"}

#Populates the $userIDs variable with the userId value from the filtered sessions
$userIDs = $sessionDate1.UserId.InnerText

#Create a null array, used to capture and count user logons
$userObject = @()

#Begin for loop to process data
foreach ($userID in $userIDS) {
    
    #Create $userName variable and set the value to $null	
    $userName = $null

    #Filter $users so that only the user object with the given userId is returned
    $userName = $users | where {$_.Id.InnerText -eq $userID}
    
    #Check to see if the currently returned username already exists in the $userObject array
    if($userObject.UserName -contains $userName.UserName) {
        
	#Return the index of the location of the current user object
	$i = [array]::indexOf($userObject.UserName,($userName.UserName))
        
	#Since the user object already exists for userName, increase logon count by one
	($userObject[$i]).count++
    }

    #If userName has not already been processed, proceed to object creation
    else{
	
	#Create a new System Object named $userObj
        $userObj = new-object System.Object

	#Add a member property of type [string] to the object, with the value of current UserName
        $userObj | add-member -memberType NoteProperty -Name UserName -Value $userName.UserName
        
	#Add a member property of type [int] to the object, with the value of 1, since this is the first occurance
	#of the current user
	$userObj | add-member -memberType NoteProperty -Name Count -Value 1

	#Add the newly created user object to the $userObject array
        $userObject += $userObj
    }
}

#Display Username and Logon Count
$userObject | fl UserName,Count


