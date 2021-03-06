# 
# Since: September, 2015
# Author: andres.fandino@oracle.com
# Description: script to stage patches for Opatch

# set-executionpolicy remotesigned

$EPM_ORACLE_HOME = "C:\Oracle\Middleware\EPMSystem11R1"
$MIDDLEWARE_HOME = "C:\Oracle\Middleware"
$OPATCH_HOME = $MIDDLEWARE_HOME +"\ODI_HOME\OPatch"
$JAVA_HOME = $MIDDLEWARE_HOME + "\jdk160_29"
$PATCH_HOME =  $MIDDLEWARE_HOME + "\patches"
$SYSTEM_NAME = $env:COMPUTERNAME




function Map-Adrive{
<#
     .Example
          Map-Adrive Z \\server\folder
     .Example
          Map-Adrive Z \\server\folder -persistent
     .Example
          Map-Adrive Z \\server\folder -verbose
#>    
     [CmdletBinding()]
     param(
          [string]$driveletter,
          [string]$path,
          [switch]$persistent
     )
     process{
          $nwrk=new-object -com Wscript.Network
          Write-Verbose "Mapping $($driveletter+':') to $path and persist=$persistent"
          try{
               $nwrk.MapNetworkDrive($($driveletter+':'),$path)     
               Write-Verbose "Mapping successful."
          }
          catch{
               Write-Verbose "Mapping failed!"
          }
     }
}


function Unzip-File { 
 
<# 
.SYNOPSIS 
   Unzip-File is a function which extracts the contents of a zip file. 
 
.DESCRIPTION 
   Unzip-File is a function which extracts the contents of a zip file specified via the -File parameter to the 
location specified via the -Destination parameter. This function first checks to see if the .NET Framework 4.5 
is installed and uses it for the unzipping process, otherwise COM is used. 
 
.PARAMETER File 
    The complete path and name of the zip file in this format: C:\zipfiles\myzipfile.zip  
  
.PARAMETER Destination 
    The destination folder to extract the contents of the zip file to. If a path is no specified, the current path 
is used. 
 
.PARAMETER ForceCOM 
    Switch parameter to force the use of COM for the extraction even if the .NET Framework 4.5 is present. 
 
.EXAMPLE 
   Unzip-File -File C:\zipfiles\AdventureWorks2012_Database.zip -Destination C:\databases\ 
 
.EXAMPLE 
   Unzip-File -File C:\zipfiles\AdventureWorks2012_Database.zip -Destination C:\databases\ -ForceCOM 
 
.EXAMPLE 
   'C:\zipfiles\AdventureWorks2012_Database.zip' | Unzip-File 
 
.EXAMPLE 
    Get-ChildItem -Path C:\zipfiles | ForEach-Object {$_.fullname | Unzip-File -Destination C:\databases} 
 
.INPUTS 
   String 
 
.OUTPUTS 
   None 
 
.NOTES 

 
#> 
 
    [CmdletBinding()] 
    param ( 
        [Parameter(Mandatory=$true,  
                   ValueFromPipeline=$true)] 
        [ValidateScript({ 
            If ((Test-Path -Path $_ -PathType Leaf) -and ($_ -like "*.zip")) { 
                $true 
            } 
            else { 
                Throw "$_ is not a valid zip file. Enter in 'c:\folder\file.zip' format" 
            } 
        })] 
        [string]$File, 
 
        [ValidateNotNullOrEmpty()] 
        [ValidateScript({ 
            If (Test-Path -Path $_ -PathType Container) { 
                $true 
            } 
            else { 
                Throw "$_ is not a valid destination folder. Enter in 'c:\destination' format" 
            } 
        })] 
        [string]$Destination = (Get-Location).Path, 
 
        [switch]$ForceCOM 
    ) 
 
 
    If (-not $ForceCOM -and ($PSVersionTable.PSVersion.Major -ge 3) -and 
       ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue).Version -like "4.5*" -or 
       (Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client" -ErrorAction SilentlyContinue).Version -like "4.5*")) { 
 
        Write-Verbose -Message "Attempting to Unzip $File to location $Destination using .NET 4.5" 
 
        try { 
            [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null 
            [System.IO.Compression.ZipFile]::ExtractToDirectory("$File", "$Destination") 
        } 
        catch { 
            Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message" 
        } 
 
 
    } 
    else { 
 
        Write-Verbose -Message "Attempting to Unzip $File to location $Destination using COM" 
 
        try { 
            $shell = New-Object -ComObject Shell.Application 
            $shell.Namespace($destination).copyhere(($shell.NameSpace($file)).items()) 
        } 
        catch { 
            Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message" 
        } 
 
    } 
 
}

function copyPatches {
    $patchList=IMPORT-CSV "$MIDDLEWARE_HOME\patches\patches.csv"
    FOREACH ($System in $patchList) {
        IF ($SYSTEM_NAME -eq $System.SYSTEM_NAME) { 
            $patchfile = "Z:\" + $System.PATCH_NUMBER+".zip"
            Copy-Item -Path $patchfile -Destination $PATCH_HOME
        }
        ELSE { $System.PATCH_NUMBER + "is not applicable on $SYSTEM_NAME."}
    }

}

function unzipPatches {
    
    CD $PATCH_HOME
    $fileEntries = Get-ChildItem -Path $PATCH_HOME | Where-Object {$_.Extension -eq ".zip"}
    foreach($fileName in $fileEntries) 
    { 
        $fullfileName = join-path $PATCH_HOME $fileName -resolve
        [Console]::WriteLine($fullfileName)
        Unzip-File –File $fullfileName –Destination $OPATCH_HOME 
    }   

}

Map-Adrive Z \\AFANDINO-US\patches

MD $PATCH_HOME

Copy-Item -Path Z:\patches.csv -Destination $PATCH_HOME

copyPatches

unzipPatches