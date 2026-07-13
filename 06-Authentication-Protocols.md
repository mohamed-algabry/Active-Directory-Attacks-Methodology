# Chapter 6: Authentication Protocols

Authentication protocols are the mechanisms by which users and services prove their identity to the Active Directory (AD) environment. The two primary protocols used in Windows domains are Kerberos and NTLM. Understanding how these protocols work is essential for identifying and exploiting their weaknesses.

## Kerberos

Kerberos is the default authentication protocol in Windows Active Directory. It is a ticket-based protocol that relies on symmetric key cryptography. Unlike NTLM, Kerberos does not transmit the user's password or hash over the network during authentication.

### How Kerberos Works

The Kerberos authentication process involves three main parties: the Client, the Key Distribution Center (KDC - which includes the Authentication Service and Ticket Granting Service), and the Service.

1. **AS-REQ / AS-REP (Authentication Service)**:
   - The client requests a Ticket Granting Ticket (TGT) from the Authentication Service (AS) on the Domain Controller.
   - The AS verifies the user's identity using their password hash.
   - If successful, the AS issues a TGT encrypted with the KRBTGT account's hash (which only the DC can decrypt).

2. **TGS-REQ / TGS-REP (Ticket Granting Service)**:
   - The client presents the TGT to the Ticket Granting Service (TGS) to request a Service Ticket (ST) for a specific service (e.g., CIFS, HTTP, MSSQL).
   - The TGS verifies the TGT and issues a Service Ticket encrypted with the service account's hash (e.g., the computer account of the server hosting the service).

3. **AP-REQ / AP-REP (Authentication Protocol)**:
   - The client presents the Service Ticket to the target service.
   - The service decrypts the ticket using its own hash. If successful, the client is authenticated.

### Ticket Concepts

- **Ticket Granting Ticket (TGT)**: Proof of identity issued by the AS. It contains the user's SID, groups, and a session key.
- **Service Ticket (ST)**: Proof of authorization to access a specific service. It contains the user's SID, groups, and a session key.
- **KRBTGT Account**: A special, hidden account in AD used to encrypt TGTs. Compromising the KRBTGT hash allows for the creation of Golden Tickets.

### Kerberos Weaknesses

- **Offline Cracking**: While passwords aren't sent over the network, tickets can be captured and cracked offline (Kerberoasting, AS-REP Roasting).
- **Golden Tickets**: If the KRBTGT hash is compromised, an attacker can forge valid TGTs for any user.
- **Silver Tickets**: If a service account's hash is compromised, an attacker can forge valid Service Tickets for that specific service.

## NTLM (NT LAN Manager)

NTLM is a legacy authentication protocol that remains enabled in Windows domains for backward compatibility and when connecting to non-domain resources. It is significantly less secure than Kerberos and is a primary target for attackers.

### NTLM Authentication Flow

1. **Negotiate**: The client sends a message to the server indicating it wants to authenticate using NTLM.
2. **Challenge**: The server responds with a random 8-byte challenge.
3. **Response**: The client encrypts the challenge using the user's NTLM hash and sends it back to the server.
4. **Verification**: The server forwards the challenge and response to the Domain Controller, which verifies the response using the user's hash stored in AD.

### NTLM Weaknesses

- **Hash Transmission**: The NTLM hash is effectively transmitted over the network (as the response to the challenge). This allows for offline cracking or relay attacks (NTLM Relay).
- **Reflection/Relay**: An attacker can intercept the challenge/response and relay it to another server to authenticate as the user.
- **Weak Cryptography**: NTLM relies on MD4 hashing, which is cryptographically weak.

## LDAP and LDAPS

Lightweight Directory Access Protocol (LDAP) is used to query and modify the Active Directory database. It is not an authentication protocol itself, but it relies on authentication (Kerberos or NTLM) to function.

- **LDAP (Port 389)**: Unencrypted. Vulnerable to eavesdropping and manipulation (e.g., LDAP injection).
- **LDAPS (Port 636)**: LDAP over TLS/SSL. Encrypts the communication channel, protecting against eavesdropping.

## SMB Authentication

Server Message Block (SMB) is a file and printer sharing protocol. It relies on NTLM or Kerberos for authentication.

- **SMB Signing**: A security feature that cryptographically signs SMB packets to prevent man-in-the-middle attacks (e.g., SMB Relay). If SMB signing is not enforced, attackers can relay NTLM hashes.

## Practical Examples

### Extracting a Kerberos Ticket

```powershell
# PowerShell (using Rubeus)
Rubeus.exe asktgt /user:<Username> /password:<Password> /domain:<Domain> /dc:<DomainController> /ptt
```

### Extracting an NTLM Hash

```text
# Mimikatz
mimikatz # sekurlsa::logonpasswords
```

### Forcing NTLM Authentication (SMB Signing Check)

```powershell
# PowerShell
Get-NetSession -ComputerName <TargetComputer>
```

## Protocol Comparison

| Feature | Kerberos | NTLM |
|---------|----------|------|
| **Ticket-Based** | Yes | No |
| **Mutual Authentication** | Yes | No |
| **Delegation Support** | Yes (Constrained/Unconstrained) | No |
| **Vulnerability** | Golden/Silver Tickets, Roasting | Relay, Reflection, Cracking |
| **Default** | Yes (Domain) | No (Fallback/Local) |

---
*Understanding the protocols is the foundation for exploiting them. The next chapter will dive deep into Kerberos-specific attacks.*
