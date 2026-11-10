# Simple Scripts 1

> Notes based on Linux Bible and personal learning experiments.

Table of Contents:
- [Simple Scripts 1](#simple-scripts-1)
  - [Understanding Shell Scripts](#understanding-shell-scripts)
  - [Executing and Debugging shell scripts](#executing-and-debugging-shell-scripts)
    - [Ways to Execute a Script](#ways-to-execute-a-script)
    - [Command-Line Arguments](#command-line-arguments)
    - [Comments](#comments)
    - [Debugging Techniques](#debugging-techniques)
  - [Understanding Shell Variables](#understanding-shell-variables)
    - [Special Shell Positional Parameters](#special-shell-positional-parameters)
    - [Reading User Input](#reading-user-input)
    - [Parameter Expansion in Bash](#parameter-expansion-in-bash)
  - [Performing arithmetic in shell scripts](#performing-arithmetic-in-shell-scripts)
    - [Arithmetic with `let`](#arithmetic-with-let)
    - [Arithmetic with `expr`](#arithmetic-with-expr)
    - [Arithmetic with `bc`](#arithmetic-with-bc)
    - [Random Numbers](#random-numbers)
    - [Incrementing Variables](#incrementing-variables)

## Understanding Shell Scripts

<strong> A shell script is a text file containing a sequence of shell commands that can be executed automatically. </strong>

Shell scripts are similar to Windows batch files. They can contain: commands, variables, loops, conditions, functions, arithmetic operations. Shell scripts can automate repetitive tasks.

<strong> Good Practices </strong>

- Write scripts in small stages
- Test frequently
- Add comments
- Keep logic simple and readable
- Use `echo` for debugging

## Executing and Debugging shell scripts

### Ways to Execute a Script

1. Run Through Bash

```bash
bash myscript
```

Requirements:

- script does not need execute permission
- Bash interprets the file directly

---

2. Run as a Program

Add a shebang (#!) at the top:

```bash
#!/bin/bash
```
The first line of a script can specify which interpreter should run it. This tells Linux: Use Bash to execute this script.

Make the file executable:

```bash
chmod +x myscript
```

Run it:

```bash
./myscript
```

---

### Command-Line Arguments 

Anything after the script name is an argument.

Example:

```bash
./myscript file.txt
```

Here `file.txt` is a command-line argument.

---

### Comments 

Use `#` for comments.

```bash
echo "Hello"  # Inline comment
```

---

### Debugging Techniques

1. Use `echo`

```bash
echo "Processing file..."
```

Allows you to verify program flow.

---

2. Show Executed Commands

```bash
bash -x myscript
```

or inside the script:

```bash
set -x
```

Display each command before execution.

Useful for troubleshooting.

---

## Understanding Shell Variables

<strong> Variables store data that can be reused in a shell script. </strong>

---

<strong> Creating Variables </strong>

Syntax:

```bash
$ NAME=value
$ CITY="Springfield"
```

---

<strong> Command Substitution </strong>

A variable can store the output of a command.

<i>Example: </i>

`MYDATE=$(date)` is equivalent to `MYDATE=`date`.

---

<strong> Escaping Special Characters </strong>

Some characters have special meaning in Bash:

```text
$  `  *  !
```

Use a backslash (`\`) to treat a character literally:

```bash
echo \$HOME
```

Output:

```text
$HOME
```

---
 
<strong> Quotes </strong>

| Quotes | Behavior |
|----------|----------|
| `' '` | Everything is treated literally |
| `" "` | Variables and commands are expanded |
| No quotes | Shell expands variables, wildcards, commands |

<i> Examples </i>

- `echo '$HOME'`: $HOME
- `echo "$HOME"`: /home/user
- `echo $HOME`: /home/user

### Special Shell Positional Parameters

<strong> Positional parameters store command-line arguments passed to a script. </strong>

| Variable | Meaning |
|----------|----------|
| `$0` | Script name (or path used to run it) |
| `$1` | First argument |
| `$2` | Second argument |
| `$3...$n` | Next arguments |
| `$#` | Number of arguments |
| `$@` | All arguments |
| `$?` | Exit status of the last command |

<i> Note: <br>
the result of `$?`: <br>
0     → success <br>
≠ 0   → error
</i>

---

### Reading User Input

<strong> `read` Command </strong>

Used to get input from the user.

Syntax:

```bash
read variable
```

---

<strong> Prompting the User </strong>

Use `-p` to display a message:

```bash
read -p "Enter your name: " name
```

---

<strong> Reading Multiple Values </strong>

```bash
read adj1 noun1 verb1
```

Input:

```text
hairy football danced
```

Result:

```text
adj1  = hairy
noun1 = football
verb1 = danced
```

---

<strong> Example Script </strong>

```bash
#!/bin/bash

read -p "Type adjective noun verb: " adj1 noun1 verb1

echo "He sighed and $verb1 to the elixir."
echo "Then he ate the $adj1 $noun1."
```

Input:

```text
hairy football danced
```

Output:

```text
He sighed and danced to the elixir.
Then he ate the hairy football.
```

### Parameter Expansion in Bash

<strong> Parameter expansion allows you to modify or extract parts of variables. </strong>

---

Basic Syntax

These are equivalent:

```bash
$CITY
```

```bash
${CITY}
```

Curly braces are useful when the variable is next to other text:

```bash
echo "${CITY}_backup"
```

---

<strong> Default Value </strong>

- `${var:-value}`: If a variable is empty or not set, use a default value.

Example:

```bash
THIS="Example"

THIS=${THIS:-"Not Set"}
THAT=${THAT:-"Not Set"}
```

Results:

```text
THIS = Example
THAT = Not Set
```

---

<strong> Removing Text from the Beginning </strong>

- `${var#pattern}`: Remove the shortest match from the front.
- `${var##pattern}`: Remove the longest match from the front.

Example:

```bash
MYFILENAME=/home/digby/myfile.txt

FILE=${MYFILENAME##*/}
```

Result:

```text
myfile.txt
```

---

<strong> Removing Text from the End </strong>

- `${var%pattern}`: Remove the shortest match from the end.
- `${var%%pattern}`: Remove the longest match from the end.

Example:

```bash
DIR=${MYFILENAME%/*}
```

Result:

```text
/home/digby
```

---

<strong> Practical Example </strong>

```bash
MYFILENAME=/home/digby/myfile.txt

FILE=${MYFILENAME##*/}
DIR=${MYFILENAME%/*}
NAME=${FILE%.*}
EXTENSION=${FILE##*.}
```

Results:

| Variable | Value |
|-----------|--------|
| MYFILENAME | /home/digby/myfile.txt |
| FILE | myfile.txt |
| DIR | /home/digby |
| NAME | myfile |
| EXTENSION | txt |

---

<strong> Most Useful Forms </strong>
 
- `${var:-value}`: Default value if variable is empty.
- `${FILE##*/}`: Get filename from path.
- `${PATH%/*}`: Get directory from path.
- `${FILE%.*}`: Get filename without extension.
- `${FILE##*.}`: Get extension.

## Performing arithmetic in shell scripts

<strong> Bash variables are untyped, but Bash can automatically treat values as numbers when performing arithmetic. </strong>

---

### Arithmetic with `let`

Syntax:

```bash
let RESULT=$BIGNUM/16
```

Result:

```text
RESULT = 64
```
 
<i> Note: No spaces around operators. Correct: `let RESULT=$BIGNUM/16`, Wrong: `let RESULT = $BIGNUM / 16`.</i>

---

### Arithmetic with `expr`

Syntax:

```bash
RESULT=`expr $BIGNUM / 16`
```

Result:

```text
64
```

<i> Note: Spaces are required. Correct: `expr 1024 / 16`, Wrong: `expr 1024/16`.</i>

---

### Arithmetic with `bc`

Syntax:

```bash
RESULT=`echo "$BIGNUM / 16" | bc`
```

Result:

```text
64
```

Features:

- Supports floating-point numbers
- Flexible spacing

---

### Random Numbers

```bash
let foo=$RANDOM
echo $foo
```

`$RANDOM` generates a random integer.

---

### Incrementing Variables

<strong> Pre-increment: Increase first, then use value </strong>

```bash
I=1
echo $((++I))
```

Output:

```text
2
```

---

<strong> Post-increment: Use current value, then increase </strong>

```bash
I=1
echo $((I++))
echo $I
```

Output:

```text
1
2
```

<br>
<br>
<br>

**The continuation: [Simple Scripts 2](./07-imple-scripts-2.md)**