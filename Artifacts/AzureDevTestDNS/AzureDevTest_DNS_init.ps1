<#
.SYNOPSIS

Script to create report of services not running.

.DESCRIPTION

Use this command to configure DNS for Azure VMs so that they can connect to a domain.
AzureDevTest_DNS_init.ps1
$DNSServers should be one or two IP addresses.
$suffixsearchlaist should be one or more suffixes to search, including the domain FQDN that the VM is being joined to.
$suffix should be the domain FQDN the the VM is being joined to.

#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string] $DNSservers,
    
    [Parameter(Mandatory = $true)]
    [string] $suffixsearchlist,

    [Parameter(Mandatory = $false)]
    [string] $suffix
)

###################################################################################################
#
# PowerShell configurations
#

# NOTE: Because the $ErrorActionPreference is "Stop", this script will stop on first failure.
#       This is necessary to ensure we capture errors inside the try-catch-finally block.
$ErrorActionPreference = "Stop"

# Ensure we set the working directory to that of the script.
Push-Location $PSScriptRoot

###################################################################################################
#
# Handle all errors in this script.
#

trap
{
    # NOTE: This trap will handle all errors. There should be no need to use a catch below in this
    #       script, unless you want to ignore a specific error.
    $message = $error[0].Exception.Message
    if ($message)
    {
        Write-Host -Object "ERROR: $message" -ForegroundColor Red
    }
    
    # IMPORTANT NOTE: Throwing a terminating error (using $ErrorActionPreference = "Stop") still
    # returns exit code zero from the PowerShell script when using -File. The workaround is to
    # NOT use -File when calling this script and leverage the try-catch-finally block and return
    # a non-zero exit code from the catch block.
    Write-Host 'Artifact failed to apply.'
    exit -1
}

###################################################################################################
#
# Main execution block.
#

try
{
    $VMint = (get-netipinterface | ? {$_.InterfaceAlias -like "*Ethernet*" -and $_.AddressFamily -like "*IPv4*"}).InterfaceAlias

    Set-DnsClientServerAddress -InterfaceAlias $VMint -ServerAddresses $DNSservers
    Set-DnsClientGlobalSetting -SuffixSearchList $suffixsearchlist
    Set-DNSClient -InterfaceAlias $VMint -ConnectionSpecificSuffix $suffix -UseSuffixWhenRegistering $true

    (Get-WMIObject Win32_NetworkAdapterConfiguration -Filter "DNSDomain=$($quote)$suffix$($quote)").SetDynamicDNSRegistration($true,$true)

    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

    Write-Host 'DNS updated'
}
finally
{
    Pop-Location
}
