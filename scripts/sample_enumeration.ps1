# Sample Enumeration Script
# This script demonstrates basic AD enumeration using native PowerShell commands.
# It is intended for educational purposes only.

Write-Host "=== Active Directory Enumeration Script ===" -ForegroundColor Cyan

# 1. Get Current Domain Info
Write-Host "`n[+] Getting Domain Info..." -ForegroundColor Green
try {
    $domainInfo = Get-ADDomain
    Write-Host "Domain Name: $($domainInfo.DNSRoot)"
    Write-Host "Domain SID: $($domainInfo.DomainSID)"
} catch {
    Write-Host "[-] Failed to get domain info. Are you domain joined?" -ForegroundColor Red
}

# 2. Get Domain Controllers
Write-Host "`n[+] Getting Domain Controllers..." -ForegroundColor Green
try {
    $dcs = Get-ADDomainController -Filter *
    foreach ($dc in $dcs) {
        Write-Host "DC: $($dc.HostName) | IP: $($dc.IPv4Address) | OS: $($dc.OperatingSystem)"
    }
} catch {
    Write-Host "[-] Failed to get DCs." -ForegroundColor Red
}

# 3. List Users
Write-Host "`n[+] Listing Users..." -ForegroundColor Green
try {
    $users = Get-ADUser -Filter * -Properties Description, LastLogonDate, PasswordLastSet
    foreach ($user in $users) {
        Write-Host "User: $($user.SamAccountName) | Enabled: $($user.Enabled) | LastLogon: $($user.LastLogonDate)"
        if ($user.Description) {
            Write-Host "  Description: $($user.Description)" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "[-] Failed to list users." -ForegroundColor Red
}

# 4. List Groups
Write-Host "`n[+] Listing Groups..." -ForegroundColor Green
try {
    $groups = Get-ADGroup -Filter *
    foreach ($group in $groups) {
        Write-Host "Group: $($group.Name) | Category: $($group.GroupCategory) | Scope: $($group.GroupScope)"
    }
} catch {
    Write-Host "[-] Failed to list groups." -ForegroundColor Red
}

# 5. List Computers
Write-Host "`n[+] Listing Computers..." -ForegroundColor Green
try {
    $computers = Get-ADComputer -Filter * -Properties OperatingSystem, LastLogonDate
    foreach ($computer in $computers) {
        Write-Host "Computer: $($computer.Name) | OS: $($computer.OperatingSystem) | LastLogon: $($computer.LastLogonDate)"
    }
} catch {
    Write-Host "[-] Failed to list computers." -ForegroundColor Red
}

Write-Host "`n=== Enumeration Complete ===" -ForegroundColor Cyan
