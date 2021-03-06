# 
# Since: September, 2015
# Author: andres.fandino@oracle.com
# Description: script to apply patches with Opatch

# set-executionpolicy remotesigned

$EPM_ORACLE_HOME = "C:\Oracle\Middleware\EPMSystem11R1"
$MIDDLEWARE_HOME = "C:\Oracle\Middleware"
$OPATCH_HOME = $MIDDLEWARE_HOME +"\OPatch"
$JAVA_HOME = $MIDDLEWARE_HOME + "\jdk160_29"
$PATCH_HOME =  $MIDDLEWARE_HOME + "\patches"
$SYSTEM_NAME = $env:COMPUTERNAME
$patchList=IMPORT-CSV "$MIDDLEWARE_HOME\patches.csv"

function applyPatch {

<#
     .Example
          applyPatch 18659116
#>    
[CmdletBinding()]
     param(
          [Parameter(Mandatory=$true)]   
          [string]$patchNumber
     )

# cmd.exe /C "$OPATCH_HOME\opatch.bat apply $OPATCH_HOME\$patchNumber -oh $EPM_ORACLE_HOME -jdk $JAVA_HOME"

$OPATCH_HOME +"\opatch.bat apply "+ $OPATCH_HOME +"\"+ $patchNumber +" -oh "+ $EPM_ORACLE_HOME +" -jdk  "+ $JAVA_HOME

}


FOREACH ($System in $patchList) {
    IF ($SYSTEM_NAME -eq $System.SYSTEM_NAME) { 
        applypatch $System.PATCH_NUMBER
    
    }
    ELSE { $System.PATCH_NUMBER + "is not applicable on $SYSTEM_NAME."}
}