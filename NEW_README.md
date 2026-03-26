# Advanced Custom Bash & Vim Profile
**Author:** Adam Brandeis  
**Version:** 1.3 (Vim & UX Integration)

A modular, high-productivity environment designed for system administration, DevOps, and advanced terminal-based editing.

---

## 1. Profile Architecture
* **Bash**: Modularized into `.bashrc_cust`, `.bashrc_alias`, and a dynamic `.bashrc_functions` loader.
* **Vim**: A centralized `.vimrc` that enhances the standard editor into a context-aware IDE with custom status reporting.

---

## 2. Visual Identity & Status Reporting

### Bash Prompt (PS1)
* **Two-Line Interface**: Environmental metadata (Date/Time/FQDN) sits on the top line; User/Host/PWD sits on the bottom.
* **Production Awareness**: Automatic Magenta highlighting for sensitive hostnames to prevent accidental command execution.

### Vim Status Line
* **State Awareness**: Explicitly displays active mode (`[INSERT]` vs `[NORMAL]`).
* **Unsaved Changes**: A `[+]` mark appears next to the filename when the buffer is modified.
* **File Metrics**: Real-time line, column, and file percentage tracking.

---

## 3. Specialized Utility Functions

### File & Disk Management
* **`cpy`**: Safety-first backup tool; creates `.bak` files with date-stamping and auto-incrementing suffixes.
* **`dfc`**: Colorized disk usage; highlights partitions >75% in Red.
* **`topfiles [N]`**: Recursively lists the largest files in the current directory tree.

### Navigation & Discovery
* **`which [name]`**: High-power introspection tool identifying aliases, functions, and their source file locations.
* **`lcd [dir]`**: Enters a directory and immediately lists contents (`ls -latrh`).
* **`lsc`**: Lists files with a total count of directories and regular files.

---

## 4. Key Bindings & Shortcuts

### Vim Function Keys
| Key | Action |
| :--- | :--- |
| **F7** | Toggle Line Numbers |
| **F8** | Toggle Tagbar / Structure |
| **F9** | Quick Save Buffer |
| **F10** | Toggle Paste Mode |

### Vim Leader Shortcuts (Leader = `;`)
| Shortcut | Action |
| :--- | :--- |
| `;w` | Save File |
| `;q` | Quit Editor |
| `;/` | Clear Search Highlights |
| `;v` | Edit .vimrc in vertical split |

---

## 5. Change Log
| Version | Date | Highlights |
| :--- | :--- | :--- |
| **1.3** | 2026-03-26 | **Vim Integration**: Custom status bar (`[INSERT]`, `[+]`), F-key mappings, and `;` Leader configuration. |
| **1.2** | 2026-03-26 | Added Discovery suite: `which`, `lcd`, `lsc`, and `topfiles`. |
| **1.1** | 2026-03-26 | Integrated `cpy`, `dfc`, and `du_better` modules. |
| **1.0** | 2026-03-26 | Initial baseline with `.bashrc_cust` and `.bashrc_alias`. |
