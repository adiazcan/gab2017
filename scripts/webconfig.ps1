#create KeyVault
$keyVaultName = "WebConfigSecrets"
New-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $resourcegroupname -Location $location -Sku Standard 

#create Azure Ad Application
$aadClientSecret = "q42JAgvdS+Beo7YJtJjS+TifOSY4uoSwNnTl4YBVP6M="
$azureAdApp = New-AzureRmADApplication -DisplayName "WebConfigApp" -HomePage "https://webconfig.startrek.com" -IdentifierUris "https://webconfig.startrek.com" -Password $aadClientSecret
$servicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $azureAdApp.ApplicationId
$servicePrincipal.ApplicationId

#give application access to KeyVault
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName $servicePrincipal.ApplicationId -PermissionsToKeys all -PermissionsToSecrets all -ResourceGroupName $resourcegroupname

# Ponemos la cadena de conexión como Secret
$secretkey1 = ConvertTo-SecureString "Server=tcp:enterprise.database.windows.net;Database=myDataBase;User ID=spock;Password=SoyElMejorDelUniverso;Trusted_Connection=False;Encrypt=True;" -AsPlainText -Force
$kvsecret1 = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name "DB" -SecretValue $secretkey1
$kvsecret1