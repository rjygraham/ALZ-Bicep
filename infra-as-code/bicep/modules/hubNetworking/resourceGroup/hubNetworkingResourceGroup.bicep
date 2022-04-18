targetScope = 'subscription'

@description('The Azure Region to deploy the resources into. Default: resourceGroup().location')
param parLocation string

@description('Prefix value which will be prepended to all resource names. Default: alz')
param parCompanyPrefix string = 'alz'

@description('Named Used for Hub Network Resource Group. Default: {parCompanyPrefix}-hub-{parLocation}')
param parResourceGroupName string = '${parCompanyPrefix}-hub-${parLocation}'

@description('Prefix Used for Hub Network. Default: {parCompanyPrefix}-hub-{parLocation}')
param parHubNetworkName string = '${parCompanyPrefix}-hub-${parLocation}'

@description('The IP address range for all virtual networks to use. Default: 10.10.0.0/16')
param parHubNetworkAddressPrefix string = '10.10.0.0/16'

@description('The name and IP address range for each subnet in the virtual networks. Default: AzureBastionSubnet, GatewaySubnet, AzureFirewall Subnet')
param parSubnets array = [
  {
    name: 'AzureBastionSubnet'
    ipAddressRange: '10.10.15.0/24'
  }
  {
    name: 'GatewaySubnet'
    ipAddressRange: '10.10.252.0/24'
  }
  {
    name: 'AzureFirewallSubnet'
    ipAddressRange: '10.10.254.0/24'
  }
]

@description('Array of DNS Server IP addresses for VNet. Default: Empty Array')
param parDNSServerIPArray array = []

@description('Public IP Address SKU. Default: Standard')
@allowed([
  'Basic'
  'Standard'
])
param parPublicIPSku string = 'Standard'

@description('Switch which allows Bastion deployment to be disabled. Default: true')
param parBastionEnabled bool = true

@description('Name Associated with Bastion Service:  Default: {parCompanyPrefix}-bastion')
param parBastionName string = '${parCompanyPrefix}-bastion'

@description('Azure Bastion SKU or Tier to deploy.  Currently two options exist Basic and Standard. Default: Standard')
param parBastionSku string = 'Standard'

@description('Switch which allows DDOS deployment to be disabled. Default: true')
param parDdosEnabled bool = true

@description('DDOS Plan Name. Default: {parCompanyPrefix}-ddos-plan')
param parDdosPlanName string = '${parCompanyPrefix}-ddos-plan'

@description('Switch which allows Azure Firewall deployment to be disabled. Default: true')
param parAzureFirewallEnabled bool = true

@description('Azure Firewall Name. Default: {parCompanyPrefix}-azure-firewall ')
param parAzureFirewallName string = '${parCompanyPrefix}-azure-firewall'

@description('Azure Firewall Tier associated with the Firewall to deploy. Default: Standard ')
@allowed([
  'Standard'
  'Premium'
])
param parAzureFirewallTier string = 'Standard'

@description('Switch which enables DNS Proxy to be enabled on the Azure Firewall. Default: true')
param parNetworkDNSEnableProxy bool = true

@description('Name of Route table to create for the default route of Hub. Default: {parCompanyPrefix}-hub-routetable')
param parHubRouteTableName string = '${parCompanyPrefix}-hub-routetable'

@description('Switch which allows BGP Propagation to be disabled on the route tables: Default: false')
param parDisableBGPRoutePropagation bool = false

@description('Switch which allows Private DNS Zones to be disabled. Default: true')
param parPrivateDNSZonesEnabled bool = true

@description('Array of DNS Zones to provision in Hub Virtual Network. Default: All known Azure Private DNS Zones')
param parPrivateDnsZones array = [
  'privatelink.azure-automation.net'
  'privatelink.database.windows.net'
  'privatelink.sql.azuresynapse.net'
  'privatelink.azuresynapse.net'
  'privatelink.blob.core.windows.net'
  'privatelink.table.core.windows.net'
  'privatelink.queue.core.windows.net'
  'privatelink.file.core.windows.net'
  'privatelink.web.core.windows.net'
  'privatelink.dfs.core.windows.net'
  'privatelink.documents.azure.com'
  'privatelink.mongo.cosmos.azure.com'
  'privatelink.cassandra.cosmos.azure.com'
  'privatelink.gremlin.cosmos.azure.com'
  'privatelink.table.cosmos.azure.com'
  'privatelink.${parLocation}.batch.azure.com'
  'privatelink.postgres.database.azure.com'
  'privatelink.mysql.database.azure.com'
  'privatelink.mariadb.database.azure.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.${parLocation}.azmk8s.io'
  '${parLocation}.privatelink.siterecovery.windowsazure.com'
  'privatelink.servicebus.windows.net'
  'privatelink.azure-devices.net'
  'privatelink.eventgrid.azure.net'
  'privatelink.azurewebsites.net'
  'privatelink.api.azureml.ms'
  'privatelink.notebooks.azure.net'
  'privatelink.service.signalr.net'
  'privatelink.afs.azure.net'
  'privatelink.datafactory.azure.net'
  'privatelink.adf.azure.com'
  'privatelink.redis.cache.windows.net'
  'privatelink.redisenterprise.cache.azure.net'
  'privatelink.purview.azure.com'
  'privatelink.digitaltwins.azure.net'
  'privatelink.azconfig.io'
  'privatelink.webpubsub.azure.com'
  'privatelink.azure-devices-provisioning.net'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.azurecr.io'
  'privatelink.search.windows.net'
]

