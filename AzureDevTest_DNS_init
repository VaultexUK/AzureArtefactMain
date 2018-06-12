
$DNSservers = "#{DNSservers}"
$suffixsearchlist = "#{suffixsearchlist}"
$suffix = "#{suffix}"
$quote = [char]34
$dash = [char]45

$VMint = (get-netipinterface | ? {$_.InterfaceAlias -like "*Ethernet*" -and $_.AddressFamily -like "*IPv4*"}).InterfaceAlias

Set-DnsClientServerAddress -InterfaceAlias $VMint -ServerAddresses $DNSservers
Set-DnsClientGlobalSetting -SuffixSearchList $suffixsearchlist
Set-DNSClient -InterfaceAlias $VMint -ConnectionSpecificSuffix $suffix -UseSuffixWhenRegistering $true

(Get-WMIObject Win32_NetworkAdapterConfiguration -Filter "DNSDomain=$($quote)$suffix$($quote)").SetDynamicDNSRegistration($true,$true)

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
