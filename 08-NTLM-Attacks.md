# Chapter 8: NTLM Attacks

NTLM (NT LAN Manager) is a legacy authentication protocol that remains enabled in Windows domains for backward compatibility. Despite its age, NTLM is still heavily exploited by attackers due to its inherent weaknesses, particularly its susceptibility to relay and reflection attacks.

## NTLM Authentication

As covered in Chapter 6, NTLM authentication involves a challenge-response mechanism:
1. **Negotiate**: Client requests NTLM auth.
2. **Challenge**: Server sends a random 8-byte challenge.
3. **Response**: Client encrypts the challenge with the user's NTLM hash and sends it back.
4. **Verification**: Server forwards the challenge and response to the Domain Controller (DC) for verification.

This mechanism is the foundation for several attack vectors.

## NTLM Relay

NTLM Relay is a powerful attack where an attacker intercepts an NTLM authentication request from a victim and relays it to a target server to authenticate as the victim.

### How it works
1. The attacker forces the victim to authenticate to the attacker's machine (e.g., via LLMNR/NBT-NS poisoning or SMB signing bypass).
2. The attacker intercepts the NTLM challenge/response.
3. The attacker relays the challenge/response to a target server (e.g., a file share, LDAP, or HTTP service).
4. If the target server accepts NTLM authentication and the victim has sufficient privileges, the attacker gains access.

### Prerequisites
- **SMB Signing Disabled**: The target server must not enforce SMB signing. If SMB signing is enforced, the attacker cannot relay the authentication to an SMB target.
- **NTLM Auth Enabled**: The target service must accept NTLM authentication.

### Example using Impacket (ntlmrelayx.py)

```bash
# Using Impacket to relay NTLM to an LDAP server
python3 ntlmrelayx.py -t ldap://<TargetDC> -dc-ip <TargetDC> --escalate-user <CompromisedUser>
```

### Example using ntlmrelayx.py to dump secrets

```bash
# Using Impacket to relay NTLM and dump secrets via DCSync
python3 ntlmrelayx.py -t ldap://<TargetDC> --no-http-server -smb2support -c "whoami"
```

## Pass-the-Hash (PtH)

Pass-the-Hash allows an attacker to authenticate to a remote system using the user's NTLM hash, without knowing the plaintext password.

### How it works
- The attacker obtains the user's NTLM hash (e.g., via LSASS dumping).
- The attacker injects the hash into the current session or uses it directly to authenticate to remote services (e.g., SMB, WMI).

### Example using CrackMapExec

```bash
# Using CrackMapExec for PtH
crackmapexec smb <TargetIP> -u <Username> -H <NTLM_Hash>
```

### Example using Impacket (psexec.py)

```bash
# Using Impacket for PtH
python3 psexec.py <Domain>/<Username>@<TargetIP> -hashes :<NTLM_Hash>
```

## SMB Relay

SMB Relay is a specific type of NTLM Relay where the attacker relays the NTLM authentication to an SMB target.

### Prerequisites
- **SMB Signing Disabled**: The target server must not enforce SMB signing.
- **Guest Access Disabled**: The target server should not allow guest access.

### Example using Impacket (smbrelayx.py)

```bash
# Using Impacket to relay NTLM to an SMB target
python3 smbrelayx.py -h <TargetIP> -c "whoami"
```

## LLMNR Poisoning

Link-Local Multicast Name Resolution (LLMNR) is a protocol that allows hosts on the same local link to perform name resolution for other hosts on that link. It is used when DNS fails to resolve a hostname.

### How it works
1. A user attempts to access a non-existent resource (e.g., `\\fileserver\share`).
2. The client sends an LLMNR broadcast asking "Who is fileserver?".
3. The attacker's machine (running Responder or Inveigh) responds, claiming to be `fileserver`.
4. The client attempts to authenticate to the attacker's machine using NTLM.
5. The attacker captures the NTLM hash (or relays it).

### Example using Responder

```bash
# Using Responder on Linux
sudo responder -I eth0 -w -r -d -F
```

### Example using Inveigh

```powershell
# PowerShell (Inveigh)
Invoke-Inveigh -ConsoleOutput Y -IP 192.168.1.100 -NBNS Y -LLMNR Y -DHCPv6 Y -Challenge 0000000000000000
```

## NBT-NS Poisoning

NetBIOS Name Service (NBT-NS) is a legacy protocol similar to LLMNR. It is also susceptible to poisoning attacks where the attacker responds to name resolution requests and forces the client to authenticate.

### Example using Responder

```bash
# Using Responder to poison NBT-NS
sudo responder -I eth0 -w -r -d -F
```

## Detection and Mitigation

### Detection
- **NTLM Relay**: Look for Event ID 4624 (Logon success) with Logon Type 3 (Network) from unexpected source IPs.
- **LLMNR/NBT-NS Poisoning**: Monitor for DNS queries that fail, followed by LLMNR/NBT-NS broadcasts and responses from non-authorized IP addresses.
- **Pass-the-Hash**: Look for Event ID 4624 with Logon Type 3 where the `LogonProcessName` is `Advapi` or `Negotiate`, and the `AuthenticationPackageName` is `NTLM`.

### Mitigation
- **Disable NTLM**: Disable NTLM authentication wherever possible. Use Kerberos instead.
- **Enforce SMB Signing**: Enable SMB signing on all servers to prevent SMB Relay attacks.
- **Disable LLMNR and NBT-NS**: Disable LLMNR and NBT-NS on client machines to prevent poisoning attacks.
- **Use Strong Passwords**: Enforce strong, complex passwords to make captured NTLM hashes harder to crack.

---
*NTLM attacks are versatile and often serve as the initial foothold. The next chapter will focus on how to use these footholds to escalate privileges within the domain.*
