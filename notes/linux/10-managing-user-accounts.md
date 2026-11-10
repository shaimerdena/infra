# Managing User Accounts

> Notes based on Linux Bible and personal learning experiments.

Table of Contents:
- [Managing User Accounts](#managing-user-accounts)
  - [Creating User accounts](#creating-user-accounts)
    - [`useradd`](#useradd)
    - [User defaults](#user-defaults)
      - [`/etc/login.defs`](#etclogindefs)
      - [`/etc/default/useradd`](#etcdefaultuseradd)
      - [Changing default settings](#changing-default-settings)
    - [Skeleton directory](#skeleton-directory)
    - [`usermod`](#usermod)
    - [`userdel`](#userdel)
  - [Group Accounts](#group-accounts)
    - [`groupadd` / `groupmod`](#groupadd--groupmod)
  - [Access Control Lists (ACL)](#access-control-lists-acl)
    - [`setfacl`](#setfacl)
    - [`getfacl`](#getfacl)
    - [Default ACL](#default-acl)
    - [Enabling ACL](#enabling-acl)
  - [Special Permission Bits](#special-permission-bits)
  - [Creating Group Collaboration Directories (SetGID)](#creating-group-collaboration-directories-setgid)

## Creating User accounts
### `useradd`

| Option | Purpose | Example |
|--------|---------|---------|
| `-c "comment"` | Add a description for the user (usually the full name). | `useradd -c "Jake Jackson" jake` |
| `-d <home_dir>` | Set a custom home directory instead of the default `/home/<username>`. | `useradd -d /mnt/homes/jake jake` |
| `-D` | Change the default settings used when creating new users. | `useradd -D` |
| `-e <YYYY-MM-DD>` | Set the account expiration date. | `useradd -e 2029-05-05 jake` |
| `-f <days>` | Set how many days after a password expires before the account is disabled. `-1` means never disable automatically. | `useradd -f 7 jake` |
| `-g <group>` | Set the user's primary group. The group must already exist. | `useradd -g wheel jake` |
| `-G <group1,group2>` | Add the user to one or more supplementary groups. | `useradd -G wheel,sales,tech jake` |
| `-k <skel_dir>` | Use a custom skeleton directory when creating the home directory. Works only with `-m`. | `useradd -m -k /etc/customskel jake` |
| `-m` | Create the user's home directory and copy files from `/etc/skel`. (Default on Fedora/RHEL, not on Ubuntu.) | `useradd -m jake` |
| `-M` | Do not create a home directory. | `useradd -M jake` |
| `-n` | Do not create a new group with the same name as the user. | `useradd -n jake` |
| `-o` | Allow creating a user with a duplicate UID. Must be used with `-u`. | `useradd -o -u 1002 tim` |
| `-p <password>` | Set an encrypted password during account creation. | `useradd -p <encrypted_password> jake` |
| `-s <shell>` | Set the user's default login shell. | `useradd -s /bin/bash jake` |
| `-u <UID>` | Assign a specific user ID instead of using the next available one. | `useradd -u 1793 jake` |

Example:

```bash
$ sudo useradd -c "John Smith" jsmith -g users -G apachi,wheels -s /bin/bash
```

### User defaults

`useradd` reads default settings from: `/etc/login.defs` and `/etc/default/useradd`. These files define how new user accounts are created.

---

#### `/etc/login.defs`

This file contains system-wide defaults, such as:

| Setting | Purpose |
|---------|---------|
| `PASS_MAX_DAYS` | Maximum number of days a password is valid. |
| `PASS_MIN_DAYS` | Minimum number of days before a password can be changed. |
| `PASS_MIN_LEN` | Minimum password length. |
| `PASS_WARN_AGE` | Number of days before password expiration to warn the user. |
| `UID_MIN` / `UID_MAX` | Range of automatically assigned user IDs. |
| `GID_MIN` / `GID_MAX` | Range of automatically assigned group IDs. |
| `CREATE_HOME` | Whether a home directory is created automatically. |

You can change these values by editing the file.

---

#### `/etc/default/useradd`

This file stores default options used by `useradd`.

View current defaults:

```bash
useradd -D
```

Example output:

```text
GROUP=100
HOME=/home
INACTIVE=-1
EXPIRE=
SHELL=/bin/bash
SKEL=/etc/skel
CREATE_MAIL_SPOOL=yes
```

---

#### Changing default settings

Use the `-D` option together with one or more of the following:

| Option | Purpose |
|---------|---------|
| `-b <directory>` | Set the default location for home directories. |
| `-e <YYYY-MM-DD>` | Set the default account expiration date. |
| `-f <days>` | Set the default number of inactive days after password expiration. |
| `-g <group>` | Set the default primary group. |
| `-s <shell>` | Set the default login shell. |

Example:

```bash
useradd -D -b /home/everyone -s /bin/tcsh
```

---

### Skeleton directory

`/etc/skel` contains default files that are copied to a new user's home directory.

Examples:

- `.bashrc`
- `.profile`
- login scripts

---

### `usermod`

Modify an existing user account.

| Option | Purpose | Example |
|---------|---------|---------|
| `-aG <groups>` | Add the user to supplementary groups **without removing existing ones**. | `usermod -aG docker,sudo jake` |
| `-l <login>` | Change the user's login name. | `usermod -l jack jake` |
| `-L` | Lock the user account (disable login without deleting the password). | `usermod -L jake` |
| `-U` | Unlock a locked user account. | `usermod -U jake` |
| `-m` | Move the user's home directory to the new location. Used together with `-d`. | `usermod -d /home/jack -m jack` |
| `-o` | Allow a duplicate UID. Must be used with `-u`. | `usermod -o -u 1002 tim` |

Example:

```bash
usermod -c "John Smith" jsmith
usermod -s /bin/csh jsmith
```

<i> Notes:
- other available options mirror those found in `useradd`, like `c`,`d`,`s`,`e`,`f` and so on.
- always use `aG` instead of just `G`, as it can remove the user from previous group list. </i>
  
### `userdel`

Delete a user account.

| Command | Purpose | Example |
|---------|---------|---------|
| `userdel <user>` | Delete the user account, but keep the home directory. | `userdel chris` |
| `userdel -r <user>` | Delete the user account and remove the home directory. | `userdel -r chris` |

<i> Note: Deleting a user does **not** automatically remove all files they own (unless `-r` removes the home directory). Remaining files keep the old UID as the owner until reassigned. </i>

Useful `find` commands:

| Command | Purpose |
|---------|---------|
| `find / -user <user> -ls` | Find all files owned by a specific user before deleting the account. |
| `find / -uid <UID> -ls` | Find files owned by a specific UID. |
| `find / -nouser -ls` | Find files that are not owned by any existing user. |

## Group Accounts

- Every user has one **primary group**.
- By default, new files and directories belong to the user's primary group (`cipher`).
- A user can also belong to multiple **supplementary groups** (`sales`, `marketing`).
- Supplementary groups provide additional access to files and directories (depending on permissions).
- Only the **root** user can add or remove users from groups.
- The `newgrp <group>` command temporarily changes the current primary group.
- Files created after using `newgrp` are assigned to the new primary group.
- Use `exit` to leave the temporary group session and return to the original primary group.
- A user can become a member of a group temporarily with the `newgrp` command without actually being a member of that group. To do so, root account should give set a group password using `gpasswd`.

### `groupadd` / `groupmod`

| Command | Purpose | Example |
|---------|---------|---------|
| `groupadd <group>` | Create a new group. | `groupadd kings` |
| `groupadd -g <GID> <group>` | Create a group with a specific GID. | `groupadd -g 1325 jokers` |

| Command | Purpose | Example |
|---------|---------|---------|
| `groupmod -g <GID> <group>` | Change the group's GID. | `groupmod -g 330 jokers` |
| `groupmod -n <new_name> <old_name>` | Rename a group. | `groupmod -n jacks jokers` |

<i> Notes:
- New groups are also created automatically when a new user is created (by default).
- Regular groups usually start with GID **1000** (Ubuntu, Fedora, RHEL).
- Use `usermod -aG` or `gpasswd -a` to add users to a group. </i>

## Access Control Lists (ACL)

ACL (Access Control List) provides more flexible permissions than the standard `rwx` model.
<i> Note: The filesystem must support and have ACL enabled. </i>

---

### `setfacl`

Used to **add, modify, or remove** ACL permissions.

| Command | Purpose | Example |
|---------|---------|---------|
| `setfacl -m u:<user>:<perm> <file>` | Add or modify permissions for a user. | `setfacl -m u:jake:rw file.txt` |
| `setfacl -m g:<group>:<perm> <file>` | Add or modify permissions for a group. | `setfacl -m g:developers:rwx project` |
| `setfacl -x u:<user> <file>` | Remove ACL entry for a user. | `setfacl -x u:jake file.txt` |
| `setfacl -x g:<group> <file>` | Remove ACL entry for a group. | `setfacl -x g:developers project` |
| `setfacl -b <file>` | Remove all ACL entries from a file or directory. | `setfacl -b file.txt` |
| `setfacl -R ...` | Apply ACL recursively to a directory and its contents. | `setfacl -R -m g:developers:rwx project/` |

---

### `getfacl`

Display ACL permissions for a file or directory.

| Command | Purpose | Example |
|---------|---------|---------|
| `getfacl <file>` | Show ACL entries of a file. | `getfacl file.txt` |
| `getfacl <directory>` | Show ACL entries of a directory. | `getfacl project/` |

---

<i> Notes:
- ACL extends the standard Linux permission model (`owner`, `group`, `others`).
- ACL is useful when a single user or group needs special permissions without changing the file's owner or group.
</i>

### Default ACL

Default ACL applies **only to directories**.

It defines the default permissions that **newly created files and subdirectories** will inherit. Existing files are **not** affected.

| Command | Purpose | Example |
|---------|---------|---------|
| `setfacl -m d:u:<user>:<perm> <dir>` | Set a default ACL for a user. | `setfacl -m d:u:jake:rw project/` |
| `setfacl -m d:g:<group>:<perm> <dir>` | Set a default ACL for a group. | `setfacl -m d:g:developers:rwx project/` |
| `getfacl <directory>` | View default ACL entries. | `getfacl projects/` |

### Enabling ACL

On modern Ubuntu, Fedora, and RHEL systems, **ext4** and **XFS** filesystems usually have ACL support enabled by default. Manual ACL configuration is mainly needed on older systems or filesystems without ACL enabled by default.

If ACL is **not enabled**, it can be turned on in several ways:

| Method | Purpose |
|---------|---------|
| `/etc/fstab` | Add the `acl` mount option so the filesystem is mounted with ACL support automatically at boot. |
| Filesystem superblock | Set `acl` as a default mount option, so ACL is enabled whenever the filesystem is mounted (automatically or manually). |
| `mount` command | Enable ACL temporarily by adding the `acl` option when mounting the filesystem manually. |

## Special Permission Bits

Special permission bits provide additional behavior for executable files and directories. They can be set with `chmod` using either **numeric** or **symbolic** notation.

Special Permission Bits

| Bit | Symbolic | Description |
|-----|----------|-------------|
| `4` | `u+s` | **SetUID** – an executable file runs with the permissions of its owner instead of the user who started it. |
| `2` | `g+s` | **SetGID** – on directories, new files inherit the directory's group. On executable files, the program runs with the group's permissions. |
| `1` | `o+t` | **Sticky Bit** – on directories, users can delete only their own files (or files owned by root). |

Examples

```bash
chmod u+s program      # SetUID
chmod g+s project/     # SetGID
chmod o+t /tmp         # Sticky Bit

chmod 4755 program
chmod 2775 project/
chmod 1777 /tmp
```

---

<i> Notes 
- `chmod 775` is equivalent to `chmod 0775` (`0` means no special permission bits are set).
- **SetGID** and **Sticky Bit** are commonly used for collaborative directories.
- **SetUID** is mainly used on special executable programs.
</i>

---

**SetUID and SetGID on Executable Files**

Normally, a program runs with the permissions of the user who starts it.

If **SetUID** or **SetGID** is enabled:

- **SetUID** → the program runs with the permissions of the file's **owner**.
- **SetGID** → the program runs with the permissions of the file's **group**.

This allows certain privileged programs (e.g., `su`, `passwd`, `newgrp`) to perform actions that ordinary users cannot perform directly.

## Creating Group Collaboration Directories (SetGID)

Flow:

1. Create a group.

```bash
groupadd sales
```

2. Add users to the group.

```bash
usermod -aG sales mary
```

3. Create a shared directory.

```bash
mkdir /mnt/salestools
```

4. Change the directory's group.

```bash
chgrp sales /mnt/salestools
```

5. Enable the SetGID bit.

```bash
chmod 2775 /mnt/salestools
```

6. Users create files in the shared directory.

Result:

- New files automatically inherit the directory's group (`sales`).
- All group members can collaborate based on the directory's permissions.

---

<i> Notes
- A lowercase `s` in the group's execute position (`rwxrwsr-x`) indicates that the **SetGID** bit is enabled.
- Without SetGID, new files belong to the creator's primary group.
- With SetGID, new files inherit the directory's group.
</i>

---

<br>
<br>
<br>

**The next topic: [Managing Disks and Filesystems](/notes/linux/11-disks-filesystems.md)**