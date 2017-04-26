#variables
$subcriptionid = "bffbb91a-dcee-4040-962e-6efbd2ad9d00"
$location = "North Europe"
$servername = "VM"
$prefix = "startrek"
$resourcegroupname = $prefix + "rg"
$SAunencrypted = $prefix + "unencrypted"
$SAencrypted = $prefix + "encrypted"
$SAVMs = $prefix + "vms"

Login-AzureRmAccount
Set-AzureRmContext -SubscriptionId $subcriptionid

New-AzureRmResourceGroup -Name $resourcegroupname -Location $location 