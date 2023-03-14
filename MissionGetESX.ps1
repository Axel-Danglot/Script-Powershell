########### INFORMATION ###############
#Auteur : Axel Danglot
#Date de Création : 24/05/2022

######## VARIABLE A CHANGER ###########
#$ip = 10.59.3.185
#$User = administrator@maquette.lan
#$Psswd = Axians2022$
#######################################
# même chose pour HyperV 
Set-PowerCLIConfiguration -InvalidCertificateAction ignore
Connect-VIServer -Server 10.59.3.185 -User administrator@maquette.lan -Password Axians2022$
Get-VM | Where-object {$_.powerstate -eq "poweredon"} | select Name,PowerState,MemoryGB,NumCpu,UsedSpaceGB
Get-VM | Where-object {$_.powerstate -eq "poweredon"} | select Name,PowerState,MemoryGB,NumCpu,UsedSpaceGB | Export-Csv -path “C:\test\vminventory.csv” -NoTypeInformation
