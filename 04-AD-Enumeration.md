# Chapter 4: Active Directory Enumeration

Enumeration is the first critical step in any Active Directory penetration test or red team operation. It involves mapping the network, identifying users, groups, computers, and understanding the relationships between them. A thorough enumeration phase is essential for identifying attack paths and potential targets for exploitation.

## Domain Enumeration

Domain enumeration focuses on gathering high-level information about the domain structure, policies, and trust relationships.

### Discovering the Current Domain

To identify the domain you are currently in and gather basic domain information:

```powershell
# PowerShell
Get-ADDomain | Select-Object Name, NetBIOSName, DomainMode, DomainControllersContainer, DomainSID
```

### Enumerating Domain Controllers

Identifying Domain Controllers (DCs) is crucial because they are the primary targets for privilege escalation.

```powershell
# PowerShell
Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, OperatingSystem, Site, IsGlobalCatalog
```

### Enumerating Trust Relationships

Understanding trust relationships helps in planning cross-domain or cross-forest attacks.

```powershell
# PowerShell
Get-ADTrust -Filter * | Select-Object Name, Direction, TrustType, IsTransitive
```

## User Enumeration

Users are the primary entry points for attackers. Enumerating users helps in identifying targets for phishing, password spraying, or Kerberoasting.

### Listing All Users

```powershell
# PowerShell
Get-ADUser -Filter * -Properties Description, LastLogonDate, PasswordLastSet, Enabled | Select-Object Name, SamAccountName, Description, LastLogonDate, PasswordLastSet, Enabled
```

### Finding Privileged Users

Identifying users in highly privileged groups (e.g., Domain Admins, Enterprise Admins) is critical.

```powershell
# PowerShell
Get-ADGroupMember -Identity "Domain Admins" | Select-Object Name, SamAccountName
Get-ADGroupMember -Identity "Enterprise Admins" | Select-Object Name, SamAccountName
```

### Finding Users with Sensitive Descriptions

Administrators often leave passwords or sensitive information in user descriptions.

```powershell
# PowerShell
Get-ADUser -Filter {Description -like "*"} -Properties Description | Select-Object Name, SamAccountName, Description
```

## Group Enumeration

Groups define permissions and roles within the domain. Enumerating groups helps in understanding the access control model.

### Listing All Groups

```powershell
# PowerShell
Get-ADGroup -Filter * | Select-Object Name, SamAccountName, GroupCategory, GroupScope
```

### Enumerating Nested Groups

Attackers often hide privileged accounts in nested groups to evade detection.

```powershell
# PowerShell
Get-ADGroupMember -Identity "Domain Admins" -Recursive | Select-Object Name, SamAccountName
```

## Computer Enumeration

Computers represent machines joined to the domain. Enumerating computers helps in identifying targets for lateral movement and finding machines running specific services.

### Listing All Computers

```powershell
# PowerShell
Get-ADComputer -Filter * -Properties OperatingSystem, LastLogonDate, Enabled | Select-Object Name, SamAccountName, OperatingSystem, LastLogonDate, Enabled
```

### Finding Servers

Identifying servers (e.g., SQL, IIS, Exchange) is crucial for targeting specific services.

```powershell
# PowerShell
Get-ADComputer -Filter {OperatingSystem -like "*Server*"} -Properties OperatingSystem | Select-Object Name, OperatingSystem
```

## Share Enumeration

Network shares can contain sensitive data or be used for lateral movement (e.g., copying malware).

### Enumerating Shares using PowerShell

```powershell
# PowerShell
Get-NetShare -ComputerName <TargetComputer>
```

## Session Enumeration

Sessions reveal which users are logged into which machines, providing targets for lateral movement (e.g., Pass-the-Ticket, LSASS dumping).

### Enumerating Logged-on Users

```powershell
# PowerShell (using NetWkstaUserEnum API)
Get-NetLoggedon -ComputerName <TargetComputer>
```

### Enumerating Active Sessions

```powershell
# PowerShell (using NetSessionEnum API)
Get-Netsession -ComputerName <TargetComputer>
```

## GPO Enumeration

Group Policy Objects (GPOs) can contain sensitive information (e.g., Group Policy Preferences with passwords) or be misconfigured to allow privilege escalation.

### Listing All GPOs

```powershell
# PowerShell
Get-GPO -All | Select-Object DisplayName, GpoStatus, CreationTime
```

### Finding GPOs with Group Policy Preferences

```powershell
# PowerShell
Get-GPO -All | ForEach-Object {
    $path = "\\$($_.DomainName)\SysVol\$($_.DomainName)\Policies\$($_.Id)\Machine\Preferences\Groups\Groups.xml"
    if (Test-Path $path) {
        Write-Output "Found GPP in GPO: $($_.DisplayName)"
    }
}
```

## LDAP Enumeration

LDAP is the underlying protocol used for AD enumeration. Understanding LDAP queries is essential for advanced enumeration.

### Basic LDAP Queries

```bash
# Using ldapsearch (Linux)
ldapsearch -x -H ldap://<DomainController> -b "DC=example,DC=com" -D "CN=User,CN=Users,DC=example,DC=com" -w "password" "(objectClass=user)" sAMAccountName
```

### PowerShell LDAP Queries

```powershell
# PowerShell
$ldap = New-Object System.DirectoryServices.DirectorySearcher
$ldap.Filter = "(objectClass=user)"
$ldap.FindAll() | ForEach-Object { $_.Properties["sAMAccountName"] }
```

## BloodHound Collection

BloodHound is a tool that uses graph theory to reveal the hidden and often unintended relationships within an Active Directory environment. It is essential for visualizing attack paths.

### Using SharpHound

SharpHound is the official data collector for BloodHound. It gathers data about domain trusts, group memberships, ACLs, and sessions.

```powershell
# PowerShell (SharpHound.ps1)
Invoke-BloodHound -CollectionMethod All -Domain <DomainName> -OutputDirectory C:\Temp\BloodHound
```

### Using the CLI Collector

```bash
# Using SharpHound.exe
SharpHound.exe --collectionmethods All --domain <DomainName> --outputdirectory C:\Temp\BloodHound
```

## PowerView

PowerView is a PowerShell tool to gain network situational awareness on Windows domains. It provides functions for enumerating domains, trusts, users, groups, and more.

### Basic PowerView Commands

```powershell
# PowerShell
Get-DomainController
Get-DomainUser -Identity <Username>
Get-DomainGroup -Identity "Domain Admins"
Get-DomainComputer -Properties dnshostname, operatingsystem
```

## Checklist for AD Enumeration

- [ ] Identify the current domain and domain controllers.
- [ ] Enumerate trust relationships.
- [ ] List all users and identify privileged accounts.
- [ ] Check user descriptions for sensitive information.
- [ ] List all groups and check for nested groups.
- [ ] Enumerate computers and identify servers.
- [ ] Check network shares for sensitive data.
- [ ] Enumerate active sessions and logged-on users.
- [ ] List Group Policy Objects (GPOs) and check for Group Policy Preferences.
- [ ] Run BloodHound/SharpHound to collect data for graph analysis.
- [ ] Perform LDAP queries for advanced enumeration.

---
*Enumeration provides the map of the territory. The next chapter will focus on how to use this map to launch credential attacks and gain initial access.*
