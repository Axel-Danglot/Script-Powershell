<# 
.NAME
    Veeam Backup for Microsoft Office 365 clean up script for a list of users
.SYNOPSIS
    Removes all data and licences from a list of users
.DESCRIPTION
    Script to use for removing all data and licences from a list of users from a specific repository
    Released under the MIT license.
.LINK
    http://
#>


# Do not change below unless you know what you are doing
Import-Module "C:\Program Files\Veeam\Backup365\Veeam.Archiver.PowerShell\Veeam.Archiver.PowerShell.psd1"

# Modify the values below to your needs
######################################################################
$CSVFile = Get-Content "C:\Sources\Scripts\Exclusiontest.txt"
$LogFile = "C:\Temp\VBOExclusion.log"

$repository = Get-VBORepository -Name "ExtendRepository"
$org = Get-VBOOrganization -Name "voiesnavigablesdefrance.onmicrosoft.com"

$from = "VeeamO365@vnf.fr"
$Destinataires = "philippe.sakwinski@vnf.fr"
[string[]]$To = $Destinataires.Split(',')
$smtpserver = "mailvnf.in.tmes.trendmicro.eu"
$subject = "Veeam Backup for Microsoft Office 365 reports"
$port = "25" # default: 25
$usessl = $true # Use SSL (true) or not (false)

$job1 = Get-VBOJob -Name "Exchange_Silver"
$job2 = Get-VBOJob -Name "OneDrive_Silver"
$job3 = Get-VBOJob -Name "SharePoint_Silver"
$job4 = Get-VBOJob -Name "Teams_Silver"
######################################################################


# Function to timestamp input in logfiles
 function Get-TimeStamp {
    return "[{0:dd-MM-yyyy}] [{0:HH:mm:ss}]" -f (Get-Date)
}

# Create a VBO log file if does not exist
if(!(Test-Path -Path $LogFile)) {
    New-Item -Path $LogFile
} else {
    New-Item -Path $LogFile -Force
}

Foreach($UtilisateurMail in $CSVFile) {   

    $user = Get-VBOEntityData -Type User -Repository $repository -Name $UtilisateurMail    
   
    if($user -eq $null) {
        Write-Output "-------------------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
        Write-Output "$(Get-TimeStamp)" " [Info]: " "Processing : " $UtilisateurMail " à déja été supprimé"  | Out-File -FilePath $LogFile -NoNewLine -Append

    } else {
        # Remove users data from the repository
        Remove-VBOEntityData -Repository $repository -User $user -Mailbox -ArchiveMailbox -OneDrive -Sites -Confirm:$False # Il fqut verifier le retour de cette co,,qnde et fqire un ,essqge dùerreur en conceauence
        $checkrm = Get-VBOEntityData -Type User -Repository $repository -Name $UtilisateurMail
        
        if($checkrm -eq $null){
            Write-Output "--------------------------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
            Write-Output "$(Get-TimeStamp)" " [Info]: " "Successfull : " "le repository de " $UtilisateurMail " à bien été supprimé"  | Out-File -FilePath $LogFile -NoNewLine -Append

        }else{
            Write-Output "--------------------------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
            Write-Output "$(Get-TimeStamp)" " [Info]: " "Error : " "le repository de " $UtilisateurMail " n'a pas été supprimé"  | Out-File -FilePath $LogFile -NoNewLine -Append
            }
        # Get a licensed user name and save as a variable
        $licensedUser = Get-VBOLicensedUser -Organization $org -Name $UtilisateurMail
        
        if ($licensedUser -eq $null) {
            Write-Output "--------------------------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
            Write-Output "$(Get-TimeStamp)" " [Info]: " "Processing : " $UtilisateurMail " la license de cette utilisateur à déjà été supprimé"  | Out-File -FilePath $LogFile -NoNewLine -Append

        } else {
            # Remove the licensed user
            Remove-VBOLicensedUser -User $licensedUser
            $checklicense = Get-VBOLicensedUser -Organization $org -Name $UtilisateurMail
                if($checklicense -eq $null){
                    Write-Output "--------------------------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
                    Write-Output "$(Get-TimeStamp)" " [Info]: " "Successfull : " "la license de " $UtilisateurMail " a été supprimé avec succès"  | Out-File -FilePath $LogFile -NoNewLine -Append
                   }else{
                        Write-Output "--------------------------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
                        Write-Output "$(Get-TimeStamp)" " [Info]: " "Error : " "la license de " $UtilisateurMail " n'a pas été supprimé"  | Out-File -FilePath $LogFile -NoNewLine -Append
        }
    }
  }
}

#-------------- Exclusion des utilisateurs dans les Jobs -----------------------

# Importation des variables
$Users = Get-VBOOrganizationUser -Organization $org | ?{$CSVFile.Contains($_.UserName)}
$bi = New-VBOBackupItem -User $Users

# Exclusion sur chaque job
Set-VBOJob -Job $job1 -ExcludedItems $bi
Set-VBOJob -Job $job2 -ExcludedItems $bi
Set-VBOJob -Job $job3 -ExcludedItems $bi
Set-VBOJob -Job $job4 -ExcludedItems $bi


Foreach($UtilisateurMail in $CSVData) {
    Write-Output "-----------------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
    Write-Output "$(Get-TimeStamp)" " [Info]: " "Processing : " $UtilisateurMail " à été exclu des jobs"  | Out-File -FilePath $LogFile -NoNewLine -Append
}


#------------------------ Envoie du Mail ---------------------------------

Send-MailMessage -SmtpServer $smtpserver -from $from -To $To -Subject $subject -Body "Bonjour, Veuillez trouver en pièce jointe le rapport du script" -Attachments $LogFile  -Port $port
Write-Output "-----------------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
Write-Output "$(Get-TimeStamp)" " [Info]: " "Processing : Envoie du mail avec rapport"  | Out-File -FilePath $LogFile -NoNewLine -Append

#------------------------ Update Licences ---------------------------------

Update-VBOLicense

#------------------------ Cleaning variables ---------------------------------

Remove-Variable -Name * -ErrorAction SilentlyContinue
