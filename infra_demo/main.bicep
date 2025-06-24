@description('The location for all resources.')
param location string = resourceGroup().location

@description('Admin username for the VMs')
param adminUsername string

@description('Admin password for the VMs')
@secure()
param adminPassword string

@description('Size for the VMs')
param vmSize string = 'Standard_B2s'

@description('Number of worker nodes')
param workerNodeCount int = 0

var networkSettings = {
  vnetName: 'k3s-vnet'
  vnetAddressPrefix: '10.0.0.0/16'
  subnetName: 'k3s-subnet'
  subnetAddressPrefix: '10.0.1.0/24'
}

// Create VNET and Subnet
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: networkSettings.vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        networkSettings.vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: networkSettings.subnetName
        properties: {
          addressPrefix: networkSettings.subnetAddressPrefix
        }
      }
    ]
  }
}

// Deploy master node
module masterNode 'vm.bicep' = {
  name: 'masterNode'
  params: {
    vmName: 'k3s-master'
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
    subnetId: vnet.properties.subnets[0].id
    customData: loadFileAsBase64('scripts/master.sh')
  }
}

// Deploy worker nodes
module workerNodes 'vm.bicep' = [
  for i in range(0, workerNodeCount): {
    name: 'workerNode${i}'
    params: {
      vmName: 'k3s-worker${i}'
      location: location
      adminUsername: adminUsername
      adminPassword: adminPassword
      vmSize: vmSize
      subnetId: vnet.properties.subnets[0].id
      customData: loadFileAsBase64('scripts/worker.sh')
    }
  }
]

output masterNodePublicIP string = masterNode.outputs.publicIPAddress
