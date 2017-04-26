#Create KeyVault
$keyVaultName = "BitlockerKeys"
$kv = New-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $resourcegroupname -Location $location -Sku Standard -EnabledForDiskEncryption -EnabledForDeployment -EnabledForTemplateDeployment

#Create Azure AD application
$aadClientSecret = "vv9309r8290rsdvlksdfklwfkljdklfjglk||kwfkljfjwf==sdfkndf=="
$azureAdApp = New-AzureRmADApplication -DisplayName "BitlockerApp" -HomePage "https://bitlocker.startrek.com" -IdentifierUris "https://bitlocker.startrek.com" -Password $aadClientSecret
$servicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $azureAdApp.ApplicationId
$servicePrincipal

#add Client Secret to KeyVault
$aadSecret = ConvertTo-SecureString $aadClientSecret -AsPlainText -Force
$kvaadsecret1 = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name aadsecret -SecretValue $aadSecret
$aadkey = (Get-AzureKeyVaultSecret -VaultName $keyVaultName -Name aadsecret).SecretValueText

#give Azure AD App access to KeyVault
$aadClientId = $servicePrincipal.ApplicationId
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName $aadClientId -PermissionsToKeys wrapKey -PermissionsToSecrets set -ResourceGroupName $resourcegroupname

#Get VM properties
$aadClientSecret = $aadkey
$keyVaultID = $kv.ResourceId
$keyVaultURL = $kv.VaultUri

Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $resourcegroupname -VMName $servername -AadClientID $aadClientId -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultId $keyVaultID -DiskEncryptionKeyVaultUrl $keyVaultURL -SequenceVersion (New-Guid) -VolumeType All
