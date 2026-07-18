![maxpack](maxpack.png)

---

# maxpack — Maxima package manager

maxpack is a package manager for [Maxima](https://maxima.sourceforge.io/), inspired by
[vim-plug](https://github.com/junegunn/vim-plug). It provides a minimalist CLI and a
Maxima runtime API to install, update, and manage Maxima packages.

## Installation

### Requirements

- [SBCL](https://www.sbcl.org/) (Steel Bank Common Lisp)
- [git](https://git-scm.com/)
- [Maxima](https://maxima.sourceforge.io/) (optional, for in-Maxima usage)

### Linux, BSD and macOS

```sh
git clone https://github.com/achengli/maxpack.git && cd maxpack
chmod +x install.sh
./install.sh
```

The installer will:
1. Copy maxpack to `~/.maxpack/repo/`
2. Create the `maxpack` CLI wrapper in `~/.maxpack/bin/`
3. Create `~/.maxpack/package.list` (your package declarations)
4. Append the load line to `~/.maxima/maxima-init.mac`

After installation, add this to your shell config (`~/.bashrc`, `~/.zshrc`, …):

```sh
export PATH="$HOME/.maxpack/bin:$PATH"
```

### Windows 10 & 11

```powershell
git clone https://github.com/achengli/maxpack.git && cd maxpack
.\install.ps1
```

## Usage

### CLI

```
maxpack <command> [arguments]
```

| Command | Description |
|---|---|
| `install [pkg]` | Install packages from `package.list` or a single package |
| `remove <pkg> [ver]` | Remove a package or a specific version |
| `list` | List all installed packages |
| `update [pkg]` | Update `latest` versions (`git pull`) |
| `import <pkg> [ver]` | Import a package and resolve dependencies |
| `exists <pkg> [ver]` | Check if a package is installed |
| `info <pkg> [ver]` | Show package metadata from `manifest.toml` |
| `search [query]` | Search packages (coming soon) |
| `version` | Show maxpack version |
| `help` | Show help |

Examples:

```sh
maxpack install                          # install all from ~/.maxpack/package.list
maxpack install achengli/maxpack          # install latest
maxpack install achengli/maxpack@v1.0     # install specific tag
maxpack list                              # list installed packages
maxpack update                            # update all latest versions
maxpack remove mypackage                  # remove all versions
maxpack remove mypackage v1.0             # remove specific version
maxpack info mypackage                    # show package metadata
maxpack exists mypackage v1.0            # check if v1.0 is installed
```

### Package list format (`~/.maxpack/package.list`)

```
# Comments start with #
achengli/maxpack                          # GitHub shorthand
achengli/some-package@v1.0                # with specific tag
https://gitlab.com/user/repo.git          # full git URL
```

### Maxima integration

Once installed, maxpack is available inside Maxima via the `maxpack#` prefix:

```maxima
maxpackMImport("mypackage")$
maxpackMInstall("user/repo")$
maxpackMList()$
maxpackMUpdate()$
maxpackMUninstall("mypackage")$
```

All CLI commands have a corresponding Maxima function:

| CLI | Maxima |
|---|---|
| `maxpack install` | `maxpackMInstall(pkg)` |
| `maxpack remove` | `maxpackMUninstall(pkg, ver)` |
| `maxpack list` | `maxpackMList()` |
| `maxpack update` | `maxpackMUpdate(pkg)` |
| `maxpack import` | `maxpackMImport(pkg, ver)` |
| `maxpack exists` | `maxpackMExists(pkg, ver)` |
| `maxpack info` | `maxpackMInfo(pkg, ver)` |

## Package directory layout

```
~/.maxpack/
├── bin/
│   └── maxpack              # CLI wrapper
├── repo/                    # maxpack source
├── package.list             # your package declarations
├── maxpack-registry.lisp    # generated ASDF registry
├── some-package/
│   ├── latest/              # default installation
│   └── v1.0/                # specific version
└── other-package/
    └── latest/
```

- `mInstall foo/bar` → clones to `~/.maxpack/bar/latest/`
- `mInstall foo/bar@v1.0` → clones to `~/.maxpack/bar/v1.0/`
- `mUpdate` → `git pull` in all `*/latest/` directories

## Creating a maxpack package

A maxpack-compatible package follows this structure:

```
my-package/
├── manifest.toml            # mandatory: package metadata
├── src/
│   ├── init.mac             # mandatory: exports
│   └── install.sh           # optional: install script
├── test/                    # mandatory: tests
├── LICENSE                  # optional
└── NOTICE                   # optional
```

### `manifest.toml`

```toml
name = "my-package"
version = "1.0.0"
author = "user@github.com"
description = "A useful Maxima package"
license = "BSD-3"
repository = "https://github.com/user/my-package.git"
minver = "5.45.0"
dependencies = ["other/pkg@v1.0"]
```

### `src/init.mac`

Exports the package's public API as a dictionary:

```maxima
mypackage#exports: [
    [myFunction,  ?mfuncall('myFunction, args)],
    [myConstant,  42]
]$

mypackage#version:  "1.0.0"$
mypackage#author:   "user@github.com"$
```

## Uninstallation

Remove the maxpack directory and the PATH entry from your shell config:

```sh
rm -rf ~/.maxpack
# Then remove 'export PATH="$HOME/.maxpack/bin:$PATH"' from ~/.bashrc / ~/.zshrc
```

To uninstall a specific package:

```sh
maxpack remove package-name
```

## License

BSD-3 © Yassin Achengli Benmouais
