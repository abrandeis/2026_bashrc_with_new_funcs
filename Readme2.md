# cust-bash-shell

**Author:** Adam Brandeis  
**Created:** 2026-01-08  
**Shell:** bash 4.x+  
**Platform:** Linux / macOS compatible

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [The Prompt (PS1)](#2-the-prompt-ps1)
3. [Shell Options & History](#3-shell-options--history)
4. [Alias Reference](#4-alias-reference)
5. [Functions Reference](#5-functions-reference)
   - [which](#which)
   - [lcd](#lcd)
   - [cpy](#cpy)
   - [dfc](#dfc)
   - [lsc](#lsc)
   - [du. / du_better](#du--du_better)
   - [topfiles](#topfiles)
   - [histdel](#histdel)
   - [bvi](#bvi)
   - [crongrep](#crongrep)
   - [lessr](#lessr)
   - [cust-bash-shell_help](#cust-bash-shell_help)
6. [Color System](#6-color-system)
7. [Installation](#7-installation)

---

## 1. Project Overview

`cust-bash-shell` is a modular, self-contained bash shell profile system designed to be dropped into any Linux environment and sourced on top of the system default `.bashrc`. It enhances the shell with a rich colored prompt, smart shell options, a curated alias library, and a suite of custom utility functions — all without requiring root access.

The entire system is anchored by a single exported variable `$BASHRC_HOME`, which resolves to the repo root at source time (including through symlinks), making it portable and location-independent.

### File Structure

```
cust-bash-shell/
├── .bashrc_cust                  # Main entry point — prompt, options, HISTIGNORE, sourcing
├── .bashrc_alias                 # All aliases, exports BASHRC_HOME
├── .bashrc_functions             # Function loader — sources all .function_* files
├── colors                        # Shared color variable definitions (C_* exports)
├── cust-bash-shell_help          # help() function listing all available commands
├── default-vars                  # Template for per-script date/path/log variables
├── bashrc_fucntion_alias_source  # Snippet to add to system .bashrc (custbash loader)
├── .function_which               # Function: which
├── .function_cpy                 # Function: cpy
├── .function_lcd                 # Function: lcd
├── .function_dfc                 # Function: dfc
├── .function_lsc                 # Function: lsc / ls_with_counts
├── .function_topfiles            # Function: topfiles
└── .function_du_better           # Function: du. / du_better
```

### How It Loads

The system uses a two-step bootstrap:

1. A small `custbash()` function (from `bashrc_fucntion_alias_source`) is added to the user's system `~/.bashrc`. When invoked, it locates and sources `.bashrc_cust`.
2. `.bashrc_cust` in turn sources `.bashrc_alias`, `.bashrc_functions`, and `colors`. Each file independently resolves `$BASHRC_HOME` via symlink-safe logic — nothing is hardcoded.

---

## 2. The Prompt (PS1)

The prompt is **two lines**:

- **Line 1:** Date/time + full hostname (FQDN)
- **Line 2:** `user@hostname:path]` followed by a neon green cursor

```
Thu Jan 09 02:15 PM  webserver01.prod.example.com
adam@webserver01:/var/log/nginx] █
```

### PS1 Color Map

| Element | Variable | Color |
|---|---|---|
| Date / Time | `$PS_DT` | Cyan (bright) |
| Hostname (default) | `$PSDTHOST` | Green |
| Hostname (HOST1/HOST2 match) | `$PSDTHOST` | Yellow |
| Keyword within hostname | inline | Magenta Bold |
| Username | `$PSUSR` | Magenta Bold |
| `@` symbol | `$PS_AT` | Neon Green |
| `hostname:` separator | `$PSHOST` | Yellow |
| Working directory | `$PSPWD` | White |
| `]` prompt character | `$PSPROMPT` | Neon Green |
| PS2 continuation prompt | `$PS2` | Neon Green → `continue-> ` |

### Hostname Highlighting Logic

On startup, `$FullHost` is set once via `hostname -f`. The prompt then checks whether the FQDN contains configured keywords (`HOST1`, `HOST2`, `HOST3`). If matched, the entire hostname renders in yellow with specific substrings in magenta — giving immediate visual awareness of which environment you're in. Unmatched hostnames render in green.

### Title Bar (`PROMPT_COMMAND`)

The title bar of the terminal window is updated on every prompt render to show:

```
user@HOSTNAME: /current/path    |    HOST_LABEL    |    YOU ARE username    |    [status]    |
```

It also includes a **production hours alert**: the status symbol in the title bar changes based on whether the current time falls within `$prodStartTime` / `$prodEndTime` window.

`PROMPT_COMMAND` also runs `history -a` on every prompt — history is continuously written to disk, so no commands are lost if the session is killed.

---

## 3. Shell Options & History

### `shopt` Options

| Option | Effect |
|---|---|
| `histappend` | Appends to `~/.bash_history` on session close instead of overwriting |
| `histverify` | Shows `!command` history expansion for review before executing |
| `cdspell` | Silently fixes small typos in `cd` paths |
| `checkwinsize` | Recalculates terminal dimensions after each command, prevents line-wrap artifacts |
| `globstar` | Enables `**` recursive glob pattern |
| `cmdhist` (on) | Saves multi-line commands as a single history entry |
| `lithist` (off) | Multi-line commands use semicolons in history, not embedded newlines |

### History Configuration

| Variable | Value | Effect |
|---|---|---|
| `HISTSIZE` | 5000 | Commands kept in memory per session |
| `HISTFILESIZE` | 100000 | Lines stored in `~/.bash_history` on disk |
| `HISTTIMEFORMAT` | `%F %T` | Timestamps every history entry (`2026-01-09 14:22:07`) |
| `HISTCONTROL` | `ignorespace:ignoredups` | Commands prefixed with space not saved; consecutive duplicates suppressed |

### HISTIGNORE — What Gets Filtered

Commands in these categories are never written to history:

| Group | Patterns |
|---|---|
| Navigation / housekeeping | `ll`, `pwd`, `clear`, `cls`, `exit`, `logout`, `ag*` |
| History commands | `history*`, `hist*`, `hcg*` |
| Profile management | `*custbash*`, `*sL*`, `mybashrc*`, `newsource*`, `*SUPERbash*` |
| History edit functions | `histdel*`, `histdel_last*` |

### Tab Completion

Custom completions configured for:

- `type, which, man, whatis, locate` → complete with command names
- `ll, ls, lcd, goal` → complete with directories and files
- `ssh, scp, rsync, ping, sftp, host, jump` → complete from `~/.ssh/known_hosts` and `~/.ssh/config` Host entries, with domain suffixes stripped for brevity

---

## 4. Alias Reference

### Navigation

| Alias | Expands To | Notes |
|---|---|---|
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `....` | `cd ../../..` | Go up three directories |
| `~` | `cd ~` | Go to home directory |
| `-` | `cd -` | Go to previous directory |
| `cd..` | `cd ..` | Forgives missing-space typo |

### Listing

| Alias | Expands To | Notes |
|---|---|---|
| `ls` | `ls --color=auto` | Always colorized |
| `ll` | `ls -alF --group-directories-first` | Long list, dirs first |
| `la` | `ls -A` | Show hidden files, no `.` and `..` |
| `l` | `ls -CF` | Compact, classified listing |
| `goal` | `ls -goal --color=always` | No-owner long format, always colored |
| `lsl` | `ls -latr` | Long, all, time-sorted, reverse |

### Grep Variants

| Alias | Expands To | Notes |
|---|---|---|
| `grep` | `grep --color=auto` | Default colored grep |
| `cgrep` | `grep --color=always` | Force color (useful in pipes) |
| `egrep` | `egrep --color=always` | Extended regex, colored |
| `fgrep` | `fgrep --color=always` | Fixed string, colored |
| `igrep` | `grep --color=always -i` | Case-insensitive |
| `psefg` | `ps -ef \| grep -v grep \| grep $1` | Process search, no self-match |
| `hcg` | `history \| cgrep` | Search history with color |
| `ag` | `alias \| cgrep` | Search aliases with color |
| `cg` | `crontab -l \| cgrep` | Search crontab with color |

### System Info

| Alias | Expands To | Notes |
|---|---|---|
| `df` | `df -h` | Human-readable disk usage |
| `du` | `du -h` | Human-readable directory sizes |
| `free` | `free -h` | Human-readable memory |
| `psu` | `ps aux --sort=-%mem \| head -15` | Top 15 processes by memory |
| `pscpu` | `ps aux --sort=-%cpu \| head -15` | Top 15 processes by CPU |
| `openports` | `sudo lsof -i -P -n \| grep LISTEN` | All open listening ports |
| `ports` | `ss -tulpen` | Socket stats (TCP/UDP) |
| `ip4` | `ip -4 addr` | IPv4 addresses |
| `ip6` | `ip -6 addr` | IPv6 addresses |
| `ipr` | `ip route` | Routing table |

### Safety & Convenience

| Alias | Expands To | Notes |
|---|---|---|
| `cp` | `cp -i` | Always prompt before overwrite |
| `mv` | `mv -i` | Always prompt before overwrite |
| `rm` | `rm -i` | Always prompt before delete |
| `please` | `sudo` | Polite sudo shortcut |
| `sudoe` | `sudo -E` | sudo preserving environment vars |
| `cls` | `printf '\e[H\e[2J'` | Clear without erasing scrollback buffer |
| `reload` | `source ~/.bashrc` | Reload system bashrc |
| `newsource` | `source ~/.bashrc && source .bashrc_cust` | Reload everything |
| `hist` | `history` | Short alias |
| `myproc` | `pgrep -fl` | Find processes by name |
| `kill9` | `xargs -r kill -9` | Kill PIDs from stdin |
| `v` | `vim` / `nvim` / `vi` (first found) | Smart editor shortcut |

### vim / vi Overrides

Both `vim` and `vi` are aliased to load your custom vimrc:

```bash
vim -u ${BASHRC_HOME}/.vim/.vimrc
```

### Profile Sync (rsync)

| Alias | Purpose |
|---|---|
| `sLl_bash` | Live rsync of `$BASHRC_HOME` to a remote target |
| `sLdr_bash` | Dry-run preview of the same rsync |

**Usage:**

```bash
sLdr_bash user@remotehost:/home/user/cust-bash-shell  # dry run first
sLl_bash  user@remotehost:/home/user/cust-bash-shell  # live sync
```

### Docker Aliases (conditional — only loads if `docker` is installed)

| Alias | Expands To |
|---|---|
| `dps` | `docker ps` |
| `dpa` | `docker ps -a` |
| `di` | `docker images` |
| `dlogs` | `docker logs -f` |
| `drm` | `docker rm` |
| `drmi` | `docker rmi` |

### Kubernetes Aliases (conditional — only loads if `kubectl` is installed)

| Alias | Expands To |
|---|---|
| `k` | `kubectl` |
| `kgp` | `kubectl get pods` |
| `kgs` | `kubectl get svc` |
| `kgn` | `kubectl get nodes` |
| `kctx` | `kubectl config current-context` |

---

## 5. Functions Reference

---

### `which`

**File:** `.function_which`  
**Usage:** `which <name>`

Replaces the system `which` with a smarter version that identifies whether a name is an **alias**, **function**, **builtin**, **file**, or **keyword** — and shows you exactly where it's defined. The system `which` only finds binaries in `$PATH`; this version handles everything in your shell.

#### Behavior by Type

| Type | Output |
|---|---|
| `alias` | Prints type, runs `type -a`, then greps all bash config files to show the file and line number where the alias is defined |
| `function` | Prints type, uses `declare -F` with `extdebug` to show the exact file and line number, then prints the full function body |
| `builtin` / `file` / `keyword` | Prints type, suggests `man $1`, runs `type -a`, runs `man -f` for one-line description |
| not found | Red error message |
| no argument | Colored usage/help with examples |

#### Examples

```bash
which ll
# ll is a           : alias
# alias ll='ls -alF --group-directories-first'
# ll is located in  :
# /home/adam/cust-bash-shell/.bashrc_alias:42:alias ll='ls -alF ...'

which cpy
# cpy is a          : function
# cpy is located in : cpy /home/adam/cust-bash-shell/.function_cpy 5

which for
# for is a          : keyword
# See: man for

which awk
# awk is a          : file
# /usr/bin/awk
# awk - pattern-directed scanning and processing language

which nonexistent
# nonexistent not found or not a valid command
```

---

### `lcd`

**File:** `.function_lcd`  
**Usage:** `lcd [dir]` or `lcd -h`

Combines `cd` and `ls` into a single command. Changes to the target directory and immediately lists its contents in `dir -latrh --color=always` format. With no argument, lists the current directory. Only runs the listing in interactive shells (`$PS1` is set).

#### Examples

```bash
lcd /var/log
# Changes to /var/log and lists contents (time-sorted, reverse, human-readable)

lcd ..
# Goes up one level and lists

lcd
# Lists current directory (no cd)

lcd -h
# Prints usage and description
```

---

### `cpy`

**File:** `.function_cpy`  
**Usage:** `cpy <file_or_directory>`

Creates a date-stamped backup of any file or directory in a single command.

- **Backup format:** `filename.YYYYMMDD.bak`
- **Collision handling:** If today's backup already exists, auto-increments: `filename.20260109_2.bak`, `_3.bak`, etc.
- **Directories:** Fully recursive with preserved attributes (`cp -pr`)
- **Feedback:** Shows the source and last 3 matching backups after creation

#### Examples

```bash
cpy nginx.conf
# Creates nginx.conf.20260109.bak

cpy nginx.conf
# Run again same day → nginx.conf.20260109_2.bak

cpy /etc/ssh
# Recursively backs up the directory → /etc/ssh.20260109.bak/

cpy
# No argument: prints usage/help

cpy does-not-exist
# Error: "does-not-exist" file or directory not found!
```

---

### `dfc`

**File:** `.function_dfc`  
**Usage:** `dfc [threshold]` | `dfc -h` | `dfc --help`

Colorized disk usage display. Runs `df -h` with:

- **Header** in cyan
- **Any Use% exceeding threshold** highlighted in red (default: 75%)
- **Blank line**, then a **TOTAL line** in yellow

Supports GNU `df --total` and BSD/macOS environments (portably computes totals when `--total` is unavailable).

#### Usage

```bash
dfc            # default threshold 75%
dfc 90         # flag mounts > 90% in red
dfc -h         # show help
```

#### Example Output

```
Filesystem      Size  Used Avail Use% Mounted on    ← cyan header
/dev/sda1        50G   18G   30G  37% /
/dev/sdb1       500G  420G   60G  85% /data         ← red (exceeds threshold)
tmpfs           3.9G  1.2M  3.9G   1% /dev/shm

total           554G  438G  90G  79%  -              ← yellow total line
```

---

### `lsc`

**File:** `.function_lsc`  
**Alias:** `lsc` (maps to `ls_with_counts`)  
**Usage:** `lsc [dir]`

Enhanced directory listing (`ls -latr`) that appends a yellow summary of directory count, file count, and total at the bottom. Counts are accurate for all immediate children including hidden files, using `find -mindepth 1 -maxdepth 1`.

#### Examples

```bash
lsc
# ... normal ls -latr output ...
#
# dirs = 2
# files = 7
# total = 9

lsc /var/log
# Same output for a specific directory
```

---

### `du.` / `du_better`

**File:** `.function_du_better`  
**Alias:** `du.` (maps to `du_better`)  
**Usage:** `du. [dir]`

Improved `du` that lists immediate children sorted by size (largest first), with human-readable right-aligned sizes, and a yellow TOTAL line at the end.

Flags used: `du -ahx --max-depth=1`  
- `-a` — show files and directories  
- `-h` — human-readable sizes  
- `-x` — stay on one filesystem (no NFS/network traversal)

> **Note:** The `-x` flag intentionally prevents traversal into mounted filesystems. This keeps scans fast and avoids hanging on NFS mounts.

#### Examples

```bash
du. /var/log
#       45M  ./nginx
#       12M  ./apache2
#        8M  ./syslog
#      3.2M  ./auth.log
#        71M  TOTAL       ← yellow

du.
# Defaults to current directory
```

---

### `topfiles`

**File:** `.function_topfiles`  
**Usage:** `topfiles [N] [--color=auto|always|never|--no-color]`

Recursively finds the top N largest files under the current directory, sorted by size descending. Displays human-readable size, last-modified timestamp, and full path. Includes a timestamped header.

- Default: top 10
- Uses GNU `find -printf` for performance; falls back to BSD `stat` on macOS
- Color control: `auto` (TTY-aware), `always`, `never`, `--no-color`

#### Examples

```bash
topfiles           # top 10
topfiles 5         # top 5
topfiles 25        # top 25
topfiles --no-color  # plain output for logs/pipes
topfiles 15 --color=always  # force color in pipes
```

#### Example Output

```
Top 10 largest files under: /home/adam
As of: 2026-01-09 14:22:07 EST
------------------------------------------------------------
   2.3G  2025-12-01 09:14  ./backups/server_backup.tar.gz
 890.0M  2026-01-05 18:30  ./VMs/ubuntu22.vmdk
 440.2M  2025-11-22 11:00  ./Downloads/centos9.iso
  12.4M  2026-01-09 08:44  ./logs/app.log
   8.1M  2026-01-07 17:03  ./.vim/spell/en.utf-8.spl
```

---

### `histdel`

**File:** `.bashrc_functions`  
**Usage:** `histdel`

Deletes the last 2 lines from `$HISTFILE` on disk using in-place `sed`, reloads history into the current session, and shows the last 5 entries. Useful for scrubbing an accidentally typed password or sensitive string.

> **Note:** `histdel` is in HISTIGNORE, so running it never leaves a trace in history.

#### Example

```bash
export DB_PASS=mysecretpassword123   # oops
histdel
# Last 2 lines removed from /home/adam/.bash_history.
#   502  ls -la
#   503  cd /var/log
#   504  tail -f syslog
#   505  dfc
#   506  ll
```

---

### `bvi`

**File:** `.bashrc_functions`  
**Usage:** `bvi [file...]`

Smart vim launcher that detects the installed Vim major version and selects the correct binary, always loading your custom vimrc from `$BASHRC_HOME/.vim/.vimrc`.

| Vim Version | Binary Used |
|---|---|
| 7.x | `vim` |
| 8.x | `/usr/bin/vim` |
| Unknown | `/usr/bin/vim` with a warning |

All arguments are passed through to vim normally.

```bash
bvi nginx.conf       # opens with correct binary + custom vimrc
bvi +100 app.log     # standard vim args work fine
```

---

### `crongrep`

**File:** `.bashrc_functions`  
**Usage:** `crongrep <pattern>`

Case-insensitive crontab search that returns the matching line **plus the comment header block above it** — so you see each cron job in context rather than a bare line with no description.

#### Example

```bash
crongrep backup
# # Nightly DB backup
# 0 2 * * * /opt/scripts/db_backup.sh >> /var/log/db_backup.log 2>&1

crongrep nginx
# # Restart nginx if down
# */5 * * * * /opt/scripts/check_nginx.sh
```

---

### `lessr`

**File:** `.bashrc_cust`  
**Usage:** `lessr <file>`

Enhanced `less` wrapper with a rich status bar. The global `$LESS` environment variable applies the same options to all `less` invocations system-wide (including `man` pages).

#### less Options

| Flag | Effect |
|---|---|
| `-f` | Force open non-regular files (pipes, devices) |
| `-F` | Quit immediately if content fits on one screen |
| `-R` | Pass through ANSI color codes (rendered, not raw) |
| `-J` | Show a status column on the left margin |
| `-P` | Custom prompt: filename, line range, byte range, percentage |

#### Man Page Colorization (`LESS_TERMCAP_*`)

| Element | Color |
|---|---|
| Bold text (section headers) | Cyan on black |
| Standout / info box | White on blue |
| Underlined text | Bold underlined Green |

---

### `cust-bash-shell_help`

**File:** `cust-bash-shell_help`  
**Usage:** `cust-bash-shell_help`

Prints a colored quick-reference of all available custom functions and their one-line descriptions. The built-in help page for the profile.

```bash
cust-bash-shell_help
```

---

## 6. Color System

Two separate color variable sets exist:

- **`C_*` variables** (from `colors`) — for use in script output and function messages  
- **`PSC_*` variables** (from `.bashrc_cust`) — for prompt construction; include `\[...\]` non-printing wrappers required for correct readline cursor positioning

### Script Colors (`C_*`)

| Variable | Color | ANSI Code | Typical Use |
|---|---|---|---|
| `C_NC` | Reset | `\e[0m` | Always end colored output with this |
| `C_RD` | Bold Red | `\e[1;31m` | Errors, warnings |
| `C_YW` | Bold Yellow | `\e[1;33m` | Labels, important text |
| `C_CY` | Bold Cyan | `\e[1;36m` | Command names, highlights |
| `C_GN` | Neon Green | `\e[38;5;46m` | Success messages, examples |

> **Tip:** `colors` also sets `LS_COLORS` to add `ow=1;0;42` if not already set, making other-writable directories display with a green background instead of the default hard-to-read dark blue.

---

## 7. Installation

### Step 1 — Clone the repo

```bash
git clone <your-repo-url> ~/ADAM/cust-bash-shell
```

### Step 2 — Add the loader to your system `.bashrc`

Copy the contents of `bashrc_fucntion_alias_source` into your `~/.bashrc`:

```bash
cat bashrc_fucntion_alias_source >> ~/.bashrc
source ~/.bashrc
```

This adds the `custbash()` and `SUPERbash()` loader functions.

### Step 3 — Activate

```bash
custbash    # or: SUPERbash  (both do the same thing)
```

Your prompt will change immediately and all functions and aliases will be available.

To **auto-load on every login**, add `custbash` as a line at the bottom of your `~/.bashrc` (after the loader functions).

### Step 4 — Reload after changes

```bash
newsource    # sources both ~/.bashrc and .bashrc_cust
```

### Syncing to Other Servers

```bash
sLdr_bash user@remotehost:/home/user/cust-bash-shell  # dry run first
sLl_bash  user@remotehost:/home/user/cust-bash-shell  # live sync
```

---

## Quick Reference Card

| Command | What It Does |
|---|---|
| `which <name>` | Find where any alias/function/command is defined |
| `lcd [dir]` | `cd` into a directory and list it immediately |
| `cpy <file>` | Date-stamped backup of any file or directory |
| `dfc [%]` | Colorized disk usage with threshold alerting |
| `lsc [dir]` | `ls -latr` with dir/file count summary |
| `du. [dir]` | Size-sorted depth-1 du with total |
| `topfiles [N]` | Top N largest files recursively |
| `histdel` | Erase last 2 lines from history file |
| `bvi [file]` | Open vim with version-aware config |
| `crongrep <pat>` | Search crontab, show results with context headers |
| `lessr <file>` | Enhanced less with rich status bar |
| `cust-bash-shell_help` | Show all available custom commands |

---

*cust-bash-shell — Adam Brandeis — 2026*
