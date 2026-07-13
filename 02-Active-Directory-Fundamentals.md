# Chapter 2: Active Directory Fundamentals

## The Building Blocks of Active Directory

Active Directory (AD) is a hierarchical database that stores information about network resources and provides services to manage them. Understanding the physical and logical structure of AD is critical for both administration and security testing.

### Domain

A domain is the primary security boundary in Active Directory. It is a collection of objects (users, computers, groups) that share a common directory database, security policies, and security relationships with other domains.

- **Key Characteristic**: All Domain Controllers (DCs) within a domain hold a writable replica of the same Active Directory database.
- **Security Boundary**: Security policies (like password policies) can be applied at the domain level.

### Forest

A forest is the top-level container in an Active Directory infrastructure. It represents a collection of one or more domains that share a common schema, configuration, and global catalog.

- **Security Boundary**: The forest is the ultimate security boundary. Trust relationships are established between forests, but policies do not automatically traverse forest boundaries.
- **Schema**: Defines the types of objects and attributes that can exist in the directory.

### Tree

A tree is a hierarchical grouping of domains within a forest. Domains in a tree share a contiguous namespace. For example, `corp.contoso.com` and `us.corp.contoso.com` form a tree because they share the `contoso.com` suffix.

### Organizational Unit (OU)

An Organizational Unit (OU) is a container used to organize objects within a domain. OUs can contain users, computers, groups, and other OUs.

- **Purpose**: OUs are primarily used for applying Group Policy Objects (GPOs) and delegating administrative tasks.
- **Hierarchy**: OUs can be nested to create a structured organizational hierarchy.

### Domain Controller (DC)

A Domain Controller is a server that responds to security authentication requests (logging in, checking permissions) within a Windows domain.

- **Role**: It hosts the Active Directory Domain Services (AD DS) and the Global Catalog.
- **Replication**: DCs replicate changes to the AD database with other DCs in the same domain using the Directory Replication Service (DRS).

### Global Catalog (GC)

The Global Catalog is a distributed data repository that contains a searchable, partial representation of every object in every domain in a multi-domain Active Directory forest.

- **Function**: It allows users to find resources in other domains without needing to query each domain controller individually.
- **Ports**: By default, the GC listens on port 3268 (LDAP) and 3269 (LDAPS).

### FSMO Roles

Flexible Single Master Operation (FSMO) roles are specialized tasks that cannot be performed by any Domain Controller. There are five FSMO roles:

1. **Schema Master**: Controls all updates and modifications to the schema. (Forest-wide)
2. **Domain Naming Master**: Controls the addition or removal of domains from the forest. (Forest-wide)
3. **RID Master**: Allocates pools of unique identifiers (RID) to Domain Controllers. (Domain-wide)
4. **PDC Emulator**: Acts as the primary domain controller, handling password changes and time synchronization. (Domain-wide)
5. **Infrastructure Master**: Updates references from objects in its domain to objects in other domains. (Domain-wide)

### Users, Groups, and Computers

- **Users**: Security principals that represent individuals. They have attributes like `sAMAccountName`, `userPrincipalName`, and `objectSid`.
- **Groups**: Collections of users used to assign permissions and rights collectively. Common groups include `Domain Admins`, `Enterprise Admins`, and `Schema Admins`.
- **Computers**: Security principals representing machines joined to the domain. They have computer accounts with passwords that change automatically.

### Group Policy

Group Policy Objects (GPOs) are used to define and manage the configuration of users and computers within an Active Directory environment. GPOs can enforce security settings, deploy software, and map network drives.

- **Linking**: GPOs can be linked to Sites, Domains, or Organizational Units (OUs).
- **Enforcement**: The order of application is Local -> Site -> Domain -> OU (LSDOU).

### Trust Relationships

Trusts allow users in one domain to access resources in another domain.

- **Transitive Trusts**: If Domain A trusts Domain B, and Domain B trusts Domain C, then Domain A trusts Domain C. (Default for domains in the same forest).
- **Non-Transitive Trusts**: Trust does not flow through. (Default for external trusts between different forests).

### DNS in AD

Active Directory relies heavily on the Domain Name System (DNS) for locating resources.

- **Service Location (SRV) Records**: AD uses SRV records in DNS to locate Domain Controllers.
- **LDAP Query**: Clients query DNS for `_ldap._tcp.dc._msdcs.<domain_name>` to find a DC.

### LDAP

Lightweight Directory Access Protocol (LDAP) is the protocol used to query and modify items in directory service providers like Active Directory.

- **Attributes**: LDAP queries can target specific attributes (e.g., `sAMAccountName`, `description`).
- **Filters**: LDAP filters use syntax like `(attribute=operatorvalue)`. Example: `(objectCategory=person)` to find users.

## AD Architecture

The physical architecture of AD involves the interaction between clients, domain controllers, and the underlying database (Extensible Storage Engine - ESE).

```mermaid
graph TD
    Client[Client Workstation] -->|LDAP / Kerberos| DC1[Domain Controller 1]
    Client -->|LDAP / Kerberos| DC2[Domain Controller 2]
    DC1 <-->|Replication (DRS)| DC2
    DC1 -->|Stores| DB[Active Directory Database (NTDS.dit)]
    DC2 -->|Stores| DB2[Active Directory Database (NTDS.dit)]
```

## Practical Examples

### Enumerating Domain Controllers using PowerShell

To list all domain controllers in the current domain:

```powershell
Get-ADDomainController -Filter * | Select-Object Name, Site, OperatingSystem
```

### Enumerating FSMO Roles

To find the holders of the FSMO roles:

```powershell
Get-ADDomain | Select-Object InfrastructureMaster, RIDMaster, PDCEmulator
Get-ADForest | Select-Object DomainNamingMaster, SchemaMaster
```

### Basic LDAP Query

Using `ldapsearch` (Linux) or PowerShell to find all users:

```powershell
# PowerShell equivalent of an LDAP query
Get-ADUser -Filter * -Properties * | Select-Object Name, sAMAccountName, Description
```

## Diagrams

### AD Hierarchy

```text
Forest
└── Domain (e.g., contoso.com)
    ├── Domain Controllers
    ├── Organizational Units (OUs)
    │   ├── Users
    │   ├── Computers
    │   └── Groups
    └── Policies (GPOs)
```

### Trust Flow

```text
Forest A (trusts) --> Forest B
Forest B (trusts) --> Forest C
Forest A --> Forest C (if transitive)
```

---
*This chapter lays the groundwork for understanding the targets and boundaries in an Active Directory environment. The next chapter will delve into Windows Internals, which is essential for understanding how credentials are stored and processed.*
