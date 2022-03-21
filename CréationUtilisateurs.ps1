#Script pour creer un utilisateur ainsi que son dossier partager depuis une liste stocké dans un fichier text
#je l'ai fais depuis une liste car cela est plus cohérant par rapport à la situation.

$CSVFile = "C:\Sources\Scripts\users.csv"
$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

Write-Output $CSVData

Foreach($Utilisateur in $CSVData){
    $UtilisateurPrenom = $Utilisateur.Prenom
    $UtilisateurNom = $Utilisateur.Nom
    $UtilisateurFonction = $Utilisateur.Fonction
    $UtilisateurLogin = ($UtilisateurPrenom).Substring(0,1) + "." + $UtilisateurNom
    $UtilisateurEmail = "$UtilisateurLogin@epsi.local"
    $UtilisateurPassword = "Azerty123!*"

    if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin})
    {
        Write-Output "L'utilisateur existe déjà"
    }
    else
    {
        New-ADUser  -Name "$UtilisateurNom $UtilisateurPrenom" -DisplayName "$UtilisateurNom $UtilisateurPrenom" -GivenName $UtilisateurPrenom -Surname $UtilisateurNom -SamAccountName $UtilisateurLogin -UserPrincipalName "$UtilisateurLogin@epsi.local" -EmailAddress $UtilisateurEmail -Title $UtilisateurFonction -Path "OU=ACME,DC=epsi,DC=LOCAL" -AccountPassword(ConvertTo-SecureString $UtilisateurPassword -AsPlainText -Force) -ChangePasswordAtLogon $false -Enabled $true
        Add-ADGroupMember -Identity $UtilisateurFonction -Members $UtilisateurLogin
        
        #création du répertoire partagé
        New-SmbShare -Name $UtilisateurNom -Path "C:\Partage\" -FullAccess "Tout le monde"

        Write-Output "Création de l'utilisateur ainsi que son dossier paratagé : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)"
    }
}