//ASN must be 65515 if deploying VPN & ER for co-existence to work: https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-coexist-resource-manager#limits-and-limitations
@description('''Configuration for VPN virtual network gateway to be deployed. If a VPN virtual network gateway is not desired an empty object should be used as the input parameter in the parameter file, i.e. 
"parVpnGatewayConfig": {
  "value": {}
}''')
param parVpnGatewayConfig object = {
  name: '${parCompanyPrefix}-Vpn-Gateway'
  gatewaytype: 'Vpn'
  sku: 'VpnGw1'
  vpntype: 'RouteBased'
  generation: 'Generation1'
  enableBgp: false
  activeActive: false
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  asn: 65515
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: 65515
    bgpPeeringAddress: ''
    peerWeight: 5
  }
}

@description('''Configuration for ExpressRoute virtual network gateway to be deployed. If a ExpressRoute virtual network gateway is not desired an empty object should be used as the input parameter in the parameter file, i.e. 
"parExpressRouteGatewayConfig": {
  "value": {}
}''')
param parExpressRouteGatewayConfig object = {
  name: '${parCompanyPrefix}-ExpressRoute-Gateway'
  gatewaytype: 'ExpressRoute'
  sku: 'ErGw1AZ'
  vpntype: 'RouteBased'
  vpnGatewayGeneration: 'None'
  enableBgp: false
  activeActive: false
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  asn: '65515'
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: '65515'
    bgpPeeringAddress: ''
    peerWeight: '5'
  }
}

@description('Tags you would like to be applied to all resources in this module. Default: empty array')
param parTags object = {}

@description('Set Parameter to true to Opt-out of deployment telemetry')
param parTelemetryOptOut bool = false

module modResourceGroup '../../resourceGroup/resourceGroup.bicep' = {
  scope: subscription()
  name: '${parResourceGroupName}-resourcegroup'
  params: {
    parLocation: parLocation
    parResourceGroupName: parResourceGroupName
  }
}

module modResources '../resources/hubNetworking.bicep' = {
  scope: resourceGroup(parResourceGroupName)
  name: '${parResourceGroupName}-resources'
  dependsOn: [
    modResourceGroup
  ]
  params: {
    parLocation: parLocation
    parCompanyPrefix: parCompanyPrefix
    parHubNetworkName: parHubNetworkName
    parHubNetworkAddressPrefix: parHubNetworkAddressPrefix
    parSubnets: parSubnets
    parDNSServerIPArray: parDNSServerIPArray
    parPublicIPSku: parPublicIPSku
    parBastionEnabled: parBastionEnabled
    parBastionName: parBastionName
    parBastionSku: parBastionSku
    parDdosEnabled: parDdosEnabled
    parDdosPlanName: parDdosPlanName
    parAzureFirewallEnabled: parAzureFirewallEnabled
    parAzureFirewallName: parAzureFirewallName
    parAzureFirewallTier: parAzureFirewallTier
    parNetworkDNSEnableProxy: parNetworkDNSEnableProxy
    parHubRouteTableName: parHubRouteTableName
    parDisableBGPRoutePropagation: parDisableBGPRoutePropagation
    parPrivateDNSZonesEnabled: parPrivateDNSZonesEnabled
    parPrivateDnsZones: parPrivateDnsZones
    parVpnGatewayConfig: parVpnGatewayConfig
    parExpressRouteGatewayConfig: parExpressRouteGatewayConfig
    parTags: parTags
    parTelemetryOptOut: parTelemetryOptOut
  }
}

output outResourceGroupName string = modResourceGroup.outputs.outResourceGroupName
output outResourceGroupId string = modResourceGroup.outputs.outResourceGroupId

//If Azure Firewall is enabled we will deploy a RouteTable to redirect Traffic to the Firewall.
output outAzureFirewallPrivateIP string = modResources.outputs.outAzureFirewallPrivateIP

//If Azure Firewall is enabled we will deploy a RouteTable to redirect Traffic to the Firewall.
output outAzureFirewallName string = modResources.outputs.outAzureFirewallName

output outPrivateDnsZones array = modResources.outputs.outPrivateDnsZones

output outDdosPlanResourceID string = modResources.outputs.outDdosPlanResourceID
output outHubVirtualNetworkName string = modResources.outputs.outHubVirtualNetworkName
output outHubVirtualNetworkID string = modResources.outputs.outHubVirtualNetworkID
