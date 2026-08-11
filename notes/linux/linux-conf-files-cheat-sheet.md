# Linux Configuration Files Cheat Sheet

Table of Contents:
- [Linux Configuration Files Cheat Sheet](#linux-configuration-files-cheat-sheet)
- [User Configuration (`$HOME`)](#user-configuration-home)
- [System Configuration (`/etc`)](#system-configuration-etc)
  - [Users \& Authentication](#users--authentication)
  - [Filesystems \& Storage](#filesystems--storage)
  - [Networking](#networking)
  - [Scheduled Tasks](#scheduled-tasks)
  - [Services](#services)
  - [Logging](#logging)
  - [Mail](#mail)
  - [Printing](#printing)
  - [Shells](#shells)
  - [Legacy](#legacy)
- [Must Know](#must-know)
- [Useful Commands](#useful-commands)
 

> Legend:
>
> - 🟢 Must Know — используется постоянно
> - 🟡 Good to Know — полезно знать
> - 🔴 Legacy — устаревшее или редко используется

---

# User Configuration (`$HOME`)

| File / Directory | Priority | Purpose |
|------------------|:-------:|---------|
| `~/.bashrc` | 🟢 | Bash configuration (aliases, PATH, prompt, environment variables). Loaded for interactive shells. |
| `~/.profile` | 🟢 | Executed when the user logs in. Initializes the user environment. |
| `~/.ssh/` | 🟢 | SSH keys and SSH client configuration. |
| `~/.config/` | 🟡 | Configuration files for desktop applications. |

---

# System Configuration (`/etc`)

## Users & Authentication

| File | Priority | Purpose |
|------|:-------:|---------|
| `/etc/passwd` | 🟢 | User accounts (username, UID, GID, home directory, shell). |
| `/etc/shadow` | 🟢 | Encrypted user passwords. |
| `/etc/group` | 🟢 | Groups and group memberships. |
| `/etc/gshadow` | 🟡 | Encrypted group passwords. |
| `/etc/sudoers` | 🟢 | Defines who can use `sudo`. |
| `/etc/shells` | 🟡 | List of valid login shells. |
| `/etc/profile` | 🟢 | System-wide login environment. |
| `/etc/bashrc` | 🟢 | System-wide Bash configuration. |

---

## Filesystems & Storage

| File | Priority | Purpose |
|------|:-------:|---------|
| `/etc/fstab` | 🟢 | Filesystems mounted automatically during boot. |
| `/etc/mtab` | 🟡 | Currently mounted filesystems. |

---

## Networking

| File | Priority | Purpose |
|------|:-------:|---------|
| `/etc/hostname` | 🟢 | System hostname. |
| `/etc/hosts` | 🟢 | Local hostname ↔ IP mappings. |
| `/etc/resolv.conf` | 🟢 | DNS resolver configuration. |
| `/etc/services` | 🟢 | TCP/UDP service names and port numbers. |
| `/etc/nsswitch.conf` | 🟡 | Specifies where Linux looks up users, groups, hostnames, etc. |
| `/etc/protocols` | 🟡 | Internet protocol numbers. |
| `/etc/rpc` | 🔴 | RPC service definitions. |

---

## Scheduled Tasks

| File | Priority | Purpose |
|------|:-------:|---------|
| `/etc/crontab` | 🟢 | System-wide scheduled tasks (cron jobs). |

---

## Services

| File | Priority | Purpose |
|------|:-------:|---------|
| `/etc/systemd/` | 🟢 | Systemd service configuration. |
| `/etc/exports` | 🟡 | NFS shared directories. |
| `/etc/named.conf` | 🟡 | BIND (DNS server) configuration. |
| `/etc/ntp.conf` | 🟡 | NTP time synchronization configuration. |
| `/etc/xinetd.conf` | 🔴 | xinetd configuration. |
| `/etc/xinetd.d/` | 🔴 | xinetd service definitions. |

---

## Logging

| File | Priority | Purpose |
|------|:-------:|---------|
| `/etc/rsyslog.conf` | 🟢 | System logging configuration. |

---

## Mail

| File | Priority | Purpose |
|------|:-------:|---------|
| `/etc/aliases` | 🔴 | Mail aliases. |
| `/etc/postfix/` | 🟡 | Postfix mail server configuration. |

---

## Printing

| File | Priority | Purpose |
|------|:-------:|---------|
| `/etc/cups/` | 🔴 | CUPS printer configuration. |
| `/etc/printcap` | 🔴 | Legacy printer configuration. |

---

## Shells

| File | Priority | Purpose |
|------|:-------:|---------|
| `/etc/bashrc` | 🟢 | System-wide Bash settings. |
| `/etc/profile` | 🟢 | Executed during login. |
| `/etc/csh.cshrc` | 🔴 | C Shell configuration. |

---

## Legacy

| File | Priority | Purpose |
|------|:-------:|---------|
| `/etc/inittab` | 🔴 | Old SysV init configuration (replaced by systemd). |
| `/etc/mtools.conf` | 🔴 | DOS utilities configuration. |

---

# Must Know

User Management

- `/etc/passwd`
- `/etc/shadow`
- `/etc/group`
- `/etc/sudoers`

Shell

- `~/.bashrc`
- `~/.profile`
- `/etc/profile`

Networking

- `/etc/hostname`
- `/etc/hosts`
- `/etc/resolv.conf`
- `/etc/services`

Filesystems

- `/etc/fstab`

Services

- `/etc/systemd/`

SSH

- `~/.ssh/`

---

# Useful Commands

User Information

```bash
cat /etc/passwd
cat /etc/group
cat /etc/shadow
```

Networking

```bash
cat /etc/hostname
cat /etc/hosts
hostname
hostnamectl
```

Storage

```bash
cat /etc/fstab
mount
findmnt
```

Services

```bash
systemctl status
systemctl start
systemctl stop
systemctl restart
systemctl enable
systemctl disable
```

Scheduled Tasks

```bash
crontab -l
crontab -e
```