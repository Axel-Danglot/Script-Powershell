########### INFORMATION ###############
#Auteur : Axel Danglot
#Date de Création : 24/05/2022

######## VARIABLE A CHANGER ###########
#$ip =
#$User = 
#$Psswd = 
#######################################
# même chose pour HyperV 
Set-PowerCLIConfiguration -InvalidCertificateAction ignore
Connect-VIServer -Server $ip -User $User -Password $Psswd
Get-VM | Where-object {$_.powerstate -eq "poweredon"} | select Name,PowerState,MemoryGB,NumCpu,UsedSpaceGB
Get-VM | Where-object {$_.powerstate -eq "poweredon"} | select Name,PowerState,MemoryGB,NumCpu,UsedSpaceGB | Export-Csv -path “C:\test\vminventory.csv” -NoTypeInformation
