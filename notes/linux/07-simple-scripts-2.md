# Simple Scripts 2

> Notes based on Linux Bible and personal learning experiments.

Table of Contents:
- [Simple Scripts 2](#simple-scripts-2)
  - [Programming contructs](#programming-contructs)
    - [Bash `if` Statements](#bash-if-statements)
      - [if...else](#ifelse)
      - [if...elif...else](#ifelifelse)
    - [Bash Test Operators](#bash-test-operators)
      - [File Tests](#file-tests)
      - [String Tests](#string-tests)
      - [Numeric Comparisons](#numeric-comparisons)
      - [Logical Operators](#logical-operators)
      - [File Time Comparisons](#file-time-comparisons)
      - [Rarely Used (System Administration)](#rarely-used-system-administration)
    - [Bash Shortcuts for `if`](#bash-shortcuts-for-if)
      - [Execute if FALSE (`||`)](#execute-if-false-)
      - [Execute if TRUE (`&&`)](#execute-if-true-)
      - [One-line if...else (`&&` + `||`)](#one-line-ifelse---)
    - [`case` command](#case-command)
    - [`for...do` Loop](#fordo-loop)
      - [General Syntax](#general-syntax)
      - [C-style for Loop](#c-style-for-loop)
    - [`while...do` and `until...do` Loops](#whiledo-and-untildo-loops)
      - [`while` Loop](#while-loop)
      - [`until` Loop](#until-loop)
    - [Text manipulation programs](#text-manipulation-programs)
      - [`grep` — Search for Patterns in Text](#grep--search-for-patterns-in-text)
      - [`cut` - Remove sections of lines of text](#cut---remove-sections-of-lines-of-text)
      - [`tr` — Translate or Delete Characters](#tr--translate-or-delete-characters)
      - [`sed` — Stream Editor](#sed--stream-editor)

## Programming contructs

### Bash `if` Statements

Used for conditional execution.

---

#### if...else

```bash
if [ condition ]; then
    commands
else
    commands
fi
```

Example:

```bash
STRING="Friday"

if [ "$STRING" = "Friday" ]; then
    echo "WhooHoo. Friday."
else
    echo "Will Friday ever get here?"
fi
```

---

#### if...elif...else

```bash
if [ condition1 ]; then
    commands
elif [ condition2 ]; then
    commands
else
    commands
fi
```

Example:

```bash
filename="$HOME"

if [ -f "$filename" ]; then
    echo "Regular file"
elif [ -d "$filename" ]; then
    echo "Directory"
else
    echo "Unknown"
fi
```

---

### Bash Test Operators

#### File Tests

| Operator | Meaning | Memory Trick |
|----------|---------|-------------|
| `-e file` | File exists | **e = exists** |
| `-f file` | Regular file | **f = file** |
| `-d file` | Directory | **d = directory** |
| `-r file` | Readable | **r = read** |
| `-w file` | Writable | **w = write** |
| `-x file` | Executable | **x = execute** |
| `-s file` | Exists and size > 0 | **s = size** |
| `-L file` | Symbolic link | **L = Link** |
| `-h file` | Symbolic link | Same as `-L` |
| `-O file` | You own the file | **O = Owner** |

---

#### String Tests

| Operator | Meaning | Memory Trick |
|----------|---------|-------------|
| `-n string` | String is not empty | **n = not empty** |
| `-z string` | String is empty | **z = zero length** |
| `str1 = str2` | Strings are equal | Standard equality |
| `str1 != str2` | Strings are not equal | Standard inequality |

---

#### Numeric Comparisons

| Operator | Meaning | Memory Trick |
|----------|---------|-------------|
| `-eq` | Equal | **eq = equal** |
| `-ne` | Not equal | **ne = not equal** |
| `-gt` | Greater than | **gt = greater than** |
| `-lt` | Less than | **lt = less than** |
| `-ge` | Greater or equal | **ge = greater/equal** |
| `-le` | Less or equal | **le = less/equal** |

---

#### Logical Operators

| Operator | Meaning | Memory Trick |
|----------|---------|-------------|
| `expr1 -a expr2` | AND | **a = and** |
| `expr1 -o expr2` | OR | **o = or** |
| `! expr` | NOT | Negation |

---

#### File Time Comparisons

| Operator | Meaning | Memory Trick |
|----------|---------|-------------|
| `file1 -nt file2` | file1 is newer | **nt = newer than** |
| `file1 -ot file2` | file1 is older | **ot = older than** |
| `file1 -ef file2` | Same file/link | **ef = equal file** |

---

#### Rarely Used (System Administration)

| Operator | Meaning |
|----------|---------|
| `-b file` | Block device |
| `-c file` | Character device |
| `-g file` | SGID bit set |
| `-k file` | Sticky bit set |
| `-p file` | Named pipe |
| `-S file` | Socket |
| `-t fd` | Terminal descriptor |
| `-u file` | SUID bit set |

---

### Bash Shortcuts for `if`

Instead of writing a full `if...then`, Bash allows short one-line conditions.

---

#### Execute if FALSE (`||`)

Syntax:

```bash
[test] || command
```

Meaning: If the test is **false**, execute the command.

Example:

```bash
dirname="/tmp/testdir"

[ -d "$dirname" ] || mkdir "$dirname"
```

---

#### Execute if TRUE (`&&`)

Syntax:

```bash
[test] && command
```

Meaning: If the test is **true**, execute the command.

Example:

```bash
[ $# -ge 3 ] && echo "There are at least 3 arguments."
```

---

#### One-line if...else (`&&` + `||`)

Syntax:

```bash
[test] && command1 || command2
```

Meaning:

```text
If test is TRUE  → run command1
Else             → run command2
```

Example:

```bash
dirname="mydirectory"

[ -e "$dirname" ] && echo "$dirname already exists" || mkdir "$dirname"
```

---

### `case` command

`case` is used when you need to check one value against multiple possible options.

It is often cleaner and easier to read than many nested `if...elif...else` statements.

---

<strong> General Syntax </strong>

```bash
case VARIABLE in
    value1)
        commands
        ;;
    value2)
        commands
        ;;
    *)
        default commands
        ;;
esac
```

<strong> Important Parts </strong>

| Syntax | Meaning |
|----------|----------|
| `case` | Start of case statement |
| `value)` | Condition to match |
| `;;` | End of a case branch |
| pipe | OR |
| `*` | Default / catch-all case |
| `esac` | End of case (`case` backwards) |

---

<i> Example </i>

```bash
read -p "Choose a color: " color
case "$color" in
    red)
        echo "You chose red."
        ;;
    blue)
        echo "You chose blue."
        ;;
    green)
        echo "You chose green."
        ;;
    *)
        echo "Unknown color."
        ;;
esac
```

---

<i> Using OR (`|`) </i>

```bash
case "$answer" in
    y|Y)
        echo "Yes"
        ;;
    n|N)
        echo "No"
        ;;
    *)
        echo "Invalid input"
        ;;
esac
```

---

### `for...do` Loop

`for` loop is used to repeat actions for every item in a list.

---

#### General Syntax 

```bash
for VARIABLE in LIST
do
    commands
done
```

---

<i> Example </i>

```bash
for NAME in John Paul George Ringo
do
    echo "$NAME"
done
```

Output:

```text
John
Paul
George
Ringo
```

---

<i> Example with Files </i>

```bash
for FILE in *
do
    echo "$FILE"
done
```

`*` means all files in the current directory.

---

#### C-style for Loop

Structure:

```bash
for ((initialization; condition; increment))
```

Example:

```bash
for ((i=1; i<=10; i++))
do
    echo "$i"
done
```

---

### `while...do` and `until...do` Loops

Used when repetition depends on a condition.

---

#### `while` Loop

<strong> General Syntax </strong>

```bash
while [ condition ]
do
    commands
done
```

---

<i> Example </i>

```bash
N=0

while [ $N -lt 5 ]
do
    echo $N
    let N=$N+1
done
```

Output:

```text
0
1
2
3
4
```

---

#### `until` Loop

<strong> General Syntax </strong>

```bash
until [ condition ]
do
    commands
done
```

---

<i> Example </i>

```bash
N=0

until [ $N -eq 5 ]
do
    echo $N
    let N=$N+1
done
```

Output:

```text
0
1
2
3
4
```

---

### Text manipulation programs

#### `grep` — Search for Patterns in Text

`grep` (General Regular Expression Print) is used to search for text patterns in files or command output.

```bash
grep PATTERN file
```

Searches for lines containing `PATTERN`.

---

<i> Examples </i>

- Find all lines containing `/home` inside a file: `grep /home /etc/passwd`
- Searches the output of the command `env`: `env | grep ^HO`

<i> `^` - Find lines that START with </i>

---

#### `cut` - Remove sections of lines of text

Used to extract specific columns (fields) from text.

```bash
cut -d'SEPARATOR' -fFIELD
```

| Option | Meaning |
|----------|----------|
| `-d` | Delimiter (separator) |
| `-f` | Field number |

---

<i> Example </i>

File: `john:x:1000:/home/john`

```bash
$ cut -d':' -f4
/home/john
```

---

#### `tr` — Translate or Delete Characters

Used to replace or remove characters.

```bash
tr OLD NEW
```

---

<strong> Convert Uppercase → Lowercase </strong>

```bash
$ echo "HELLO" | tr 'A-Z' 'a-z'
hello
```

---

<strong> Replace Spaces with Underscores </strong>

```bash
$ echo "Hello World" | tr ' ' '_'
Hello_World
```

---

<strong> Useful Character Classes </strong>

| Class | Meaning |
|---------|---------|
| `[:upper:]` | Uppercase letters |
| `[:lower:]` | Lowercase letters |
| `[:digit:]` | Numbers |
| `[:blank:]` | Spaces and tabs |

---

#### `sed` — Stream Editor

Used to search, replace, delete, or modify text automatically.

Think of it as: Find & Replace for Linux

---

<strong> Search Lines </strong>

Show lines containing a pattern:

```bash
sed -n '/home/p' /etc/passwd
```

Meaning:

```text
Find "home"
Print matching lines
```

---

<strong> Replace Text </strong>

```bash
sed 's/OLD/NEW/'
```

- Replace First Match: `sed 's/Mac/Linux/'`
- Replace All Matches (`g` = global): `sed 's/Mac/Linux/g'`

<i> Example </i>

```bash
sed 's/Mac/Linux/g' file.txt
```

---

<strong> Delete Pattern </strong>

Replace text with nothing:

```bash
sed 's/text//'
```

Example:

```bash
sed 's/Mac//g'
```

Removes all occurrences of:

```text
Mac
```

---

<strong> Remove Trailing Spaces </strong>

```bash
sed 's/ *$//'
```

Meaning:

```text
Remove spaces at the end of a line
```

---

<strong> Save Result to File </strong>

```bash
sed 's/Mac/Linux/g' file.txt > newfile.txt
```

---

<strong> Common Symbols </strong>

| Symbol | Meaning |
|----------|----------|
| `s` | substitute |
| `/old/new/` | replace old with new |
| `g` | replace all occurrences |
| `p` | print |
| `$` | end of line |
| `*` | zero or more characters |

---

<br>
<br>
<br>

**The next topic: [System Administration](./08-sys-admin.md)** 