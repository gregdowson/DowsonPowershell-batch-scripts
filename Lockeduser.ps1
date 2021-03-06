<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS Log File
  The script log file stored in C:\Windows\Temp\<name>.log

.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development

.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>

  <Example explanation goes here>
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import PSLogging Module
Import-Module C:\scripts\PSLogging.psm1

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'

#Log File Info
$sLogPath = 'C:\Windows\Temp'
$sLogName = 'Lockeduser.log'
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
$date = Get-Date
$rDate = (Get-Date -format "MM-dd-yyyy")
#-----------------------------------------------------------[Functions]------------------------------------------------------------

<#

Function <FunctionName> {
  Param ()

  Begin {
    Write-LogInfo -LogPath $sLogFile -Message '<description of what is going on>...'
  }

  Process {
    Try {
      <code goes here>
    }

    Catch {
      Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
      Break
    }
  }

  End {
    If ($?) {
      Write-LogInfo -LogPath $sLogFile -Message 'Completed Successfully.'
      Write-LogInfo -LogPath $sLogFile -Message ' '
    }
  }
}

#>

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

#Obtain user

$User = Read-Host -Prompt "Please enter a user name"

#Specify PDCe
$PDC = Get-ADDomainController -Discover -Service PrimaryDC
 
#Collect lockout events for user from last hour

Get-WinEvent -ComputerName $PDC `

-Logname Security `

-FilterXPath "*[System[EventID=4740 and TimeCreated[timediff(@SystemTime) <= 3600000]] and EventData[Data[@Name='TargetUserName']='$User']]" |

Select-Object TimeCreated,@{Name='User Name';Expression={$_.Properties[0].Value}},@{Name='Source Host';Expression={$_.Properties[1].Value}}

 
Stop-Log -LogPath $sLogFile