# Software Management

> Notes based on Linux Bible and personal learning experiments.

Table of Contents:
- [Software Management](#software-management)
  - [Understanding RPM and DEB Software Packaging](#understanding-rpm-and-deb-software-packaging)
    - [DEB packaging](#deb-packaging)
    - [RPM packaging](#rpm-packaging)
  - [Managing RPMs with `dnf` and `yum`](#managing-rpms-with-dnf-and-yum)
    - [`yum`](#yum)
    - [`dnf`](#dnf)
    - [How `dnf` works](#how-dnf-works)
    - [Third-party repositories](#third-party-repositories)
    - [Managing software with the `dnf` command](#managing-software-with-the-dnf-command)
      - [Searching for packages](#searching-for-packages)
      - [Installing and removing packages](#installing-and-removing-packages)
      - [Updating packages](#updating-packages)
      - [Updating groups of packages](#updating-groups-of-packages)
      - [Maintaining your RPM package database and cache](#maintaining-your-rpm-package-database-and-cache)

## Understanding RPM and DEB Software Packaging
  
### DEB packaging

**DEB (Debian Package)**
- DEB is the package format used by Debian-based distributions (e.g., Ubuntu).
- DEB packages have the `.deb` file extension.
- DEB uses `dpkg` and `apt` for package management.
- DEB provides similar functionality to RPM but is tailored for Debian's package management system.
- DEB automatically resolves dependencies using APT.

Debian sofware packages hold multiple files and metadata, including: Control files (metadata, located in the `DEBIAN` directory), Data files (actual files that will be installed on the system), Scripts (include pre-installation and post-installation scripts), Configuration files (placed in `/etc`), Documentation (such as README files, changelogs, and license information, placed in `/usr/share/doc`).

Multplie command-line tools are available for managing DEB packages, including:
- Ubuntu Software Center: A graphical interface for managing DEB packages on Ubuntu.
- `aptitude`: A text-based interface for managing DEB packages, providing a more user-friendly experience than the command line. You can upgrade
packages, get new packages, or view installed packages.
- `apt` (apt-get, apt, apt-config, apt-cache, and so on): set of commands that can be used to manage package installation.

| Command | Description |
| --- | --- |
| sudo apt-get update | Get the latest package versions |
| sudo apt-cache search SOFTWARE | Find package by key word |
| sudo apt-cache show SOFTWARE | Display information about a package |
| sudo apt-get install SOFTWARE | Install the software package |
| sudo apt-get upgrade | Update installed packages if upgrade ready |
| sudo apt-cache pkgnames | List all packages that are installed |

### RPM packaging

**RPM (Red Hat Package Manager)**
- RPM is a package management system used by Red Hat-based distributions (e.g., RHEL, CentOS, Fedora).
- RPM packages have the `.rpm` file extension. 
- The command `rpm` was the first tool to manage RMPs. Later `.yum` was introduced for managing RPM packages, which was later replaced by `dnf` in newer versions of Fedora and RHEL.
- RPM provides tools for installing, upgrading, and removing software packages.
- RPM relies on the user to resolve dependencies.

An **RPM (Red Hat Package Manager)** package is a file that contains everything needed to install software on RPM-based Linux distributions (Fedora, RHEL, Rocky Linux, AlmaLinux). An RPM package may include: Program files (executables), Configuration files, Documentation, Metadata.

---

**RPM Package Name & Query Installed Packages**

Example:

```text
$ sudo rpm -­q firefox
firefox-141.0-2.fc42.x86_64.rpm
```

Meaning:

| Part | Description |
|------|-------------|
| firefox | Package name |
| 141.0 | Software version (from Mozilla) |
| 2 | Package release number (assigned by Fedora) |
| fc42 | Built for Fedora 42 |
| x86_64 | 64-bit architecture |
| .rpm | RPM package file |

Display detailed information about package: `rpm -qi firefox`

---

**RPM Database**

After installation, package information is stored in the **local RPM database**. The database keeps information about: Installed packages, Versions, Dependencies, Installation details.

---

## Managing RPMs with `dnf` and `yum`

### `yum`

**YUM (Yellowdog Updater Modified)** is a package manager for RPM-based Linux distributions. Before YUM, users had to install RPM packages and their dependencies manually. YUM introduced **software repositories**, allowing dependencies to be downloaded automatically.

Its main purpose is to:
- install packages;
- update packages;
- remove packages;
- automatically resolve dependencies.

A **repository** is a collection of software packages stored in one place.

Repositories may be located:
- on a web server (`http://`)
- on an FTP server (`ftp://`)
- on local media (USB, DVD)
- in a local directory (`file://`)

### `dnf`

**DNF (Dandified YUM)** is the modern replacement for YUM. In many systems, `yum` is simply a symbolic link to `dnf`.

It performs the same tasks:
- install packages
- update packages
- remove packages
- search packages
- resolve dependencies

Repositories are configured in: `/etc/dnf/dnf.conf` or `/etc/yum.repos.d/`.

### How `dnf` works

1. Read configuration (`/etc/dnf/dnf.conf`)
2. Read enabled repositories (`/etc/yum.repos.d/`)
3. Download repository metadata
4. Resolve dependencies
5. Download RPM packages
6. RPM installs packages into the filesystem
7. Update local RPM database

### Third-party repositories

- Use third-party repositories only when necessary.
- Too many repositories can:
  - cause package conflicts;
  - slow metadata updates;
  - provide less trusted packages.
- Prefer official repositories whenever possible.

### Managing software with the `dnf` command

#### Searching for packages

| Command | Purpose | Example |
|---------|---------|---------|
| `dnf search <keyword>` | Search for packages by keyword (name or description). | `dnf search editor` |
| `dnf info <package>` | Display detailed information about a package. | `dnf info emacs` |
| `dnf provides <file/command>` | Find which package provides a specific file or command. | `dnf provides dvdrecord` |
| `dnf list <package>` | Show the available version and repository of a package. | `dnf list emacs` |
| `dnf list --available` | List all available packages from enabled repositories. | `dnf list --available` |
| `dnf list --installed` | List all installed packages. | `dnf list --installed` |

#### Installing and removing packages

| Command | Purpose | Example |
|---------|---------|---------|
| `dnf install <package>` | Install a package and its dependencies. | `dnf install firefox` |
| `rpm -V <package>` | Verify the integrity of an installed package by comparing its files with the RPM database. | `rpm -V openssh` |
| `dnf reinstall <package>` | Reinstall an already installed package. | `dnf reinstall firefox` |
| `dnf remove <package>` | Remove an installed package. | `dnf remove firefox` |
| `dnf history undo <ID>` | Undo a previous DNF transaction. | `dnf history undo 15` |
| `dnf download <package>` | Download an RPM package without installing it. | `dnf download firefox` |

#### Updating packages

| Command | Purpose | Example |
|---------|---------|---------|
| `dnf check-update` | Check for available package updates without installing them. | `dnf check-update` |
| `dnf update` | Update all installed packages to the latest available versions. | `dnf update` |
| `dnf update <package>` | Update a specific package to the latest available version. | `dnf update firefox` |


#### Updating groups of packages

| Command | Purpose | Example |
|---------|---------|---------|
| `dnf group list \| grep <group>` | Search for a package group by filtering the list of available groups. | `dnf group list \| grep Development` |
| `dnf group info <group>` | Display detailed information about a package group, including the packages it contains. | `dnf group info "Development Tools"` |
| `dnf group install <group>` | Install all packages in a package group. | `dnf group install "Development Tools"` |
| `dnf group remove <group>` | Remove the packages installed from a package group. | `dnf group remove "Development Tools"` |

#### Maintaining your RPM package database and cache

| Command | Purpose |
|---------|---------|
| `dnf clean packages` | Remove cached downloaded package files. |
| `dnf clean metadata` | Remove cached repository metadata. |
| `dnf clean all` | Remove all cached packages and metadata. |
| `dnf check` | Check for dependency problems and package database consistency. |
| `rpm --rebuilddb` | Rebuild the local RPM database if it becomes corrupted. |


<br>
<br>
<br>

**The next topic: [Managing-user-accounts](./10-managing-user-accounts.md)**