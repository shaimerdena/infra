# milestones

## 01.06.2026 - 07.06.2026
#### Day 1
- Installed Ubuntu Server on UTM
- First Linux login
#### Day 2
- started reading "Linux Bible"
- understood what linux is
- learned how Linux evolved from UNIX concepts
- Learned UNIX philosophy:
  - everything is a file
  - modular tools
  - pipes and redirection
  - portability
- understood how linux differs from other OSs
#### Day 3
- learned about shells and command line interfaces
- learned new commands: uname, lsb_release, hostname, uptime, whoami, grep, cat, man
- understood the structure of commands and how to use options and arguments
- learned how to view system information and date/time
- learned how to use man pages for command documentation
#### Day 4
- learned about location of commands and how to find them using which and whereis
- learned about types of commands: built-in, external, aliases, functions
#### Day 5
- explored command-line editing and history recall
- practiced command chaining and expansion
#### Day 6
- studied shell variables and environment variables
- created aliases and explored shell session management
#### Day 7
- understood how Bash configuration files work
- configured a custom shell environment
- customized prompts, aliases, and environment variables
- learned about man page sections
## 08.06.2026 - 14.06.2026
#### Day 8
- did hands-on shell exercises to reinforce key concepts
#### Day 9
- started exploring the linux filesystem
- learned creating and using files
- practiced using metacharacters and operators
#### Day 10
- learned listing files and directories using options
#### Day 11
- explored Linux file permissions (`r`, `w`, `x`) and ownership (user, group, others)
- learned how to modify permissions using `chmod`
- learned how to change file ownership using `chown`
- learned how default permissions are assigned with `umask`
- practiced managing permissions and ownership on files and directories
- learned how to manage, copy and delete files
#### Day 12
- did hands-on shell exercises to reinforce key concepts
- started working with text files
#### Day 13
- explored the `vi` text editor
- learned navigation and editing commands
- practiced working with buffers, search, and text replacement
- learned how to save, exit, undo, and redo changes
#### Day 14
- explored file searching in Linux
- learned the differences between `locate` and `find`
- practiced advanced file searches using various attributes
## 15.06.2026 - 21.06.2026
#### Day 15
- learned searching text with `grep`
- did hands-on shell exercises to reinforce key concepts
#### Day 16
- did hands-on shell exercises to reinforce key concepts
#### Day 17
- started learning the processes
- learned listing processes using `ps`, `procs`, `top` commands
#### Day 18
- learned about foreground and background processes
- practiced moving jobs between the foreground and background
#### Day 19
- learned about killing processes: `kill` and `killall`
- studied processor priority: `nice` and `renice`
#### Day 20
- understood how cgroups work, but i should revisit it after docker
- did hands-on shell exercises to reinforce key concepts
#### Day 21
- started learning about scripts
- understood shell variables
## 22.06.2026 - 28.06.2026
#### Day 22
- practiced writing simple scripts
- learned more about shell variables and parameter expansion
- learned reading parameters using the `read` command
#### Day 23
- revision day
#### Day 24
- practiced performing arithmetic in shell scripts
- learned writing `if...then` statements
#### Day 25
- learned using `case` command
- practiced writing `for...do` loop
- practiced writing `while...do` and `until...do` loops
#### Day 26
- tries some useful text manipulation programs
- practiced using `grep` command
#### Day 27
- learned `cut` for extracting fields
- learned `tr` for translating and replacing characters
- learned `sed` for searching and editing text
#### Day 28
- reviewed scripts written in the book 
## 29.06.2026 - 05.07.2026
#### Day 29
- did hands-on shell exercises to reinforce key concepts
#### Day 30
- wrote simple scripts
#### Day 31
- started learning about system administration
#### Day 32
- understood the importance of system administration
#### Day 33
- went through the responsibilities of a Linux system administrator
- learned about gaining admin access using `su`, `sudo`, and Cockpit
#### Day 34
- learned about ``su`` command and its usage
- learned the difference between `su` and `su -`
## 06.07.2026 - 12.07.2026
#### Day 35
- learned about `sudo` command and its usage
- learned how to configure `sudo` access for users
- learned about the `sudoers` file and how to edit it safely using `visudo
#### Day 36
- studied common administrative commands like `shutdown`, `reboot`, `systemctl`, `journalctl`, and `dmesg`
#### Day 37
- went throgth the admin configuration files in `/etc` directory
- understood how to view systemd journal logs using `journalctl`
- understood how log messages are managed using `rsyslog` and stored in `/var/log`
#### Day 38
- learned about using other admin accounts and their privileges
- learned about checking and configuring hardware
#### Day 39
- explored the how to check hardware information using commands like `lspci`, `lsusb`, and `lscpu`
- learned how to view kernel messages using `dmesg`
#### Day 40
- learned about managing kernel modules using `lsmod`, `modinfo`, `modprobe`, and `rmmod`
- practiced loading and unloading kernel modules
#### Day 41
- did hands-on shell exercises to reinforce key concepts
- wrote a simple script - "to do list" to manage tasks
## 13.07.2026 - 19.07.2026
#### Day 42
- wrote a simple script - "backup" to backup directories
- tried to write a script that shows the system information, but i didn't cover all the information, so i will revisit it later
#### Day 43
- a revision day
- wrote a simple script - "unit converter" to convert units
#### Day 44
- a revision day
- wrote a simple script - "timer" to set a timer
#### Day 45
- a revision day
#### Day 46
- a revision day
- wrote a simple script - "notes" to manage notes
#### Day 47
- started learning about software management
## 20.07.2026 - 26.07.2026
#### Day 48
- learned about package management in Linux
- learned about different package formats: `.deb` and `.rpm`
#### Day 49
- learned more about `deb` and `rpm` packaging
- explored their differences
#### Day 50
- understood how to manage RPMs using `dnf` and `yum`
#### Day 51
- understood how `dnf` works
#### Day 52
- a revision day
#### Day 53
- read about third-party repositories
- learned how to search for packages using `dnf` subcommands
#### Day 54
- explored different subcommands for managing rpm packages
## 27.07.2026 - 02.08.2026
#### Day 55
- a revision day
#### Day 56
- practiced adding users on cockpit
- explored options that come with the `useradd` command
#### Day 57
- practiced modifying and deleting users accounts
- explored options that come with `usermod` and `userdel`
#### Day 58
- read about group accounts
- learned about `groupadd` and `groupmod` commands
#### Day 59
- understood how to set and display ACLs
- learned about default ACLs
## 03.08.2026 - 09.08.2026
#### Day 60
- explored special permission bits
- went throught the steps of creating group collaboration directories
#### Day 61
- did hands-on shell exercises to reinforce key concepts
#### Day 62
- started reading about disks and filesystem management
#### Day 63
- understood how disk storage works (swap area, lvm)
- understood partition tables
#### Day 64
- learned new commands for viewing disk partitions
## 10.08.2026 - 16.08.2026
#### Day 65
- understood the general workflow of creating a single-partition disk
#### Day 66
- understood the general workflow of creating a multiple-partition disk
#### Day 67
- learned more about lvms
#### Day 68
- learned how to create lvm logical volumes
- learned how to grow lvm logical volumes
#### Day 69
- practiced viewing supported filesystems