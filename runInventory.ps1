# 
# Since: September, 2015
# Author: andres.fandino@oracle.com
# Description: script to run Opatch with lsinventory

# set-executionpolicy remotesigned

$EPM_ORACLE_HOME = "C:\Oracle\Middleware\EPMSystem11R1"
$MIDDLEWARE_HOME = "C:\Oracle\Middleware"
$OPATCH_HOME = $MIDDLEWARE_HOME +"\OPatch"
$JAVA_HOME = $MIDDLEWARE_HOME + "\jdk160_29"
$PATCH_HOME =  $MIDDLEWARE_HOME + "\patches"
$SYSTEM_NAME = $env:COMPUTERNAME
$patchList=IMPORT-CSV "$MIDDLEWARE_HOME\patches.csv"

$EPM_ORACLE_HOME = "C:\Oracle\Middleware\ODI_HOME"
$OPATCH_HOME = $MIDDLEWARE_HOME +"\ODI_HOME\OPatch"
$JAVA_HOME = "C:\PROGRA~1\Java\jdk1.7.0_79"

function runInventory {
# cmd.exe /C "opatch.bat param1 param2"
# 

cmd.exe /C "$OPATCH_HOME\opatch.bat lsinventory -oh $EPM_ORACLE_HOME -jdk $JAVA_HOME"


}

runInventory