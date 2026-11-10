# Text Files

> Notes based on Linux Bible and personal learning experiments.

Table of Contents:
- [Text Files](#text-files)
  - [`vim`/`vi`](#vimvi)
    - [Starting with `vi`](#starting-with-vi)
    - [Entering Insert Mode](#entering-insert-mode)
    - [Navigation Commands](#navigation-commands)
    - [Editing Text](#editing-text)
    - [Pasting Text](#pasting-text)
    - [Repeating Commands](#repeating-commands)
    - [Saving and Exiting `vi`](#saving-and-exiting-vi)
    - [Useful `vi` Tips](#useful-vi-tips)
    - [File Navigation Commands](#file-navigation-commands)
    - [Search Commands](#search-commands)
    - [Ex Mode](#ex-mode)
  - [Finding Files](#finding-files)
    - [`locate`](#locate)
    - [`find`](#find)
      - [Search by Name](#search-by-name)
      - [Search by Size](#search-by-size)
      - [Search by Owner or Group](#search-by-owner-or-group)
      - [Search by Permissions](#search-by-permissions)
      - [Search by Time](#search-by-time)
      - [Combining Conditions](#combining-conditions)
      - [Executing Commands](#executing-commands)
    - [Searching Text with `grep`](#searching-text-with-grep)

## `vim`/`vi`

### Starting with `vi`

<strong> `vi` is a text editor commonly used in Linux systems. </strong>

Opening a File:

```bash
vi /tmp/test
```

- Opens an existing file or creates a new one if it does not exist.
- A new file displays `~` characters on empty lines.
- The status line at the bottom shows information about the file.

<strong> `vi` operates in two primary modes: </strong>

| Mode | Purpose |
|----------|----------|
| Command Mode | Navigate and execute commands |
| Insert Mode | Enter and edit text |

<i> Note: `vi` starts in Command Mode by default. </i>

<strong> You cannot start typing immediately after opening `vi`. </strong>
 
To begin entering text, first switch to Insert Mode using commands such as: `a`, `i`, `o`

<strong> Compared to `vi`, `vim` provides: </strong>

- syntax highlighting
- colorized text
- visual selection
- split-screen editing
- additional editing features

<i> Notes:
- `vi` is a modal editor.
- Commands are case-sensitive.
- Understanding the difference between Command Mode and Insert Mode is essential. </i>

### Entering Insert Mode

<strong> To add or modify text in `vi`, you must switch from Command Mode to Insert Mode. </strong>

<strong> Common Insert Commands </strong>

| Command | Action | Position |
|----------|----------|----------|
| `i` | Insert | Before the cursor |
| `a` | Append | After the cursor |
| `I` | Insert | Beginning of the current line |
| `A` | Append | End of the current line |
| `o` | Open a new line | Below the current line |
| `O` | Open a new line | Above the current line |

<i> Notes: 
- Lowercase commands work near the cursor, while uppercase commands usually affect the entire line. lowercase = local action, UPPERCASE = bigger scope. 
- When Insert Mode is active, `-- INSERT --` appears at the bottom of the screen.
- To leave Insert Mode and return to Command Mode, press `Ecs`. Sometimes you may need to press `Esc` twice, especially after entering special modes such as Ex mode (`:`). </i>

### Navigation Commands

| Command | Action |
|----------|----------|
| `←` / `h` | Move left |
| `→` / `l` | Move right |
| `↑` / `k` | Move up |
| `↓` / `j` | Move down |
| `w` | Jump to the beginning of the next word |
| `W` | Jump to the beginning of the next word (spaces/tabs only) |
| `b` | Jump to the beginning of the previous word |
| `B` | Jump to the beginning of the previous word (spaces/tabs only) |
| `0` (zero) | Move to the beginning of the current line |
| `$` | Move to the end of the current line |
| `H` | Move to the top line of the screen |
| `M` | Move to the middle line of the screen |
| `L` | Move to the bottom line of the screen |

```text
     k
     ↑
h ←     → l
     ↓
     j
```

<i>Note: `w` and `b` treat punctuation as word boundaries, while `W` and `B` only use spaces and tabs as separators. </i>

### Editing Text

<strong> Most editing commands in `vi` follow the pattern:</strong>

```text
[action] + [target]
```

Example:

```text
dw = delete word
cw = change word
yy = copy current line
```

<strong> Actions </strong>

| Command | Action |
|----------|----------|
| `d<?>` | Delete |
| `c<?>` | Change (delete and enter Insert Mode) |
| `y<?>` | Yank (copy) |
| `x` | Delete character under cursor |
| `X` | Delete character before cursor |

<i> Common Examples </i>

| Command | Action |
|----------|----------|
| `dw` | Delete next word |
| `db` | Delete previous word |
| `dd` | Delete current line |
| `cw` | Change next word |
| `cc` | Change current line |
| `c$` | Change from cursor to end of line |
| `yy` | Copy current line |
| `y)` | Copy current sentence |
| `3dd` | Delete 3 lines |
| `3dw` | Delete 3 words |
| `5cw` | Change 5 words |
| `12j` | Move down 12 lines |

<i> Note: Numbers act as multipliers for commands.</i>

### Pasting Text

<strong> Text stored in the buffer can be pasted using `p` or `P`. </strong>

Paste Commands

| Command | Action |
|----------|----------|
| `p` | Paste after the cursor or below the current line |
| `P` | Paste before the cursor or above the current line |

Behavior

| Buffered Content | `p` | `P` |
|----------|----------|----------|
| Characters / words | Paste after cursor | Paste before cursor |
| Entire lines | Paste below current line | Paste above current line |

<i> Notes:

- Deleted (`d`), changed (`c`), and yanked (`y`) text is stored in the buffer.
- `p` and `P` retrieve the most recently stored text from the buffer.
</i>

### Repeating Commands

<strong> The `.` command repeats the most recent editing action. </strong>

<i> Common Workflow </i>

```text
1. Make a change
2. Move to the next location
3. Press .
```

<i> Example: </i>

```vim
cw
```

Change a word.

```vim
.
```

Repeat the same change at the current cursor position.

<i> Notes:
- Often used together with search commands.
- Useful for making the same change multiple times throughout a file. </i>

### Saving and Exiting `vi`

<strong> Use Ex commands (`:`) to save, quit, or both. </strong>

<i> Common Commands </i>

| Command | Action |
|----------|----------|
| `:w` | Save the current file but keeps `vi` open. |
| `:wq` | Save and quit |
| `ZZ` | Save and quit |
| `:q` | Quit (only if there are no unsaved changes) |
| `:q!` | Quit without saving changes |

<i> Notes:
- `:q!` discards all unsaved changes.
- `ZZ` and `:wq` achieve the same result: save and exit.
</i>

### Useful `vi` Tips

| Command | Action |
|----------|----------|
| `Esc` | Return to Command Mode |
| `u` | Undo last change |
| `Ctrl+R` | Redo |
| `:!command` | Run a shell command from `vi` |
| `Ctrl+g` | Show file information and cursor position |


### File Navigation Commands

| Command | Action |
|----------|----------|
| `Ctrl+f` | Move forward one page |
| `Ctrl+b` | Move backward one page |
| `Ctrl+d` | Move forward half a page |
| `Ctrl+u` | Move backward half a page |
| `G` | Go to the last line |
| `1G` | Go to the first line |
| `#G` | Go to line `#` |

### Search Commands

| Command | Action |
|----------|----------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Repeat search in the same direction |
| `N` | Repeat search in the opposite direction |

<i> Examples: </i>

- Search forward for `hello`: `/hello`
- Search backward for `goodbye`: `?goodbye`
- Search for either `print` or `Print`: `/[pP]rint`
- Search for a line containing `The` followed later by `foot`: `/The.*foot`

<i> Note: Regular expression patterns can be used. </i>

### Ex Mode

<strong> Ex mode is entered by typing `:` in Command Mode. It allows advanced search and text manipulation commands.</strong>

<i> Common Commands </i>

| Command | Action |
|----------|----------|
| `:g/pattern` | Display lines matching a pattern |
| `:s/old/new` | Replace first occurrence on the current line |
| `:g/old/s//new/g` | Replace all occurrences in the file |

<i> Examples </i>

- Show all lines containing `error`: `:g/error`
- Replace the first occurrence on the current line: `:s/old/new`
- Replace all occurrences of `old` with `new` throughout the file: `:g/old/s//new/g`

## Finding Files

### `locate`

<strong> The `locate` command searches a prebuilt database of filenames instead of scanning the filesystem live. </strong>

How `locate` Works?

- Uses a database generated by `updatedb`.
- Usually much faster than `find`.
- May not find recently created files until the database is updated.

Advantages and Limitations

| Advantage | Limitation |
|------------|------------|
| Very fast searches | Database may be outdated |
| Searches the entire indexed filesystem | Some paths are excluded from indexing |
| Simple syntax | Cannot find files added after the last `updatedb` run |

<i> Common Commands </i>

| Command | Action |
|----------|----------|
| `locate filename` | Search for files containing the given string |
| `locate -i filename` | Case-insensitive search |
| `updatedb` | Update the locate database (typically requires root) |

<i> Examples </i>

- Find all indexed paths containing `.bashrc`: `locate .bashrc`
- Find files containing `config`, regardless of letter case: `locate -i config`
- Refresh the locate database: `sudo updatedb`

<i> Notes:

- Searches match any part of the file path, not just the filename.
- Results depend on file permissions.
- `locate` is best for quickly finding known filenames.
- `find` is more flexible and always searches the live filesystem.
- Some directories are excluded from indexing, such as:

```text
/tmp
/proc
/sys
/dev
/media
```
</i>

### `find`

<strong> The `find` command searches the filesystem live and can locate files based on many different attributes. </strong>

<i> Key Features </i>

- Searches the current filesystem state (not a database).
- More flexible than `locate`.
- Can search by:
  - name
  - permissions
  - owner
  - size
  - modification time
  - and many other attributes
- Can execute commands on matching files.

<i> Common Commands </i>

| Command | Action |
|----------|----------|
| `find` | Search from the current directory |
| `find /etc` | Search starting from `/etc` |
| `find ~` | Search within the home directory |
| `find ~ -ls` | Display detailed information for each result |

<i> `-ls` - Show detailed file information (`ls -l` style output) </i>

<strong> Handling Permission Errors </strong>

When searching protected directories as a regular user, `find` may display permission errors.

To hide those messages:

```bash
find /etc 2> /dev/null
```

| Part | Meaning |
|--------|---------|
| `2` | Standard Error (stderr) |
| `>` | Redirect output |
| `/dev/null` | Discard output |

<i> Notes:

- Results are always up to date.
- Slower than `locate`, but more accurate and flexible.
- Often used when searching by attributes other than filename. </i>

find <br>
├── -name / -iname <br>
├── -size <br>
├── -user / -group <br>
├── -perm <br>
├── -atime / -mtime / -ctime <br>
├── -not / -or / -and <br>
└── -exec / -ok <br>

#### Search by Name

| Option | Description |
|----------|----------|
| `-name` | Case-sensitive filename search |
| `-iname` | Case-insensitive filename search |

<i> Examples </i>

```bash
find /etc -name passwd
```

```bash
find /etc -iname '*passwd*'
```

---

#### Search by Size

| Pattern | Meaning |
|----------|----------|
| `+size` | Larger than |
| `-size` | Smaller than |
| `size` | Exact size |

<i> Examples </i>

```bash
find /usr/share -size +10M
```

```bash
find /data -size -1M
```

```bash
find /data -size +500M -size -5G
```

---

#### Search by Owner or Group

| Option | Description |
|----------|----------|
| `-user` | Search by owner |
| `-group` | Search by group |

<i> Examples </i>

```bash
find /home -user cipher
```

```bash
find /etc -group lp
```

---

#### Search by Permissions

| Option | Description |
|----------|----------|
| `-perm 755` | Exact permission match |
| `-perm -222` | All specified bits must be present |
| `-perm /222` | Any specified bit may be present |

<i> Examples </i>

```bash
find /usr/bin -perm 755
```
Useful for finding world-writable files:

```bash
find . -perm /002
```


---

#### Search by Time

| Option | Description |
|----------|----------|
| `-atime` | Last access time (days) |
| `-mtime` | Last content modification (days) |
| `-ctime` | Last metadata change (days) |
| `-amin` | Last access time (minutes) |
| `-mmin` | Last content modification (minutes) |
| `-cmin` | Last metadata change (minutes) |

<i> Examples </i>
 
Modified within the last 10 minutes: 

```bash
find /etc -mmin -10
```

Not accessed for more than 300 days:

```bash
find /var/www -atime +300
```

---

#### Combining Conditions

| Option | Description |
|----------|----------|
| `-and` | Both conditions must match |
| `-or` (`-o`) | Either condition may match |
| `-not` | Negate a condition |

<i> Examples </i>

```bash
find /shared \( -user joe -o -user cipher \)
```

```bash
find /shared -user joe -not -group joe
```

---

#### Executing Commands

| Option | Description |
|----------|----------|
| `-exec` | Execute command automatically (powerful but can be dangerous) |
| `-ok` | Ask before executing command (use when performing destructive actions) |

<i> Syntax </i>

```bash
find [options] -exec command {} \;
```

```bash
find [options] -ok command {} \;
```

<i> Examples </i>

```bash
find /etc -iname passwd -exec echo "Found: {}" \;
```

```bash
find /logs -size +100M -exec du -sh {} \;
```

```bash
find /shared -user joe -ok mv {} /tmp/joe/ \;
```
 

### Searching Text with `grep`

<strong> The `grep` command searches for text patterns inside files or command output. </strong>

<i> Common Options </i>

| Option | Description |
|----------|----------|
| `-i` | Ignore letter case |
| `-v` | Show lines that do NOT match |
| `-r` | Search recursively through directories |
| `-l` | Show only filenames containing matches |
| `--color` | Highlight matching text |

---

<strong> Examples: </strong>

- Find lines containing `dns`: `grep dns /etc/services`
- Case-insensitive search: `grep -i dns /etc/services`
- Display all lines except those containing `udp`: `grep -vi udp /etc/services`
- Search all files inside a directory tree: `grep -r keyword /path/to/directory`
- Show only filenames containing the keyword: `grep -rli keyword /path/to/directory`
- Search recursively and highlight matching text: `grep -ri --color root /etc/systemd`

---

<strong> Search Command Output </strong>

- Use `grep` as a filter: `command | grep pattern`

Example:

```bash
ip addr show | grep inet
```

Display only lines containing `inet`.

<i> Notes:

- `grep` searches file contents, not filenames.
- Searches are case-sensitive by default.
- Can be combined with pipes (`|`) to filter command output.
- One of the most commonly used Linux text-processing tools. </i>

<br>
<br>
<br>

**The next topic: [Processes](./05-processes.md)**