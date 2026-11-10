# System Administration

> Notes based on Linux Bible and personal learning experiments.

Table of Contents:
- [System Administration](#system-administration)
  - [Understanding System Administration](#understanding-system-administration)
    - [Gaining admin access](#gaining-admin-access)
    - [Responsibilities of a Linux System Administrator](#responsibilities-of-a-linux-system-administrator)
  - [Using the Root Account](#using-the-root-account)
    - [`su` command](#su-command)
    - [`sudo` command](#sudo-command)
      - [Common Rules](#common-rules)
      - [Using `sudo`](#using-sudo)
    - [`su` vs `sudo`](#su-vs-sudo)
  - [Admin commands, config files and logs](#admin-commands-config-files-and-logs)
    - [Admin commands](#admin-commands)
      - [Common Administrative Commands](#common-administrative-commands)
      - [Installing Your Own Commands](#installing-your-own-commands)
    - [Admin Configuration Files](#admin-configuration-files)
    - [Admin Log files and systemd journal](#admin-log-files-and-systemd-journal)
      - [`journalctl` command](#journalctl-command)
      - [`rsyslog`](#rsyslog)
  - [Using other admin accounts](#using-other-admin-accounts)
  - [Checking and Configuring Hardware](#checking-and-configuring-hardware)
    - [Checking the Hardware](#checking-the-hardware)
      - [View Kernel Messages `dmesg`](#view-kernel-messages-dmesg)
      - [View Boot and Kernel Logs `journalctl`](#view-boot-and-kernel-logs-journalctl)
      - [List PCI Devices `lspci`](#list-pci-devices-lspci)
      - [List USB Devices `lsusb`](#list-usb-devices-lsusb)
      - [Display CPU Information `lscpu`](#display-cpu-information-lscpu)
    - [Managing Removable Hardware in Linux CLI](#managing-removable-hardware-in-linux-cli)
      - [View Connected Storage Devices](#view-connected-storage-devices)
      - [Mount a USB Drive](#mount-a-usb-drive)
    - [Working with Loadable Kernel Modules](#working-with-loadable-kernel-modules)
      - [Listing Loaded Kernel Modules](#listing-loaded-kernel-modules)
        - [List Loaded Modules `lsmod`](#list-loaded-modules-lsmod)
        - [`modinfo` — View Module Information](#modinfo--view-module-information)
      - [Loading modules](#loading-modules)
      - [Removing modules](#removing-modules)
        - [Remove a Module `rmmod`](#remove-a-module-rmmod)
        - [Remove a Module with Dependencies `modprobe -r`](#remove-a-module-with-dependencies-modprobe--r)

## Understanding System Administration

System administration is the process of managing and maintaining computer systems, including hardware, software, and networks. It involves a variety of tasks, such as installing and configuring software, monitoring system performance, and troubleshooting issues.

Key responsibilities of a system administrator include:

- User management: Creating and managing user accounts, permissions, and access controls.
- System monitoring: Keeping an eye on system performance, resource usage, and security logs.
- Backup and recovery: Implementing backup solutions and ensuring data can be restored in case of failure.
- Security: Applying security patches, configuring firewalls, and monitoring for unauthorized access.
- Documentation: Maintaining clear and up-to-date documentation for systems and procedures.

### Gaining admin access

Linux administrators usually **log in as a regular user** and only obtain administrator (root) privileges when necessary.

| Method | Description | Best Use |
|--------|-------------|----------|
| `su` | Switches to another user (usually `root`) and opens a **root shell**. You can execute multiple administrative commands until you exit the shell. | Long administrative sessions. |
| `sudo` | Executes **one command** with root privileges, then returns to the regular user. | Safer for everyday administration. |
| **Cockpit** | A **web-based administration interface** for managing Linux systems (storage, networking, users, services, monitoring, etc.). | Remote system administration through a browser. |
| **Graphical Tools** | Older GUI administration tools (`system-config-*`). Mostly deprecated in modern Fedora/RHEL, but still available in some older versions. | Legacy systems. |

### Responsibilities of a Linux System Administrator

A system administrator is responsible for configuring, maintaining, and securing the Linux system.

| Area | Responsibilities |
|------|------------------|
| **Filesystems** | Manage storage, partitions, and filesystem layout. Create backups. Access and manage any user's files when necessary. |
| **Software Installation** | Install, update, and remove software available to all users. Prevent unauthorized or malicious software installation. |
| **User Accounts** | Create, modify, and delete user and group accounts. Manage user permissions. |
| **Network Interfaces** | Configure network connections and interfaces. Manage wired and wireless networking. |
| **Servers** | Install, configure, start, stop, and maintain services such as web, mail, DNS, and file servers. |
| **Security** | Configure firewalls, access control, monitor system activity, and protect system resources from misuse or attacks. |

<i> Notes: 
- Regular users can install software only in their own directories (if permitted).
- Server processes often run under dedicated service accounts (e.g., `apache`, `rpc`) instead of `root` for better security.
- The root user has full access to all files and system resources.
</i>

## Using the Root Account

The root account is the superuser in Linux, with unrestricted access to all commands and files. It is used for system administration tasks that require elevated privileges.

After logging in as the **root** user:
- **Home directory:** `/root`
- **Default shell:** `/bin/bash`

The root user's information is stored in the **`/etc/passwd`** file.

Example:

```text
root:x:0:0:root:/root:/bin/bash
```

| Field | Value | Description |
|--------|-------|-------------|
| Username | `root` | User name |
| Password | `x` | Password is stored in `/etc/shadow` (encrypted) |
| UID | `0` | User ID (root) |
| GID | `0` | Primary group ID (root group) |
| Comment | `root` | User description |
| Home directory | `/root` | Root user's home directory |
| Login shell | `/bin/bash` | Default shell |

<i> Notes:
- The **encrypted password** is stored in **`/etc/shadow`**, not in `/etc/passwd`.
- Although you **can** edit `/etc/passwd` manually, it is **recommended** to use commands like **`usermod`** to change a user's home directory or login shell.
- type `exit` to log out of the root account and return to your regular user account.
</i>

### `su` command

The **`su` (switch user)** command allows you to switch to another user (by default, `root`) without logging out.

```bash
su [options] [username]
```

| Command | Description |
|---------|-------------|
| `su` | Switch to the root user **without** loading the root user's environment. |
| `su -` | Switch to the root user **and load** the root user's login environment (recommended). |
| `su - username` | Switch to another user's account and load their environment. |

---

`su` vs `su -`

| `su` | `su -` |
|------|---------|
| Changes user only | Changes user **and** loads their environment |
| Keeps current working directory | Changes to the user's home directory |
| Keeps current environment variables | Loads the new user's environment variables (e.g., `PATH`) |
| May cause `command not found` errors | Behaves like a normal login |

<i> Notes:

- `su` requires the **target user's password**.
- If you're already **root**, you can switch to another user without entering a password.
- Exit the root shell with:
  ```bash
  exit
  ```
  or press **Ctrl + D**.

- Never leave an open **root shell** unattended on a shared computer.
</i>

### `sudo` command

`sudo` allows a regular user to execute commands with **root privileges** without logging in as the root user.

What `sudo` can do?

- Run **any command** as root.
- Allow only **specific commands** to be executed as root.
- Use the **user's own password** instead of the root password.
- Optionally allow commands **without asking for a password** (`NOPASSWD`).
- Log **which user** executed administrative commands.

<i> Note: Unlike `su`, `sudo` records exactly **who** ran each command. </i>

---

<strong> Configuration </strong>

Administrative permissions are configured in: `/etc/sudoers`

Always edit this file using:

```bash
visudo
```

<strong> Why `visudo`? </strong>

- Locks the file to prevent simultaneous edits.
- Checks the syntax before saving.
- Prevents breaking the `sudoers` configuration.

---

#### Common Rules

Give a user full sudo privileges - `joe ALL=(ALL) ALL`

Meaning:

- **joe** → user
- **ALL** → any host
- **(ALL)** → can act as any user
- **ALL** → may run any command

---

Allow sudo without a password - `joe ALL=(ALL) NOPASSWD: ALL`

---

#### Using `sudo`

```bash
sudo apt update
sudo systemctl restart nginx
sudo useradd alice
```

The user enters **their own password**, not the root password.

---

<strong> Password Timeout </strong>

After entering the password once, `sudo` remembers it for a short period.

- **Fedora/RHEL:** 5 minutes (default)
- **Ubuntu:** configurable in `/etc/sudoers`

---

### `su` vs `sudo`

| `su` | `sudo` |
|------|---------|
| Switches to another user (usually `root`) | Runs **one command** as root |
| Requires the **root password** | Requires the **current user's password** |
| Opens a root shell | Returns to the normal user after the command finishes |
| Does not record which user executed commands | Logs which user executed each command |
| Better for long administrative sessions | Better for everyday administration |


## Admin commands, config files and logs 

### Admin commands

Administrative commands are mainly used by the **root user** or users with **`sudo` privileges**.

| Directory | Purpose |
|-----------|---------|
| `/usr/sbin` | Contains most **system administration commands** (user management, services, networking, system configuration, etc.). |
| `/sbin` | Usually a symbolic link to `/usr/sbin` on modern Linux distributions. |

<i> Notes: In modern Ubuntu, Fedora, and RHEL, most administrative commands are located in **`/usr/sbin`**. </i>

---

#### Common Administrative Commands

| Command | Purpose |
|---------|---------|
| `useradd` | Create a new user |
| `usermod` | Modify a user |
| `userdel` | Delete a user |
| `passwd` | Change a user's password |
| `mount` | Mount a filesystem |
| `umount` | Unmount a filesystem |
| `systemctl` | Manage system services |
| `shutdown` | Shut down or reboot the system |

---

<strong> Manual Pages </strong>

Administrative commands are usually documented in **Section 8** of the Linux manual.

```bash
man 8 command
```

Example:

```bash
man 8 useradd
```

---

#### Installing Your Own Commands

If you create your own administrative scripts or install third-party tools, common locations are:

| Directory | Purpose |
|-----------|---------|
| `/usr/local/bin` | User-installed executable programs |
| `/usr/local/sbin` | User-installed administrative commands |
| `/opt` | Optional third-party applications |

These directories are usually included in the system's `PATH`.

### Admin Configuration Files

Main configuration locations:

| Directory | Purpose |
|-----------|---------|
| `~/` (Home directory) | User-specific configuration files. |
| `/etc` | System-wide configuration files used by the operating system and services. |

**Cheat sheet for common configuration files: [Linux Configuration Files Cheat Sheet](linux-conf-files-cheat-sheet.md)**

### Admin Log files and systemd journal

Log files record events that occur in the operating system.

They are useful for:

- Troubleshooting errors
- Debugging applications and services
- Monitoring system activity
- Detecting security issues

---

**Logging Systems**

| Tool | Purpose | Status |
|------|---------|--------|
| `journalctl` | View logs collected by **systemd journal**. The boot process, the kernel, and all systemd-managed services direct their status and error messages to the systemd journal. | 🟢 Modern (recommended) |
| `rsyslogd` | Traditional Linux logging daemon | 🟡 Still widely used |
| `syslogd` | Older logging daemon | 🔴 Legacy |

<i> Notes: Modern Linux distributions (Ubuntu, Fedora, RHEL) primarily use **systemd journal**. </i>

---

#### `journalctl` command

The `journalctl` command is used to view logs collected by **systemd journal**.

| Command | Description |
|---------|-------------|
| `journalctl` | Show all logs. |
| `journalctl -n 20` | Show the last 20 log entries. |
| `journalctl -f` | Follow new log messages in real time (like `tail -f`). |
| `journalctl -b` | Show logs from the current boot. |
| `journalctl --list-boots` | List all recorded system boots. |
| `journalctl -b <BOOT_ID>` | Show logs from a specific boot. |
| `journalctl -k` | Show only kernel messages. |
| `journalctl -u ssh.service` | Show logs for a specific service. |
| `journalctl PRIORITY=0` | Show only messages with a specific priority (0–7). |
| `journalctl -a` | Display all available fields (don't truncate output). |
| `journalctl -a -f` | Follow logs in real time and display all fields. |

---

Log Priorities

| Priority | Meaning |
|:-------:|---------|
| `0` | Emergency |
| `1` | Alert |
| `2` | Critical |
| `3` | Error |
| `4` | Warning |
| `5` | Notice |
| `6` | Informational |
| `7` | Debug |

---

Most Useful Commands (Daily Use)

```bash
journalctl              # All logs
journalctl -n 20        # Last 20 logs
journalctl -f           # Follow logs in real time
journalctl -b           # Current boot
journalctl -k           # Kernel logs
journalctl -u nginx     # Logs for nginx service
journalctl -u ssh       # Logs for SSH service
journalctl -p err       # Only error messages
```

<i> Tip: When troubleshooting a service, a common workflow is:

```bash
systemctl status nginx
journalctl -u nginx -n 30
```

First check the service status, then inspect its most recent logs. 
</i>

#### `rsyslog`

`rsyslog` is a logging daemon that collects system and application log messages.

It can:

- Store logs in files.
- Forward logs to remote log servers.
- Filter and organize log messages.

<i> Note: Modern Linux systems often use **`systemd-journald`** together with **`rsyslog`**. </i>

---

Configuration

| File | Purpose |
|------|---------|
| `/etc/rsyslog.conf` | Main `rsyslog` configuration file. |

---

Common Log Files

| File | Purpose |
|------|---------|
| `/var/log/boot.log` | Boot process messages. |
| `/var/log/messages` | General system messages. |
| `/var/log/secure` | Authentication and security-related events. |

---

<i> Notes:

- `journalctl` reads logs from **systemd journal**.
- `rsyslog` stores logs in **text files** (usually in `/var/log`).
- Many enterprise Linux systems use **both** `journald` and `rsyslog`.
</i>

## Using other admin accounts

Linux has special **system accounts** used by services and daemon processes.

These accounts are mainly created to:

- Own files and directories related to a service.
- Run service processes.
- Limit the permissions available to each service.
- Improve system security.

---

**Security Principle**

Services usually run as separate users instead of `root`.

For example:

```text
Apache → www-data
Postfix → postfix
Chrony → chrony
```

If one service is compromised, the attacker receives only the limited permissions of that service account rather than full root access. This follows the **Principle of Least Privilege**: each service should receive only the permissions it needs.

---

**Common Examples**

| System User | Service / Purpose |
|---|---|
| `root` | Superuser with full system access |
| `www-data` | Runs Apache web server processes on Ubuntu |
| `apache` | Runs Apache (`httpd`) processes on RHEL/Fedora |
| `postfix` | Runs the Postfix mail service |
| `chrony` | Runs the `chronyd` time synchronization service |
| `lp` | Owns files related to printing services |
| `avahi` | Runs the Avahi network service |

**Login Restrictions**

System accounts are generally **not intended for interactive login**. Their login shell is often: `/usr/sbin/nologin` or `/bin/false`. These shells prevent users from logging in to the account normally.
A regular user usually has a real shell: `/bin/bash`.

<i> Note: System accounts exist mainly for: `Service → Process → Limited System User → Required Resources`. They are not regular accounts intended for people. </i>

## Checking and Configuring Hardware

Linux automatically detects and manages most hardware devices.

**Udev**

**Udev** is a Linux subsystem that:

- Detects devices when they are connected or removed.
- Dynamically creates and removes device interfaces.
- Assigns names to devices.

For example:

```text
Connect USB drive
        ↓
Linux kernel detects it
        ↓
Udev identifies the device
        ↓
Device becomes available to the system
```

**Hardware Management Features:**

- **Automatic:** Linux detects most hardware and loads the necessary drivers automatically.
- **Dynamic:** Removable devices can be connected and disconnected while the system is running.
- **Flexible:** Users can configure what happens when a device is connected.

Hardware administration includes:

- Viewing hardware information.
- Managing removable devices.
- Loading and managing hardware drivers.

### Checking the Hardware

When Linux boots:

1. The **kernel detects hardware**.
2. The kernel loads the necessary **drivers**.
3. Hardware and driver information is recorded in **kernel messages**.

These messages can be used to troubleshoot hardware and driver problems.

---

#### View Kernel Messages `dmesg`

Displays messages generated by the kernel, including:

- Detected hardware
- Loaded drivers
- CPU and memory information
- Connected or disconnected devices
- Hardware and driver errors

Examples:

* View the output page by page: `dmesg | less`
* Show the latest kernel messages: `dmesg | tail`
* Follow new kernel messages in real time: `dmesg -w`
 
<i> Note: `dmesg` is useful when troubleshooting hardware, drivers, USB devices, disks, and other kernel-related problems. </i>

---

#### View Boot and Kernel Logs `journalctl`

| Command | Purpose |
|---|---|
| `journalctl -b` | Show all logs from the current boot |
| `journalctl -b -1` | Show logs from the previous boot |
| `journalctl -k` | Show kernel messages |
| `journalctl -k -b` | Show kernel messages from the current boot |
| `journalctl -f` | Follow new journal messages in real time |

---

#### List PCI Devices `lspci`

Displays devices connected through the **PCI bus**, such as:

- Network controllers
- Ethernet adapters
- Graphics cards
- Audio controllers
- Storage controllers

Examples: 
* Show more detailed information: `lspci -v`
* Show very detailed information: `lspci -vvv`

---

#### List USB Devices `lsusb`

Displays connected USB devices, such as:

- Keyboards
- Mice
- USB flash drives
- Bluetooth adapters
- Webcams

Show more details: `lsusb -v`

---

#### Display CPU Information `lscpu`

Displays information about the processor, including:

- CPU architecture
- Number of CPUs
- Number of cores
- Number of threads
- CPU model
- Virtualization support

---

### Managing Removable Hardware in Linux CLI

When removable hardware such as a USB flash drive is connected, Linux detects and prepares the device automatically.

**Device Detection Process:**

```text
USB device is connected
          ↓
Kernel detects the hardware
          ↓
Kernel loads the required driver
          ↓
systemd-udevd receives an event from the kernel
          ↓
Udev creates device files in /dev
```

For example:

```text
/dev/sdb     → the entire USB drive
/dev/sdb1    → the first partition on the USB drive
```

<i> Note: Device files in `/dev` are interfaces used by Linux to communicate with hardware. They do not directly contain the files stored on the device. </i>

---

#### View Connected Storage Devices

`lsblk` displays storage devices, their partitions, sizes, and mount points.

Example:

```text
NAME   SIZE TYPE MOUNTPOINTS
sda    32G  disk
└─sda1 32G  part  /
sdb    16G  disk
└─sdb1 16G  part
```

In this example:

- `/dev/sda` — the system disk.
- `/dev/sda1` — the system partition mounted at `/`.
- `/dev/sdb` — the USB drive.
- `/dev/sdb1` — a partition on the USB drive.

---

#### Mount a USB Drive

In a CLI environment, a removable filesystem may need to be mounted manually.

1. Create a mount point

```bash
sudo mkdir -p /mnt/usb
```

A **mount point** is a directory through which the files on a device become accessible.

2. Mount the filesystem

```bash
sudo mount /dev/sdb1 /mnt/usb
```

The USB files are now accessible through:

```bash
ls /mnt/usb
```

Process:

```text
USB drive
     ↓
/dev/sdb1
     ↓ mount
/mnt/usb
     ↓
Files become accessible
```

---

3. Unmount a USB Drive

Before physically disconnecting the device, unmount its filesystem:

```bash
sudo umount /mnt/usb
```

You can also unmount it using the device name:

```bash
sudo umount /dev/sdb1
```

<i> Notes:
- The command is `umount`, not `unmount`.
- Unmounting ensures that pending write operations are completed and the filesystem is safely detached.
- After successful unmounting, the USB drive can be disconnected.
</i>

---

**Useful Commands**

| Command | Purpose |
|---|---|
| `lsblk` | List storage devices, partitions, and mount points |
| `dmesg \| tail` | Show recent kernel messages about connected hardware |
| `dmesg -w` | Follow new kernel messages in real time |
| `journalctl -f` | Follow new system journal messages |
| `sudo mkdir -p /mnt/usb` | Create a mount point |
| `sudo mount /dev/sdb1 /mnt/usb` | Mount a USB filesystem |
| `ls /mnt/usb` | View files stored on the mounted USB drive |
| `sudo umount /mnt/usb` | Unmount the filesystem safely |

---

### Working with Loadable Kernel Modules

Kernel module is a piece of code that can be dynamically loaded into or removed from the running Linux kernel to add functionality, such as hardware driver support.

Linux usually detects hardware and loads the required **kernel modules** automatically. However, if a device is not detected or does not work correctly, an administrator may need to load the appropriate module manually.

Kernel modules are stored in: `/lib/modules/`. Inside this directory, modules are organized by **kernel version**. Each kernel version has its own set of compatible modules.

For example: `/lib/modules/6.15.9-201.fc42.x86_64/`

Linux provides commands to:

- list currently loaded modules;
- load modules into the running kernel;
- unload modules that are no longer needed;
- view information about modules.

Modules can be loaded and unloaded while Linux is running, without rebuilding the kernel or rebooting the system.

#### Listing Loaded Kernel Modules

##### List Loaded Modules `lsmod`

The `lsmod` command displays kernel modules that are currently loaded into the running Linux kernel.

Example:

```text
Module       Size      Used by
e1000e       356352    0
nf_nat       61440     3
```

| Column | Description |
|---|---|
| `Module` | Name of the loaded kernel module |
| `Size` | Size of the module in memory (bytes) |
| `Used by` | Number of components using the module and, when available, their names |

<i> Note: `lsmod` shows only modules that are currently loaded, not every module installed on the system.</i>

---

##### `modinfo` — View Module Information

The `modinfo` command displays detailed information about a kernel module.

```bash
modinfo module_name
```

Example:

```bash
modinfo e1000
```

Possible information includes:

- module description;
- author;
- module file location;
- license;
- supported devices;
- module parameters.

---

**Useful Options**

| Command | Purpose |
|---|---|
| `modinfo -d e1000` | Show the module description |
| `modinfo -a e1000` | Show the module author |
| `modinfo -n e1000` | Show the path to the module file |

Example:

```bash
modinfo -d e1000
```

Output:

```text
Intel(R) PRO/1000 Network Driver
```

<i> Note: Some modules may not contain a description or author information. </i>

#### Loading modules

**Why Load a Module Manually?**

A module may be loaded manually when:

- Linux does not automatically detect the required hardware or driver.
- A kernel feature is needed temporarily.
- Support for a particular filesystem or device is required.

---

The `modprobe` command loads an installed module into the running Linux kernel.

```bash
sudo modprobe module_name
```

Example:

```bash
sudo modprobe parport
```

The module must already be installed in the directory for the current kernel version:

```text
/lib/modules/<kernel-version>/
```

---

**Loading a Module with Parameters**

Some modules accept additional configuration parameters when they are loaded.

```bash
sudo modprobe module_name parameter=value
```

Example:

```bash
sudo modprobe parport_pc io=0x3bc irq=auto
```

In this example:

- `parport_pc` — the module being loaded.
- `io=0x3bc` — specifies the device’s I/O address.
- `irq=auto` — tells Linux to detect the IRQ automatically.

---

**Temporary Loading**

Modules loaded using `modprobe` are active only during the current system session:

```text
modprobe
    ↓
Module is loaded into the running kernel
    ↓
Module remains active during the current boot
    ↓
System reboots
    ↓
The manual loading is not automatically repeated
```

To load a module automatically after every boot, it must be added to the system’s module-loading configuration.

<i> Note: On modern Linux systems, modules that should load at boot are usually listed in files inside `/etc/modules-load.d/`, rather than by placing `modprobe` commands in startup scripts. </i>

#### Removing modules

Kernel modules can be removed from the **running kernel** when they are no longer needed.

##### Remove a Module `rmmod`

```bash
sudo rmmod module_name
```

Example:

```bash
sudo rmmod parport_pc
```

The module will be removed only if it is **not currently in use**.

If the module is busy:

- a process may be using the related device;
- another kernel module may depend on it.

In this case, stop the process or service using the module and try again.

<i> Note: Removing a module unloads it from the running kernel. It does not delete the module file from `/lib/modules/`. </i>

---

**Built-in Modules**

Some modules are compiled directly into the Linux kernel and cannot be unloaded.

Example:

```bash
sudo rmmod usbcore
```

Possible output:

```text
rmmod: ERROR: Module usbcore is builtin
```

A **built-in module** is a permanent part of the running kernel rather than a separately loaded module.

---

##### Remove a Module with Dependencies `modprobe -r`

```bash
sudo modprobe -r module_name
```

Example:

```bash
sudo modprobe -r parport_pc
```

Unlike `rmmod`, `modprobe -r` can also remove related dependency modules that are no longer needed or used by anything else.

---

**`rmmod` vs `modprobe -r`**

| Command | Purpose |
|---|---|
| `rmmod module_name` | Removes only the specified module |
| `modprobe -r module_name` | Removes the module and may also remove unused dependency modules |

<i> Note: `modprobe -r` is generally more convenient because it handles module dependencies. </i>

<br>
<br>
<br>

**The next topic: [Software management](./09-software-management.md)** 