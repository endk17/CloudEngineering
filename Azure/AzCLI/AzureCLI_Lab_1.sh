#!/bin/bash

# Azure Login
az
az login

#Define Lab Enviornment
Location=northeurope
ResourceGroupName=EKAzLab
NetworkSecurityGroup=NSG-EKAzLab
VNetName=VNet-AzureVMsNrthEU
VNetAddress=10.10.0.0/16
SubnetName=Subnet-AzureDCsNrthEU
SubnetAddress=10.10.10.0/24
DNSServers=10.10.10.11
AvailabilitySet=AppNetLab
VMSize=Standard_B1ms
DataDiskSize=20
StorageSKU=StandardSSD_LRS
AdminUsername=LabAdmin
AdminPassword=P@ssw0rd2019
DomainController1=AZDC01
DC1IP=10.10.10.11
DomainController2=AZDC02
DC2IP=10.10.10.12
DomainADFS=AZADFS01
ADFS01IP=10.10.10.13
DomainCertAuthority=AZCA01
CA01IP=10.10.10.14

# Create a resource group.
az group create --name $ResourceGroupName \
                --location $Location

# Create a network security group
az network nsg create --name $NetworkSecurityGroup \
                      --resource-group $ResourceGroupName \
                      --location $Location

# Create a network security group rule for port 3389.
az network nsg rule create --name PermitRDP \
                           --nsg-name $NetworkSecurityGroup \
                           --priority 1000 \
                           --resource-group $ResourceGroupName \
                           --access Allow \
                           --source-address-prefixes "*" \
                           --source-port-ranges "*" \
                           --direction Inbound \
                           --destination-port-ranges 3389

# Create a virtual network.
az network vnet create --name $VNetName \
                       --resource-group $ResourceGroupName \
                       --address-prefixes $VNetAddress \
                       --location $Location \
                       --dns-servers $DNSServers \

# Create a subnet
az network vnet subnet create --address-prefix $SubnetAddress \
                              --name $SubnetName \
                              --resource-group $ResourceGroupName \
                              --vnet-name $VNetName \
                              --network-security-group $NetworkSecurityGroup

# Create an availability set.
az vm availability-set create --name $AvailabilitySet \
                              --resource-group $ResourceGroupName \
                              --location $Location

# Create 4 virtual machiness
az vm create \
    --resource-group $ResourceGroupName \
    --availability-set $AvailabilitySet \
    --name $DomainController1 \
    --size $VMSize \
    --image Win2019Datacenter \
    --admin-username $AdminUsername \
    --admin-password $AdminPassword \
    --data-disk-sizes-gb $DataDiskSize \
    --storage-sku $StorageSKU \
    --data-disk-caching None \
    --nsg $NetworkSecurityGroup \
    --private-ip-address $DC1IP \
    --no-wait

az vm create \
    --resource-group $ResourceGroupName \
    --availability-set $AvailabilitySet \
    --name $DomainController2 \
    --size $VMSize \
    --image Win2019Datacenter \
    --admin-username $AdminUsername \
    --admin-password $AdminPassword \
    --data-disk-sizes-gb $DataDiskSize \
    --storage-sku $StorageSKU \
    --data-disk-caching None \
    --nsg $NetworkSecurityGroup \
    --private-ip-address $DC2IP
    --no-wait

az vm create \
    --resource-group $ResourceGroupName \
    --availability-set $AvailabilitySet \
    --name $DomainADFS \
    --size $VMSize \
    --image Win2019Datacenter \
    --admin-username $AdminUsername \
    --admin-password $AdminPassword \
    --data-disk-sizes-gb $DataDiskSize \
    --storage-sku $StorageSKU \
    --data-disk-caching None \
    --nsg $NetworkSecurityGroup \
    --private-ip-address $ADFS01IP
    --no-wait

az vm create \
    --resource-group $ResourceGroupName \
    --availability-set $AvailabilitySet \
    --name $DomainCertAuthority \
    --size $VMSize \
    --image Win2019Datacenter \
    --admin-username $AdminUsername \
    --admin-password $AdminPassword \
    --data-disk-sizes-gb $DataDiskSize \
    --storage-sku $StorageSKU \
    --data-disk-caching None \
    --nsg $NetworkSecurityGroup \
    --private-ip-address $CA01IP
    --no-wait
