# Managing Running Processes

> Notes based on Linux Bible and personal learning experiments.

Table of Contents:
- [Managing Running Processes](#managing-running-processes)
  - [Understanding Processes](#understanding-processes)
  - [Listing Processes](#listing-processes)
    - [`ps`](#ps)
    - [Useful `ps` Options](#useful-ps-options)
    - [Background Processes](#background-processes)
    - [`procs`](#procs)
    - [`top`](#top)
      - [Renice a Process](#renice-a-process)
      - [Kill a Process](#kill-a-process)
  - [Background and Foreground Processes](#background-and-foreground-processes)
    - [Starting background processes](#starting-background-processes)
    - [View Background Jobs](#view-background-jobs)
    - [Stop a Process Temporarily](#stop-a-process-temporarily)
    - [Foreground and Background commands](#foreground-and-background-commands)
  - [Killing and Renicing Processes](#killing-and-renicing-processes)
    - [`kill` and `killall`](#kill-and-killall)
    - [Kill a Process by PID](#kill-a-process-by-pid)
    - [Kill a Process by Name](#kill-a-process-by-name)
    - [`nice` and `renice`](#nice-and-renice)

## Understanding Processes

<strong> A process is a running instance of a command or program. </strong>

<strong> Key Concepts </strong>

- Every running program is a process.
- Multiple users can run the same command, creating multiple processes.
- Each process has a unique **Process ID (PID)** while it is running.
- After a process ends, its PID may be reused by another process.

Each process is associated with:

| Attribute | Description |
|------------|------------|
| PID | Unique process identifier |
| User | Owner of the process |
| Group | Group associated with the process |

These attributes determine what resources the process can access.

<i> Example </i>

One command can have many running processes:

```text
vi command
├── PID 1201 (user: cipher)
├── PID 1354 (user: alice)
└── PID 1420 (user: bob)
```

---

Permissions and Processes

- A process running as `root` has extensive system access.
- A process running as a regular user has limited permissions.
- Process permissions depend on the user account that started the process.

---

Why Process Management Matters

System administrators monitor processes to:

- identify high CPU usage
- identify excessive memory consumption
- detect runaway or frozen processes
- manage system performance

---

Process Information and `/proc`

Linux stores process information in `/proc`. Each running process has its own directory `/proc/<PID>`. Process-monitoring commands often obtain their information from the `/proc` filesystem.

## Listing Processes

<strong> Linux provides several tools for viewing and managing running processes. </strong>

<i> Common Process Tools </i>

| Command | Purpose |
|-----------|----------|
| `ps` | Display running processes |
| `top` | Real-time process monitoring |
| `procs` | Modern alternative to `ps` |
| `gnome-system-monitor` | Graphical process manager (GNOME) |

---

`ps`

- Traditional command for listing processes.
- Shows information about currently running processes.
- Supports many options inherited from UNIX and BSD systems.
- Often used in scripts and administration tasks.

---

`procs`

- Modern replacement for `ps`.
- Provides cleaner and more readable output.
- Easier to use for everyday process inspection.

---

`top`

- Displays processes in real time.
- Continuously updates CPU and memory usage.
- Can be used to monitor system performance.
- Allows interaction with running processes.

---

 GNOME System Monitor

- Graphical tool for viewing processes.
- Shows CPU, memory, and resource usage.
- Allows users to stop or manage processes through a GUI.

<i> Notes:

```text
ps    → snapshot of processes
top   → live monitoring
procs → modern ps
GUI   → gnome-system-monitor 
```
</i>

### `ps`

<strong> The `ps` command displays information about currently running processes. </strong>

Basic Usage

```bash
$ ps u
```

Displays processes for the current user with additional details such as CPU usage, memory usage, and start time.

---

Common Columns

| Column | Description |
|----------|----------|
| `USER` | User who started the process |
| `PID` | Process ID |
| `%CPU` | CPU usage percentage |
| `%MEM` | Memory usage percentage |
| `VSZ` | Virtual memory allocated (KB) |
| `RSS` | Physical memory currently used (KB) |
| `TTY` | Terminal associated with the process |
| `STAT` | Current process state |
| `START` | Process start time |
| `TIME` | Total CPU time consumed |
| `COMMAND` | Command that started the process |

---

<strong> Understanding `TTY` </strong>

| Type | Description |
|--------|------------|
| `tty` | Physical or login terminal |
| `pts` | Pseudo-terminal (Terminal window, SSH session, etc.) |

Example:

```text
pts/2
```

means the process is running inside a terminal session.

---
 
<strong> Common Process States (`STAT`) </strong>

| State | Meaning |
|----------|----------|
| `R` | Running |
| `S` | Sleeping (waiting for work) |
| `s` | Session leader |
| `l` | Multi-threaded process |
| `+` | Foreground process |

Example:

```text
R+
```

A running process in the foreground.

---

<strong> Memory Information </strong>

| Column | Meaning |
|----------|----------|
| `VSZ` | Total virtual memory allocated |
| `RSS` | Physical memory currently in RAM |

`VSZ` can be larger than `RSS` because not all allocated memory is actively used.

---

</i> Notes:

```text
ps u     → process information for current user

PID      → process identifier
TTY      → terminal/session
STAT     → process state

R        → running
S        → sleeping
```
</i>

### Useful `ps` Options

| Command / Option | Description |
|------------------|-------------|
| `ps u` | Show processes for the current user with detailed information |
| `ps ux` | Show all processes for the current user |
| `ps aux` | Show all processes for all users |
| `ps -e` | Show every running process |
| `ps -o` | Display selected columns |
| `ps -eo ...` | Show all processes with custom columns |
| `--sort=field` | Sort output by a column |
| `--sort=-field` | Sort in descending order |

---

<i> Examples </i>

Custom Output:

```bash
$ ps -eo pid,user,uid,group,gid,vsz,rss,comm
```

Sort by Virtual Memory Usage:

```bash
$ ps -eo pid,user,vsz,rss,comm --sort=-vsz
```

Show Top Memory Consumers:

```bash
$ ps -eo pid,user,vsz,rss,comm --sort=-vsz | head
```

### Background Processes

Many Linux processes run without a visible terminal.

Examples:

- logging services
- networking services
- desktop services
- audio services
- authentication services

These processes often start during boot and continue running until shutdown.

### `procs`

<strong> `procs` is a modern alternative to the `ps` command with cleaner and more readable output. </strong>

Basic Usage

| Command | Description |
|----------|----------|
| `procs` | Display all running processes |
| `procs -w` | Watch processes in real time |
| `procs --insert FIELD` | Add a custom column |

---

Useful Fields

| Field | Description |
|----------|----------|
| `TcpPort` | Network port used by the process |
| `Processor` | CPU core running the process |

<i> Example </i>

```bash
$ procs --insert TcpPort --insert Processor
```

Display additional information about ports and CPU cores.

---

Watch Mode Controls

| Key | Action |
|--------|---------|
| `a` | Sort ascending |
| `d` | Sort descending |
| `n` | Next page |
| `p` | Previous page |

### `top`

<strong> The `top` command provides a real-time view of running processes and system resource usage. </strong>

Basic Usage

```bash
$ top
```

Displays:

- running processes
- CPU usage
- memory usage
- swap usage
- system uptime
- logged-in users
- system load

---

<strong> Useful Controls </strong>

| Key | Action |
|------|---------|
| `h` | Show help |
| `M` | Sort by memory usage |
| `P` | Sort by CPU usage |
| `R` | Reverse sort order |
| `1` | Show usage for each CPU core |
| `u` | Filter by username |
| `q` | Quit `top` |

---

#### Renice a Process

| Key | Action |
|------|---------|
| `r` | Change process priority |

Steps:

1. Press `r`
2. Enter PID
3. Enter priority value (`-20` to `19`)

```text
-20 → highest priority
 19 → lowest priority
```

---

#### Kill a Process

| Key | Action |
|------|---------|
| `k` | Send signal to a process |

Steps:

1. Press `k`
2. Enter PID
3. Enter signal number

Common signals:

| Signal | Meaning |
|----------|----------|
| `15` | Graceful termination (SIGTERM) |
| `9` | Force kill (SIGKILL) |

## Background and Foreground Processes

Terminology

| Term | Description |
|---------|---------|
| Foreground | Process attached to the terminal |
| Background | Process runs while shell remains usable |
| Job | Shell-managed process/task |
| PID | Process identifier |

### Starting background processes

<strong> A process can run in the background while you continue using the shell. </strong>

Add `&` at the end of a command:

```bash
command &
```

Example:

```bash
$ find /usr > /tmp/allusrfiles &
[3] 15971
```

| Value | Meaning |
|---------|---------|
| `[3]` | Job number |
| `15971` | Process ID (PID) |

---

### View Background Jobs

```bash
$ jobs
```

Display all jobs associated with the current shell.

---

Job States

| State | Meaning |
|----------|----------|
| `Running` | Process is running |
| `Stopped` | Process is paused |
| `Done` | Process completed |

---

Symbols in `jobs`

| Symbol | Meaning |
|---------|----------|
| `+` | Current (most recent) job |
| `-` | Previous job |

Example:

```text
[4]+ Running
[5]- Running
```

--- 

Show Process IDs

```bash
$ jobs -l
```

Display job numbers together with their PIDs.

---

### Stop a Process Temporarily

```text
Ctrl + Z
```

Suspend the current foreground process.

Result:

```text
Stopped
```

---

### Foreground and Background commands

<strong> Jobs can be moved between the foreground and background. </strong>

---

<strong> Bring a Job to the Foreground </strong>

```bash
$ fg %1
```

Bring job `1` back to the foreground.

---

<strong> Start a Stopped Job in the Background </strong>

```bash
$ bg %5
```

Resume job `5` in the background.

---

<strong> Job References </strong>

| Reference | Meaning |
|------------|----------|
| `%1` | Job number 1 |
| `%` | Most recent job (`+`) |
| `%-` | Previous job (`-`) |
| `%string` | Job whose command starts with `string` |
| `%?string` | Job whose command contains `string` |

<i> Examples </i>

- `fg %1`
- `fg %`
- `fg %vim`
- `fg %?find`

---

<strong> Typical Workflow </strong>

```text
Ctrl + Z -> Stopped -> $ bg %1 -> Running -> $ fg %1
``` 


<i> Security note: Before sending editors (e.g. `vi`) to the background: Save your file first. Unsaved changes can be lost if you log out or the system shuts down.
</i>

## Killing and Renicing Processes

### `kill` and `killall`

<strong> The `kill` and `killall` commands send signals to running processes. </strong>

---

<strong> Common Commands </strong>

| Command | Description |
|----------|----------|
| `kill PID` | Send a signal to a process by PID |
| `killall name` | Send a signal to processes by name |
| `nice` | Start a process with a custom priority |
| `renice` | Change priority of a running process |

---

<strong> `kill` vs `killall` </strong>

| Command | Uses |
|----------|----------|
| `kill PID` | Target a specific process by PID |
| `killall name` | Target all processes with a given name |

---

<strong> Common Signals </strong>

| Signal | Number | Purpose |
|----------|----------|----------|
| `SIGHUP` | `1` | Reload configuration / restart behavior |
| `SIGINT` | `2` | Interrupt from keyboard |
| `SIGQUIT` | `3` | Quit from keyboard |
| `SIGABRT` | `6` | Abort signal from abort(3) |
| `SIGKILL` | `9` | Force kill a process |
| `SIGTERM` | `15` | Gracefully terminate a process (default) |
| `SIGCONT` | `18` | Continue a stopped process |
| `SIGSTOP` | `19` | Pause a process |

---

### Kill a Process by PID

<strong> Default (SIGTERM) </strong>

`kill 10432` equivalent to `kill -15 10432`

---

<strong> Force Kill </strong>

`kill -9 10432` equivalent to `kill -SIGKILL 10432`

---

<strong> Reload Configuration </strong>

`kill -1 1833` equivalent to `kill -SIGHUP 1833`

---

### Kill a Process by Name

<strong> `killall` sends a signal to process(es) by name instead of PID. It is especially useful when multiple processes share the same name. </strong>

| Command | Description |
|----------|----------|
| `killall nginx` | Signal all processes named `nginx` |
| `killall -9 nginx` | Force kill all `nginx` processes |
| `killall -HUP nginx` | Send SIGHUP to all `nginx` processes |

---

<i> Notes: <br>
SIGTERM (15) - Ask process to exit politely <br>
SIGKILL (9) - Force process to stop immediately<br>
SIGHUP (1) - Reload configuration<br>
SIGSTOP - Pause process<br>
SIGCONT - Resume process<br>
</i>

<i> Recommendation:

1. Try SIGTERM (15)
2. If process refuses → SIGKILL (9)

Avoid using `kill -9` immediately unless necessary. </i>

### `nice` and `renice`

<strong> Linux uses a nice value to decide how much CPU attention a process receives. 
- `nice` → start process with custom priority.
- `renice` → change priority of running process. </strong>

---

<i> Examples </i>

- Run `updatedb` in the background with a nice value of `5`: `nice -n 5 updatedb &`
- Change the nice value of process `20284` to `-5`: `renice -n -5 20284`
  
---

<strong> Nice Values </strong>
 
| Nice Value | Priority |
|------------|------------|
| `-20` | Highest priority |
| `0` | Default priority |
| `19` | Lowest priority |

Lower nice value = higher CPU priority

---

Rules for Regular Users

- Can set values only from `0` to `19`
- Cannot use negative values
- Cannot decrease a nice value after increasing it
- Can modify only their own processes

---

Root User Privileges

Root can:

- set any value from `-20` to `19`
- increase or decrease priority
- modify any process

---

<i> Recommendation:

1. High nice value (10-19) → Background jobs
2. Low nice value (-20 to 0) → Important system tasks

</i>

<br>
<br>
<br>

**The next topic: [Simple Scripts 1](./06-simple-scripts-1.md)**