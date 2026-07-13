# Chapter 16: BloodHound

BloodHound is a tool that uses graph theory to reveal the hidden and often unintended relationships within an Active Directory environment. It is an essential tool for penetration testers and red teamers to visualize attack paths, identify privilege escalation opportunities, and understand the overall security posture of the domain.

## BloodHound Fundamentals

BloodHound consists of two main components:
1. **Data Collector (SharpHound)**: A tool that runs on a Windows machine within the domain to collect data about users, groups, computers, GPOs, ACLs, and sessions.
2. **Analyzer (BloodHound GUI)**: A graphical interface that ingests the collected data and allows users to query and visualize the relationships using Cypher queries.

### How it Works
- **Collection**: SharpHound collects data from the Domain Controller and other domain-joined machines.
- **Ingestion**: The collected data (usually a ZIP file containing JSON files) is imported into the BloodHound GUI.
- **Analysis**: The BloodHound GUI uses a Neo4j graph database to store and query the data, allowing for powerful visualization of attack paths.

## Graph Theory

BloodHound relies on graph theory, where entities (nodes) are connected by relationships (edges).

### Nodes
- **User**: Represents a user account in Active Directory.
- **Group**: Represents a group account in Active Directory.
- **Computer**: Represents a computer account in Active Directory.
- **Domain**: Represents an Active Directory domain.
- **GPO**: Represents a Group Policy Object.

### Edges
- **MemberOf**: Indicates that a node is a member of a group.
- **HasSession**: Indicates that a user has an active session on a computer.
- **AdminTo**: Indicates that a user has local administrator privileges on a computer.
- **CanRDP**: Indicates that a user can Remote Desktop into a computer.
- **ExecuteDCOM**: Indicates that a user can execute DCOM on a computer.
- **AllowedToDelegate**: Indicates that a user or computer is trusted for delegation.
- **Owns**: Indicates that a user owns an object.
- **WriteDacl**: Indicates that a user can modify the Discretionary Access Control List (DACL) of an object.
- **WriteOwner**: Indicates that a user can change the owner of an object.

## Attack Path Analysis

BloodHound's primary strength is its ability to identify attack paths—sequences of actions that allow an attacker to move from a low-privileged user to a high-privileged target (e.g., Domain Admins).

### Shortest Path to Domain Admins
BloodHound can automatically calculate the shortest path from any node to the "Domain Admins" group. This helps attackers identify the most efficient route to compromise the domain.

### Pre-Built Queries
BloodHound comes with several pre-built queries that highlight common attack paths, such as:
- **Find Shortest Paths to Domain Admins**: Shows the quickest way to become a Domain Admin.
- **Find Principals with DCSync Rights**: Identifies users who can extract credentials from the Domain Controller.
- **Find All Computers with Unconstrained Delegation**: Highlights computers that can be used to capture TGTs.

## Privilege Escalation Paths

BloodHound helps identify specific techniques that can be used for privilege escalation.

### ACL Abuse
BloodHound highlights users who have write access to sensitive objects (e.g., `WriteDacl`, `WriteOwner`). This can be used to add users to privileged groups or modify group policies.

### Delegation Abuse
BloodHound identifies users and computers configured for unconstrained or constrained delegation, which can be exploited to impersonate other users.

### Local Admin Abuse
BloodHound shows which users have local admin privileges on which computers, allowing attackers to move laterally and dump credentials.

## Collection Methods

SharpHound offers different collection methods to gather specific types of data.

### Common Collection Methods
- **All**: Collects all available data (default and recommended for comprehensive analysis).
- **Default**: Collects standard data (users, groups, computers, ACLs).
- **Group**: Collects group memberships.
- **LocalAdmin**: Collects local administrator memberships on computers.
- **Session**: Collects active sessions on computers.
- **LoggedOn**: Collects logged-on users on computers.
- **Trusts**: Collects domain trust relationships.
- **ACL**: Collects Access Control Lists for objects.
- **Container**: Collects container information.
- **GPOLocalGroup**: Collects Group Policy Object local group information.

### Example using SharpHound

```powershell
# PowerShell (SharpHound.ps1)
Invoke-BloodHound -CollectionMethod All -Domain <DomainName> -OutputDirectory C:\Temp\BloodHound
```

```bash
# Using SharpHound.exe
SharpHound.exe --collectionmethods All --domain <DomainName> --outputdirectory C:\Temp\BloodHound
```

## Custom Queries (Cypher)

BloodHound uses Cypher, a query language for graph databases, to search and analyze the data. Users can write custom queries to find specific relationships or attack paths.

### Example: Find Users with Admin Rights on Domain Controllers

```cypher
// Cypher
MATCH p=(n:User)-[:AdminTo]->(m:Computer {name: 'DC01.CONTOSO.COM'}) RETURN p
```

### Example: Find Groups with DCSync Rights

```cypher
// Cypher
MATCH p=(n:Group)-[:DCSync]->(m:Domain) RETURN p
```

### Example: Find Users with SPNs (Kerberoasting Targets)

```cypher
// Cypher
MATCH p=(n:User)-[:HasSPN]->(m:Computer) WHERE n.hasspn=true RETURN p
```

## Path Hunting

Path hunting involves manually exploring the BloodHound graph to identify potential attack paths that may not be obvious from the pre-built queries.

### Techniques
- **Starting from a known compromised account**: Use the "Mark User as Owned" feature to trace paths from the compromised account to high-value targets.
- **Exploring specific relationships**: Look for users with `WriteDacl` or `WriteOwner` permissions on privileged groups.
- **Identifying orphaned objects**: Look for objects that are not properly managed or have overly permissive ACLs.

## Case Studies

### Case Study 1: From Standard User to Domain Admin via GPO Abuse

1. **Initial Access**: The attacker compromises a standard user account (User A).
2. **Enumeration**: The attacker uses BloodHound to analyze the domain.
3. **Discovery**: BloodHound reveals that User A has `WriteDacl` permission on a GPO (GPO 1).
4. **Exploitation**: The attacker modifies GPO 1 to include a malicious scheduled task that executes when computers in a specific OU (containing a Domain Controller) reboot.
5. **Privilege Escalation**: The malicious task executes with SYSTEM privileges on the Domain Controller, allowing the attacker to extract the KRBTGT hash and create a Golden Ticket.

### Case Study 2: Lateral Movement via Unconstrained Delegation

1. **Initial Access**: The attacker compromises a standard user account (User B).
2. **Enumeration**: The attacker uses BloodHound to analyze the domain.
3. **Discovery**: BloodHound reveals that Computer C has unconstrained delegation enabled.
4. **Exploitation**: The attacker uses a tool (e.g., printerbug.py) to force the Domain Controller to authenticate to Computer C.
5. **Credential Theft**: The attacker extracts the Domain Controller's TGT from Computer C's memory.
6. **Domain Dominance**: The attacker uses the extracted TGT to perform DCSync and dump all domain credentials.

---
*BloodHound is a powerful tool for visualizing and exploiting Active Directory relationships. The next chapter will focus on detection and defense, exploring how blue teams can monitor and protect against the attacks discussed in this repository.*
