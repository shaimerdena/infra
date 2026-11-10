# Intro to Linux

> Notes based on Linux Bible and personal learning experiments.

Table of Contents:
- [Intro to Linux](#intro-to-linux)
  - [What is Linux?](#what-is-linux)
  - [UNIX Philosophy](#unix-philosophy)
  - [Advanced Linux Features](#advanced-linux-features)

## What is Linux?
<strong> Linux </strong> is an open-source operating system kernel that serves as the foundation for a wide variety of operating systems, commonly referred to as Linux distributions. It was created by Linus Torvalds in 1991 and has since become one of the most widely used operating systems in the world. Linux is known for its stability, security, and flexibility, making it popular for servers, desktops, embedded systems, and more. It is based on the UNIX operating system and follows many of its design principles.

The features that make up Linux and similar computer OSs:
1. Detecting and preparing hardware
2. Managing processes
3. Managing memory
4. Providing user interfaces
5. Controlling filesystems
6. Providing user access and authentication
7. Offering administrative utilities
8. Starting up services
9. Programming tools

## UNIX Philosophy

UNIX was designed around simplicity, modularity, and portability.

Key principles:
- Everything is a file - devices, disks, and many system resources can be accessed through the filesystem.
- Small modular tools - programs should do one thing and do it well.
- Pipes and redirection - the output of one command can become the input of another command.
- Portability - applications can run on different hardware with minimal changes because hardware-specific details are abstracted by the operating system.

## Advanced Linux Features

Linux can be used far beyond a traditional desktop operating system.

| Feature | Description |
| --- | --- |
| Clustering | Multiple systems can work together as a single cluster to improve scalability, load balancing, and fault tolerance. |
| Virtualization | Linux can act as a virtualization host and run multiple guest operating systems such as Linux, Windows, or BSD on the same physical machine. |
| Cloud Computing | Linux provides the foundation for many cloud platforms and private cloud environments through virtualization and resource management technologies. |
| Real-Time Computing | Linux can be configured to prioritize critical processes and provide predictable response times for time-sensitive applications. |
| Network Storage | Linux supports distributed and network-based storage systems such as NFS, Samba, and iSCSI, allowing data to be accessed over a network rather than only from local disks. |

<br>
<br>
<br>

**The next topic: [Using the shell](./02-using-the-shell.md)**