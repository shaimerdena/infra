# Managing Disks and Filesystems

> Notes based on Linux Bible and personal learning experiments.

Table of Contents:
- [Managing Disks and Filesystems](#managing-disks-and-filesystems)
  - [Partitioning Hard Disks](#partitioning-hard-disks)
    - [Partition tables](#partition-tables)
    - [Viewing Disk Partitions](#viewing-disk-partitions)
    - [Device Naming](#device-naming)
    - [Creating a Single-Partition Disk](#creating-a-single-partition-disk)
    - [Creating a Multiple-Partition Disk](#creating-a-multiple-partition-disk)
  - [LVM Partitions](#lvm-partitions)
    - [Checking existing LVMs](#checking-existing-lvms)
    - [Creating LVM Logical Volumes](#creating-lvm-logical-volumes)
    - [Growing LVM Logical Volumes](#growing-lvm-logical-volumes)

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

**General workflow**
```text
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
```

**1. Connect the disk**

Connect a new HDD, SSD or USB drive. <br>
Check which device name Linux assigned to it: `journalctl -f`.

Example:
```bash
[sda] ... 
sda: sda1
```

**Important: Always verify the correct device. Using the wrong disk can destroy existing data.**

⸻

**1. Unmount the disk if it was mounted automatically**

Check: `mount | grep sda` <br>
Unmount: `umount /dev/sda1`

⸻

**3. Create the partition**

Open parted for the disk: `parted /dev/sda`

View existing partitions: `...p` <br>
Remove an existing partition if necessary: `...rm` <br>
Create a GPT partition table: `...mklabel gpt` <br>

parted applies changes immediately, so unlike fdisk, you cannot simply quit to cancel them.

Create a partition: `...mkpart`

Then specify:

* partition name;
* filesystem type;
* start;
* end.

Example:
```bash
Partition name: alldisk
File system type: ext4
Start: 1
End: 62GB
```
Check the result: `p` <br>
Exit: `q`

⸻

**4. Create a filesystem**

A partition is not ready for storing files until a filesystem is created on it.

Examples: 
```bash
`mkfs -t xfs /dev/sda1` 
`mkfs.ext4 /dev/sda1`
`mkfs.xfs /dev/sda1`
`mkfs.exfat /dev/sda1`
```
Common Linux filesystems:

* ext4
* XFS

For sharing a drive between Linux, Windows and macOS, exFAT can be useful.

⸻

**5. Create a mount point**

Create a directory where the filesystem will be accessible: `mkdir /mnt/test` <br>
Mount the partition: `mount /dev/sda1 /mnt/test` <br>
Check: `df -h /dev/sda1`

Now anything created inside: `/mnt/test` is stored on: `/dev/sda1`.

⸻

**6. Unmount the filesystem**

When finished: `umount /dev/sda1`

After unmounting, the drive can be safely removed.

⸻

**7. Automatic mounting with /etc/fstab**

USB drives usually do not need to be added to fstab because desktop Linux can mount them automatically when connected.

For permanent automatic mounting, add an entry to: `/etc/fstab`

Example:
```bash
/dev/sda1 /mnt/test ext4 defaults 0 1
```

**Field	Meaning**

`/dev/sda1` -	Partition to mount <br>
`/mnt/test` -	Mount point <br>
`ext4` -	Filesystem type <br>
`defaults` - Use default mount options <br>
`0` -	Do not use dump for backups <br>
`1` -	Check filesystem for errors during boot

<i> Note: Partitioning divides the disk, mkfs creates the filesystem, and mount makes that filesystem accessible through a directory. </i>

### Creating a Multiple-Partition Disk

**General workflow**
```text
Disk
 ↓
Create partition table
 ↓
Create multiple partitions
 ↓
Set partition types
 ↓
Write changes
 ↓
Notify kernel
 ↓
Create filesystem / swap / LVM on partitions
```

**1. Identify and unmount the disk**

Find the device name, for example: `/dev/sda` <br>
Unmount any automatically mounted partitions: `umount /dev/sda1`

**Important: Always verify the correct disk before modifying it. Partitioning the wrong disk can destroy data.**

⸻

**2. Create partitions with fdisk**

Open the disk: `fdisk /dev/sda`

Create a new partition: `...n`

Choose:
* p → primary partition
* e → extended partition

Specify the size using: +5G, +3G, +1024M

**MBR limitation**

With MBR:

* maximum 4 primary partitions;
* an extended partition can contain logical partitions;
* logical partitions are numbered starting from 5.

Example:
```text
/dev/sda1  → primary
/dev/sda2  → primary
/dev/sda3  → primary
/dev/sda4  → extended
    ├── /dev/sda5 → logical
    └── /dev/sda6 → logical
```
The extended partition acts as a container for logical partitions.

⸻

**3. Change partition types**

Inside fdisk, use: `...t`

Then specify the partition and its type code.

Common examples:
```text
Code	Type	Purpose
82	Linux swap	Swap area
c	W95 FAT32	FAT32 filesystem
8e	Linux LVM	LVM physical volume
```
Use to display available partition type codes: `...L`

⸻

**4. Check and save**

Display the partition table: `...p` <br>
Write the changes: `...w`

`...w` saves the changes. **Be careful: partitioning changes can destroy data.**

⸻

**5. Make the kernel recognize the new partitions**

Check: `grep sda /proc/partitions` <br>
If the new partitions are not visible: `partprobe /dev/sda`

Alternatively, reboot the system.

⸻

**6. Prepare each partition**

Creating a partition does not automatically create a usable filesystem.

Different partitions can be prepared for different purposes. A partition’s type tells Linux what the partition is intended for, but the partition still needs to be properly prepared before use.

Regular Linux filesystem: `mkfs -t ext4 /dev/sda1` <br>
Swap: `mkswap /dev/sda2` <br>
ext2: `mkfs /dev/sda3`  <br>
FAT32: `mkfs -t vfat /dev/sda5` <br>
LVM Physical Volume: `pvcreate /dev/sda6`

## LVM Partitions

Logical Volume Manager (LVM)

* LVM provides flexible storage management compared with traditional disk partitions.
* Physical volumes (PV) are combined into volume groups (VG).
* Logical volumes (LV) receive storage space from the volume group as needed.

Advantages:

* Extend an LV by adding free space from the VG while it is still in use.
* Add new PVs to a VG when more storage is needed.
* Move data between PVs, allowing smaller disks to be replaced with larger ones without downtime.
* Shrink filesystems to reclaim space. The LV must be unmounted, but a reboot is not required.
* Supports advanced features such as mirroring and clustering.

### Checking existing LVMs

| Command	| Purpose |
| --- | --- |
| fdisk -l /dev/sda |	View disk partitions |
| pvdisplay /dev/sda2	| View Physical Volume information |
| vgdisplay vg_abc	| View Volume Group information |
| lvdisplay vg_abc	| View Logical Volume information |
| grep vg_ /etc/fstab	| See how LVM volumes are configured and mounted |

**1. Check disk partitions**

`fdisk -l /dev/sda`

Shows the partitions on the disk and their types.

For example:
```bash
/dev/sda1 → Linux
/dev/sda2 → Linux LVM
```
A partition marked Linux LVM can be used as a Physical Volume.

⸻

**2. Check the Physical Volume**

`pvdisplay /dev/sda2`


Example:
```text
PV Name        /dev/sda2
VG Name        vg_abc
PV Size        148.52 GiB
PE Size        4.00 MiB
Total PE       38021
Free PE        0
Allocated PE   38021
```
Here, all PE are allocated, so the PV has no free space.

⸻

**3. Check the Volume Group**

`vgdisplay vg_abc`

Example:
```text
VG Size          148.52 GiB
PE Size          4.00 MiB
Total PE         38021
Alloc PE / Size  38021 / 148.52 GiB
Free PE / Size   0 / 0
```
⸻

**4. Check Logical Volumes**

`lvdisplay vg_abc`

Shows the Logical Volumes created inside the VG.

Example:
```text
/dev/vg_abc/lv_root  → 50 GiB
/dev/vg_abc/lv_home  → 92.64 GiB
/dev/vg_abc/lv_swap  → 5.88 GiB
```
Each LV has a device path: `/dev/<VG>/<LV>`

They can also be accessed through /dev/mapper/:
```text
/dev/mapper/vg_abc-lv_root
/dev/mapper/vg_abc-lv_home
/dev/mapper/vg_abc-lv_swap
```
⸻

**5. Check how LVs are used**

`grep vg_ /etc/fstab`

Example:
```text
/dev/mapper/vg_abc-lv_root  /      ext4  defaults  1 1
/dev/mapper/vg_abc-lv_home  /home  ext4  defaults  1 2
/dev/mapper/vg_abc-lv_swap  swap   swap  defaults  0 0
```
This shows where each Logical Volume is mounted and what it is used for.

* lv_root → / → ext4
* lv_home → /home → ext4
* lv_swap → swap space

---

### Creating LVM Logical Volumes

**General workflow**
```text
LVM volumes are created from the bottom up:

Physical Volume (PV)
        ↓
Volume Group (VG)
        ↓
Logical Volume (LV)
        ↓
Filesystem
        ↓
Mount
```

<i> Note: LVM is created bottom → up, but used top → down. </i>

**1. Create a Physical Volume**

Prepare a partition as an LVM Physical Volume: `pvcreate /dev/sda6`

**2. Create a Volume Group**

Add the PV to a new Volume Group: `vgcreate myvg0 /dev/sda6` <br>
Check the VG: `vgdisplay myvg0`

**3. Create a Logical Volume**

Create a 1 GB LV named music: `lvcreate -n music -L 1G myvg0` <br>
The LV will be available as: `/dev/mapper/myvg0-music`

**4. Create a Filesystem**

Create an ext4 filesystem on the LV: `mkfs -t ext4 /dev/mapper/myvg0-music`

**5. Mount the Logical Volume**

Create a mount point: `mkdir /mnt/mymusic` <br>
Mount the LV: `mount /dev/mapper/myvg0-music /mnt/mymusic` <br>
Check: `df -h /mnt/mymusic`

**6. Mount Automatically**

To mount the LV automatically after reboot, add it to /etc/fstab:

`/dev/mapper/myvg0-music /mnt/mymusic ext4 defaults 1 2`

--- 

### Growing LVM Logical Volumes

If a Logical Volume runs out of space, it can be expanded while still mounted.

**Workflow**
```text
Free space in VG
      ↓
lvextend
      ↓
Larger LV
      ↓
resize2fs
      ↓
Larger filesystem
```

<i> Note: lvextend increases the Logical Volume, but the filesystem does not automatically become larger. You must also resize the filesystem. </i>

**Requirements:**

* The Volume Group must have free space.
* The Logical Volume must be extended.
* The filesystem must then be resized to use the new space.

**1. Check available space**

Check free space in the Volume Group: `vgdisplay myvg0`
Check current filesystem usage: `df -h /mnt/mymusic`

**2. Extend the Logical Volume**

Add 1 GB: `lvextend -L +1G /dev/mapper/myvg0-music`

**3. Resize the filesystem**

For an ext4 filesystem: `resize2fs /dev/mapper/myvg0-music`

**4. Verify the new size**

`df -h /mnt/mymusic`

The filesystem should now show the additional space.