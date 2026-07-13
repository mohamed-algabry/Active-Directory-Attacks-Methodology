# Chapter 13: Trust Attacks

Trust relationships allow users in one domain to access resources in another domain. While trusts are essential for multi-domain and multi-forest environments, they also introduce significant security risks. If an attacker compromises a trusted domain, they may be able to pivot to other trusted domains or forests.

## Forest Trusts

A forest trust is a transitive trust established between two separate Active Directory forests. This allows users in one forest to authenticate to resources in the other forest.

### How it works
- The trust is established using a shared secret (the Trust Key) between the forests.
- When a user from Forest A authenticates to a resource in Forest B, the Domain Controller in Forest A issues a referral ticket (TGT) encrypted with the Trust Key.
- The user presents this referral ticket to the Domain Controller in Forest B, which decrypts it using the Trust Key and issues a Service Ticket (ST) for the resource.

### Exploiting Forest Trusts
If an attacker compromises the Trust Key (e.g., by dumping the `TRUST` account's hash from the Domain Controller), they can forge referral tickets and authenticate to resources in the trusted forest.

```text
# Mimikatz (requires the Trust Key)
mimikatz # kerberos::golden /domain:<SourceForest> /sid:<SourceSID> /rc4:<TrustKey> /sids:<TargetSID>-519 /service:krbtgt /target:<TargetForest> /user:Administrator /ptt
```

## External Trusts

An external trust is a non-transitive trust established between two domains in different forests. This allows users in one domain to access resources in the other domain.

### How it works
- The trust is established using a shared secret (the Trust Key) between the domains.
- The authentication process is similar to a forest trust, but the trust does not flow through other domains.

### Exploiting External Trusts
If an attacker compromises the Trust Key, they can forge referral tickets and authenticate to resources in the trusted domain.

## Parent-Child Trusts

A parent-child trust is a transitive trust automatically established between a parent domain and a child domain within the same forest.

### How it works
- The trust is established using a shared secret (the Trust Key) between the parent and child domains.
- The authentication process is similar to a forest trust.

### Exploiting Parent-Child Trusts
If an attacker compromises the Trust Key, they can forge referral tickets and authenticate to resources in the parent or child domain.

## SID History Abuse

SID History is an attribute that stores the previous Security Identifiers (SIDs) of a user or group. It is used during domain migrations to preserve access to resources.

### How it works
- When a user is migrated from Domain A to Domain B, their old SID from Domain A is added to their `SIDHistory` attribute in Domain B.
- When the user authenticates to a resource in Domain A, the Domain Controller includes the old SID in the ticket, allowing the user to access resources based on their previous group memberships.

### Exploiting SID History
If an attacker has control over the Domain Controller in Domain B, they can add a high-privileged SID (e.g., the Enterprise Admins SID from Domain A) to a user's `SIDHistory` attribute.

```text
# Mimikatz (requires Domain Admin privileges in Domain B)
mimikatz # lsadump::dcsync /domain:DomainB /user:krbtgt
mimikatz # kerberos::golden /user:<User> /domain:DomainB /sid:<DomainBSID> /rc4:<KRBTGT_Hash> /sids:<EnterpriseAdminsSID> /ptt
```

## Trust Exploitation Attack Chains

Trust exploitation attacks often follow these steps:

1. **Compromise a Domain Controller**: Gain access to a Domain Controller in one of the trusted domains.
2. **Extract the Trust Key**: Dump the `TRUST` account's hash using Mimikatz or secretsdump.py.
3. **Forge a Referral Ticket**: Use Mimikatz to forge a referral ticket (TGT) encrypted with the Trust Key.
4. **Authenticate to the Trusted Domain**: Present the forged referral ticket to the Domain Controller in the trusted domain to obtain a Service Ticket (ST) for a resource.
5. **Escalate Privileges**: Use the Service Ticket to access resources and escalate privileges in the trusted domain.

## Cross-Forest Attacks

Cross-forest attacks involve moving from one forest to another using trust relationships.

### Example using Mimikatz

```text
# Mimikatz (using the Trust Key)
mimikatz # kerberos::golden /domain:<SourceForest> /sid:<SourceSID> /rc4:<TrustKey> /sids:<TargetSID>-519 /service:krbtgt /target:<TargetForest> /user:Administrator /ptt
```

### Example using Impacket

```bash
# Using Impacket (interforest.py)
python3 interforest.py -source-dc <SourceDC> -target-dc <TargetDC> -source-domain <SourceDomain> -target-domain <TargetDomain> -trust-ticket <TrustTicket> -user <Username>
```

## Mitigations

### Detection
- **Trust Key Extraction**: Monitor for `lsass.exe` access on Domain Controllers and the use of tools like Mimikatz or secretsdump.py.
- **SID History Modification**: Monitor for modifications to the `SIDHistory` attribute of user or group accounts.
- **Referral Ticket Forging**: Monitor for unusual referral ticket requests or authentication attempts from unexpected source IPs.

### Mitigation
- **Minimize Trusts**: Reduce the number of trust relationships between domains and forests.
- **Disable SID History**: If possible, disable SID History or restrict its use to authorized migrations.
- **Monitor Trust Keys**: Regularly audit and rotate Trust Keys.
- **Forest Isolation**: Consider isolating critical forests to prevent cross-forest attacks.

---
*Trust attacks allow attackers to expand their reach across multiple domains and forests. The next chapter will explore persistence techniques, which allow attackers to maintain access even if their initial foothold is lost.*
