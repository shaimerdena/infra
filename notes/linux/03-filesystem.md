# Filesystem

> Notes based on Linux Bible and personal learning experiments.

Table of contents: 
- [Filesystem](#filesystem)
  - [Linux Directories](#linux-directories)
  - [Linux vs Windows Filesystems](#linux-vs-windows-filesystems)
  - [Commands to create and use files](#commands-to-create-and-use-files)
  - [Using metacharacters and operators](#using-metacharacters-and-operators)
    - [File-matching metacharacters](#file-matching-metacharacters)
    - [File-redirection metacharacters](#file-redirection-metacharacters)
    - [Brace expansion characters](#brace-expansion-characters)
  - [Listing Files and Directories](#listing-files-and-directories)
    - [Understanding `ls -l`](#understanding-ls--l)
    - [Understanding `ls -la`](#understanding-ls--la)
    - [Special Permissions](#special-permissions)
    - [Useful `ls` Options](#useful-ls-options)
    - [Creating Nested Directories](#creating-nested-directories)
  - [File Permissions and Ownership](#file-permissions-and-ownership)
    - [File Types](#file-types)
    - [Permission Structure](#permission-structure)
    - [Permission Bits](#permission-bits)
    - [Changing permissions with `chmod` (number)](#changing-permissions-with-chmod-number)
    - [Changing permissions with `chmod` (letters)](#changing-permissions-with-chmod-letters)
    - [Why Use Letters Instead of Numbers (chmod)?](#why-use-letters-instead-of-numbers-chmod)
    - [Setting Default Permissions with `umask`](#setting-default-permissions-with-umask)
    - [Changing File Ownership with `chown`](#changing-file-ownership-with-chown)
  - [Moving, Copying, and Removing Files](#moving-copying-and-removing-files)
    - [Moving Files with `mv`](#moving-files-with-mv)
    - [Copying Files with `cp`](#copying-files-with-cp)
    - [Removing Files with `rm`](#removing-files-with-rm)
    - [Removing Directories](#removing-directories)
    - [Common Options](#common-options)
    - [Safety Tips](#safety-tips)

## Linux Directories

| Directory | Purpose |
|------------|----------|
| `/` | Root directory (top of the filesystem) |
| `/bin` | Essential user commands (`ls`, `cp`, `cat`, `mkdir`) |
| `/boot` | Files required to boot Linux |
| `/dev` | Device files (disks, terminals, USB devices) |
| `/etc` | System configuration files |
| `/home` | Home directories of regular users |
| `/lib` | Shared libraries required by programs |
| `/media` | Automatically mounted removable devices (USB drives, CDs) |
| `/mnt` | Temporary mount point for filesystems |
| `/opt` | Optional third-party software |
| `/proc` | Information about processes and the Linux kernel |
| `/root` | Home directory of the root user |
| `/sbin` | System administration commands |
| `/sys` | Kernel and hardware information |
| `/tmp` | Temporary files |
| `/usr` | User applications, libraries, and documentation |
| `/var` | Variable data (logs, web files, mail, databases) |

## Linux vs Windows Filesystems

| Feature | Linux | Windows |
|----------|--------|---------|
| Storage organization | Single filesystem tree (`/`) | Multiple drives (`C:`, `D:`) |
| Path separator | `/` | `\` |
| Executable files | Determined by permissions (`chmod +x`) | Often determined by extensions (`.exe`, `.bat`) |
| File ownership | Every file has an owner and permissions | Added later; originally designed as a single-user system |

<i> Example Paths </i>

Linux: `/home/cipher/Documents` <br>
Windows: `C:\Users\Cipher\Documents`

## Commands to create and use files

Basic Filesystem Commands

| Command |	Description |
|----------|--------|
| cd | 	Navigate to a different directory
| pwd |	Display the current working directory
| mkdir |	Create a new directory
| chmod | 	Modify file or directory permissions
| ls |	Show the contents of a directory


<i> Notes: 
* Running cd without arguments returns you to your home directory.
* Use pwd to verify your current location in the filesystem.
* The mkdir command is used to create new directories.
* File and directory permissions can be modified with chmod. </i>

To view permissions and details of a directory:
```bash
$ ls -ld test
drwxr-xr-x 2 cipher users 4096 Jun 10 12:00 test
```
<i> ls -l - displays detailed info</i> <br>
<i> ls -d - only lists the name of directories </i>

## Using metacharacters and operators

### File-matching metacharacters

<strong> Bash supports wildcard characters (globbing) to match multiple files. </strong>

| Metacharacter | Description |
|---------------|-------------|
| `*` | Matches zero or more characters |
| `?` | Matches exactly one character |
| `[abc]` | Matches one character from the specified set |
| `[a-z]` | Matches one character within a range |

<i>Examples:</i>

- Matches files starting with `a`: `ls a*`
- Matches files containing `e`: `ls *e*`
- Matches files starting with `g` and ending with `t`: `ls g*t`
- Matches five-character filenames ending with `e`: `ls ????e`
- Matches files starting with `a`, `b`, or `w`: `ls [abw]*`
- Matches files starting with letters from `a` to `g`: `ls [a-g]*`

<i> Notes

- Wildcards are expanded by the shell before the command is executed.
- They can be used with many commands such as `ls`, `cp`, `mv`, and `rm`.
- Wildcards help work with multiple files without specifying each filename manually. </i>

### File-redirection metacharacters

<strong> Linux commands receive input from <em>standard input (stdin)</em> and send results to <em>standard output (stdout)</em>. </strong>

<strong> Redirection Operators </strong>

| Operator | Description |
|-----------|-------------|
| `<` | Read input from a file |
| `>` | Write output to a file (overwrite) |
| `>>` | Append output to a file |
| `2>` | Redirect error messages (stderr) to a file |
| `&>` | Redirect both output and errors to a file |
| pipe | Send output of one command as input to another |

`|`   command → command <br>
`>`   output → file <br>
`>>`  output → append to file <br>
`<`   file → command <br>
`2>`  errors → file <br>
`&>`  everything → file <br>
 
<i> Examples </i>

- Read a file as input: `sort < names.txt` (it is the same as using `sort names.txt`)
- Write output to a file: `ls > files.txt`
- Append output to a file: `date >> log.txt`
- Save errors only: `find /root 2> errors.txt`
- Save both output and errors: `find / &> output.log`
- Use a pipe: `ls | grep txt`

<strong> Here Documents </strong>

A here document (`<<`) allows multiline input to be passed to a command.

Example:

```bash
$ cat << EOF
> Hello
> Linux
> EOF
```

Output:

```text
Hello
Linux
```

### Brace expansion characters

<strong> Brace expansion (`{ }`) generates multiple strings from a single pattern. Syntax: `{item1, item2, item3}`, `start..end`.</strong>

<i>Example: </i>

- Create multiple directories: `mkdir project-{frontend,backend,database}`. Result:

```text
project-frontend
project-backend
project-database
```

- Create multiple files using a range: `touch log{1..4}.txt`. Result:

```text
log1.txt
log2.txt
log3.txt
log4.txt
```
- Combine multiple expansions: `touch env-{dev,test,prod}-{1..2}.conf`. Result:

```text
env-dev-1.conf
env-dev-2.conf
env-test-1.conf
env-test-2.conf
env-prod-1.conf
env-prod-2.conf
```

<i> Notes: 
- Brace expansion occurs before command execution.
- Supports both comma-separated values and ranges.
- Can be combined with other shell features. </i>

## Listing Files and Directories

### Understanding `ls -l`

<strong> The first character in `ls -l` output indicates the file type. </strong>

| Symbol | Type |
|----------|----------|
| `-` | Regular file |
| `d` | Directory |
| `l` | Symbolic link |

<i>Examples </i>

* Regular file - `-rw-r--r-- file.txt`
* Directory - `drwxr-xr-x Documents`
* Symbolic link - `lrwxrwxrwx config -> /etc/config`

<strong> An executable file has the `x` permission set. The `x` bits indicate that the file can be executed as a program or script. </strong>

<i> Example: </i> `-rwxr-xr-x script.sh`

### Understanding `ls -la`

<strong> The `ls -la` command displays a detailed listing of files and directories, including hidden files. </strong>

| Option | Description |
|---------|-------------|
| `-l` | Long listing format |
| `-a` | Show hidden files (files starting with `.`) |

<strong> Files and directories beginning with `.` are hidden by default. These files are commonly used for shell configuration and user settings. </strong>

Examples:

```text
.bashrc
.bash_profile
.bash_history
```

<strong> Special Directories </strong>

| Entry | Meaning |
|---------|----------|
| `.` | Current directory |
| `..` | Parent directory |

<i>Example: </i> 
```bash
$ ls -la
total 8
drwxrwxr-x 2 cipher cipher 4096 Jun 10 15:30 .
drwxr-­x--x 7 cipher cipher 4096 Jun 10 15:30 ..
-rw-rw-r--  1 cipher cipher 0 Jun 10 15:30 letter
```
<i> total - the total amount of disk space used by the files. </i>

| Column | Description |
|----------|-------------|
| 1 | File type and permissions |
| 2 | Number of hard links |
| 3 | Owner |
| 4 | Group |
| 5 | Size (bytes) |
| 6 | Last modification date |
| 7 | File or directory name |

### Special Permissions

<strong> SetUID / SetGID (`s`) </strong>

<strong> Programs with the `s` bit run with the privileges of the file owner or group.</strong>

The `s` permission indicates a special execution mode.

- SetUID: program runs with the file owner's privileges
- SetGID: program runs with the file group's privileges

Example:

```text
-rwsr-xr-x
```

<strong> Sticky Bit (`t`) </strong>

<strong> Commonly used on shared directories. Users can create files but cannot delete files owned by others. </strong>

Example:

```text
drwxrwxrwt
```

<strong> Additional Indicators </strong>

| Symbol | Meaning |
|----------|----------|
| `+` | ACLs (Access Control Lists) are configured |
| `.` | SELinux context is applied |

### Useful `ls` Options

| Command | Description |
|----------|-------------|
| `ls -a` | Show hidden files |
| `ls -l` | Display detailed information |
| `ls -la` | Show hidden files in long format |
| `ls -lt` | Sort files by modification time |
| `ls -S` | Sort files by size |
| `ls -F` | Append file type indicators |
| `ls -R` | List files recursively |
| `ls -ld DIR` | Show information about a directory itself |

<strong> File Type Indicators (`ls -F`) </strong>

| Symbol | Meaning |
|----------|----------|
| `/` | Directory |
| `*` | Executable file |
| `@` | Symbolic link |

### Creating Nested Directories

<strong> Use `mkdir -p` to create multiple directory levels at once. This command creates all missing parent directories automatically.</strong>

Example:

```bash
$ mkdir -p projects/devops/notes
```

## File Permissions and Ownership

### File Types

<strong> The first character in the permission string indicates the file type. </strong>

| Symbol | Type |
|----------|----------|
| `-` | Regular file |
| `d` | Directory |
| `l` | Symbolic link |
| `b` | Block device |
| `c` | Character device |
| `s` | Socket |
| `p` | Named pipe |

### Permission Structure

A permission string contains 9 permission bits divided into three groups:

```text
-rwxr-xr-x
 ||| ||| |||
  |   |   |
Owner Group Others
```

| Group | Description |
|----------|-------------|
| Owner | User who owns the file |
| Group | Users belonging to the file's group |
| Others | All other users |

### Permission Bits

| Symbol | Permission | File | Directory |
|----------|-------------|----------|-------------|
| `r` | Read | View file contents | List directory contents (`ls`) |
| `w` | Write | Modify file contents, rename or delete | Create, delete, or rename files inside the directory |
| `x` | Execute | Run the file as a program or script | Enter the directory (`cd`) and access its contents |
| `-` | Not granted | Permission denied | Permission denied |

<i> Note: 
- For **files**, `x` means the file can be executed.
- For **directories**, `x` means users can access (`cd`) the directory.
- Having `r` without `x` on a directory allows users to see names of files but not access them.
- Having `x` without `r` allows users to access files if they know the exact filename. </i>

### Changing permissions with `chmod` (number)

<strong> The `chmod` command is used to modify file and directory permissions. </strong>

Each permission is represented by a number:

| Permission | Value |
|------------|--------|
| `r` (read) | 4 |
| `w` (write) | 2 |
| `x` (execute) | 1 |

Permissions are calculated by adding the values together.

| Number | Permission |
|----------|-------------|
| `7` | `rwx` |
| `6` | `rw-` |
| `5` | `r-x` |
| `4` | `r--` |
| `0` | `---` |

```text
      OWNER  GROUP  OTHERS
744 -   7      4       4
```

<i> Common Permission Sets: </i>

| Permission | Result | Typical Use |
|------------|----------|-------------|
| `755` | `rwxr-xr-x` | Directories and executable scripts |
| `644` | `rw-r--r--` | Regular files |
| `700` | `rwx------` | Private directories and scripts |
| `600` | `rw-------` | Sensitive files (SSH keys, credentials) |

<strong> Recursive Permissions: Use `-R` to apply permissions recursively to a directory and all its contents. </strong>

```bash
$ chmod -R 755 myapps
```
This applies `755` permissions to all files and directories under `myapps`.

### Changing permissions with `chmod` (letters)

<strong> Besides numeric permissions, `chmod` can modify permissions symbolically using letters and operators. </strong>

Permission Targets

| Symbol | Meaning |
|----------|----------|
| `u` | User (owner) |
| `g` | Group |
| `o` | Others |
| `a` | All users |

Operators

| Symbol | Action |
|----------|----------|
| `+` | Add permission |
| `-` | Remove permission |
| `=` | Set exact permission |

<i> Common Examples: </i>

| Command | Result |
|----------|----------|
| `chmod a-w file` | Remove write permission from everyone |
| `chmod o-x file` | Remove execute permission from others |
| `chmod go-rwx file` | Remove all permissions from group and others |
| `chmod u+rw file` | Give owner read and write permissions |
| `chmod a+x file` | Give execute permission to everyone |
| `chmod ug+rx file` | Give read and execute permissions to owner and group |
| `chmod u=rwx,g=rx,o=r file` | Set exact permissions |

<strong> Recursive Permission Changes: Symbolic mode is often preferred for recursive changes because it modifies only specific permission bits. </strong>

```bash
$ chmod -R o-w myapps
```

This recursively removes write permission for others without affecting any other permissions.

### Why Use Letters Instead of Numbers (chmod)?

- Numeric mode (`755`, `644`) replaces the entire permission set.
- Symbolic mode (`u+x`, `o-w`) modifies only specific permission bits.

Symbolic mode is often safer for recursive permission changes.

### Setting Default Permissions with `umask`

<strong> The `umask` command controls the default permissions assigned to newly created files and directories. </strong>

Before applying `umask`, Linux starts with:

| Type | Base Permission |
|----------|----------|
| File | `666` (`rw-rw-rw-`) |
| Directory | `777` (`rwxrwxrwx`) |

<i> Note: Regular files do not receive execute (`x`) permissions by default. To view the current umask, enter `umask`. </i>

<strong> How Umask Works? </strong>

The umask value removes permissions from the base permissions.

```text
Directory: 777 - 002 = 775 (rwxrwxr-x)
File:      666 - 002 = 664 (rw-rw-r--)
```

<i> Common Umask Values </i>

| Umask | File Permission | Directory Permission | Description |
|----------|----------|----------|----------|
| `000` | `666` | `777` | No restrictions |
| `002` | `664` | `775` | Common for regular users |
| `022` | `644` | `755` | Common on Linux systems |
| `077` | `600` | `700` | Private access for owner only |

* Temporarily Changing Umask - `umask 022`
* Permanent Configuration - `umask 022` + add the desired value to your `~/.bashrc` + `source ~/.bashrc`.

### Changing File Ownership with `chown`

<strong> The `chown` command is used to change the owner and/or group of a file or directory. </strong>

Syntax:

Change owner:

```bash
chown USER FILE
```

Change owner and group:

```bash
chown USER:GROUP FILE
```

<strong> Recursive Ownership Changes: Use `-R` to change ownership recursively for a directory and all its contents. </strong>

```bash
$ sudo chown -R cipher:developers project/
```

This changes the owner and group of the directory and everything inside it.

<i> Notes: 
- Only the root user (or a user with sudo privileges) can change file ownership.
- Ownership consists of two parts: User (owner), Group </i>

## Moving, Copying, and Removing Files

<strong> Linux provides three main commands for file management: `mv`, `cp`, and `rm`. </strong>

### Moving Files with `mv`

* Rename a file - `mv old.txt new.txt`
* Move a file to another directory - `mv notes.txt ~/Documents/`
* Move a directory and all its contents - `mv project/ ~/archive/`

<i> Note: `mv` can be used both for moving and renaming files. </i>

### Copying Files with `cp`

* Copy a file - `cp notes.txt backup.txt`
* Copy a file to another location - `cp notes.txt ~/Documents/`
* Recursively copy a directory and its contents - `cp -r project/ backup/`
* Archive copy (preserves permissions, preserves ownership, preserves timestamps) - `cp -a project/ backup/`

### Removing Files with `rm`

* Delete a file - `rm notes.txt`
* Delete all non-hidden files in the current directory - `rm *`

### Removing Directories

* Remove an empty directory - `rmdir emptydir`
* Recursively remove a directory and its contents - `rm -r project/`
* Force removal without confirmation - `rm -rf project/`

<i> Security Note: Be careful with `rm -rf` because deleted files cannot be easily recovered </i>

### Common Options

| Option | Description |
|----------|-------------|
| `-i` | Prompt before overwriting or deleting |
| `-r` | Recursive operation |
| `-f` | Force operation |
| `-a` | Archive mode (preserve metadata) |

### Safety Tips

<strong> Be careful when using `mv`, `cp`, and `rm` without confirmation prompts. </strong>

<strong> Interactive Mode </strong>

Prompt before overwriting or deleting files.

```bash
$ rm -i file.txt
$ cp -i file.txt backup/
$ mv -i file.txt archive/

$ alias rm='rm -i'
$ alias cp='cp -i'
$ alias mv='mv -i'
```

<strong> Bypassing Aliases </strong>

Run the original command without any aliases.

```bash
\rm file.txt
```

<strong> Creating Backups </strong>

If the destination file already exists, a backup copy is created before overwriting it.

```bash
cp -b config.conf backup/
mv -b config.conf backup/
```

<i> Notes: 
- Wildcards (`*`) combined with `rm` can delete many files at once.
- `-b` helps prevent accidental data loss when overwriting files. </i>

<br>
<br>
<br>

**The next topic: [Text Files](./04-text-files.md)**