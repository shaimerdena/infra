# Managing Disks and Filesystems

> Notes based on Linux Bible and personal learning experiments.

Table of Contents:
- [Managing Disks and Filesystems](#managing-disks-and-filesystems)
  - [Partitioning Hard Disks](#partitioning-hard-disks)
    - [Partition tables](#partition-tables)
    - [Viewing Disk Partitions](#viewing-disk-partitions)
    - [Device Naming](#device-naming)
    - [Creating a Single-Partition Disk](#creating-a-single-partition-disk)

## Partitioning Hard Disks

### Partition tables 

A **partition table** is a data structure stored on a disk that describes how the disk is divided into partitions. A partition table is stored at the **beginning of a disk**. It does **not** store user data—it only describes the disk layout. Before creating partitions, a disk must have a partition table.

It contains information such as:
- the number of partitions;
- the starting and ending location of each partition;
- the partition type;
- whether a partition is bootable.

Without a partition table, the operating system cannot determine where partitions begin or end.

Common Partition Table Types

| Type | Description |
|------|-------------|
| **MBR (Master Boot Record)** | Legacy partition table. Supports up to **4 primary partitions** and disks up to **2 TB**. |
| **GPT (GUID Partition Table)** | Modern partition table. Supports **up to 128 partitions**, disks larger than **2 TB**, and provides better reliability through redundancy and error checking. |

### Viewing Disk Partitions

Linux provides several commands to view disks and partitions.

**`parted -l`**

Displays general information about disks:

- disk model;
- disk size;
- partition table (GPT/MBR);
- partitions;
- filesystem type.

---

**`fdisk -l`**

Displays detailed partition information:

- partition name;
- partition size;
- partition type;
- sector information.

---

**`df -h`**

Displays mounted filesystems and disk usage.

Shows:

- filesystem;
- total size;
- used space;
- available space;
- mount point.

---

### Device Naming

**SATA / USB**

```text
/dev/sda
/dev/sdb
/dev/sdc
```

Partitions:

```text
/dev/sda1
/dev/sda2
```

**NVMe SSD**

```text
/dev/nvme0n1
```

Partitions:

```text
/dev/nvme0n1p1
/dev/nvme0n1p2
```

---
<i>Note: USB drives are usually assigned the first available `/dev/sdX` device (e.g., `/dev/sda`).</i>

### Creating a Single-Partition Disk

General workflow

Connect disk
    ↓
Partition disk
    ↓
Create filesystem
    ↓
Mount filesystem
    ↓
Use the disk
    ↓
Unmount when finished

1. Connect the disk

Connect a new HDD, SSD or USB drive.
Check which device name Linux assigned to it: `journalctl -f`.

Example:

[sda] ...
sda: sda1

Important: Always verify the correct device. Using the wrong disk can destroy existing data.

⸻

1. Unmount the disk if it was mounted automatically

Check: `mount | grep sda`
Unmount: `umount /dev/sda1`

⸻

3. Create the partition

Open parted for the disk: `parted /dev/sda`

View existing partitions: `...p`
Remove an existing partition if necessary: `...rm`
Create a GPT partition table: `...mklabel gpt`

parted applies changes immediately, so unlike fdisk, you cannot simply quit to cancel them.

Create a partition: `...mkpart`

Then specify:

* partition name;
* filesystem type;
* start;
* end.

Example:

Partition name: alldisk
File system type: ext4
Start: 1
End: 62GB

Check the result: `p`
Exit: `q`

⸻

4. Create a filesystem

A partition is not ready for storing files until a filesystem is created on it.

Examples: 

`mkfs -t xfs /dev/sda1`
`mkfs.ext4 /dev/sda1`
`mkfs.xfs /dev/sda1`
`mkfs.exfat /dev/sda1`

Common Linux filesystems:

* ext4
* XFS

For sharing a drive between Linux, Windows and macOS, exFAT can be useful.

⸻

1. Create a mount point

Create a directory where the filesystem will be accessible: `mkdir /mnt/test`
Mount the partition: `mount /dev/sda1 /mnt/test`
Check: `df -h /dev/sda1`

Now anything created inside: `/mnt/test` is stored on: `/dev/sda1`.

⸻

6. Unmount the filesystem

When finished: `umount /dev/sda1`

After unmounting, the drive can be safely removed.

⸻

7. Automatic mounting with /etc/fstab

USB drives usually do not need to be added to fstab because desktop Linux can mount them automatically when connected.

For permanent automatic mounting, add an entry to: `/etc/fstab`

Example:

`/dev/sda1 /mnt/test ext4 defaults 0 1`

Field	Meaning
`/dev/sda1` -	Partition to mount
`/mnt/test` -	Mount point
`ext4` -	Filesystem type
`defaults` - Use default mount options
`0` -	Do not use dump for backups
`1` -	Check filesystem for errors during boot

<i> Note: Partitioning divides the disk, mkfs creates the filesystem, and mount makes that filesystem accessible through a directory. </i>