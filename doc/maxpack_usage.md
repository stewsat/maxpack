# Maxpack usage
---

## Software interface
Maxpack has to be a maxima extension, maxpack itself must be a maxpack package so it has to follow
the package definitioin in ![package_arch.md] file in this directory.

Maxpack will include functions inside maxima runtime as a api and also to be used in:
- mImport(package, version): Includes a package from maxpack
- mImport(package): Includes latest package version
- mExists(package, version): Check if the package@version is installed
- mExists(package): Check if the package is installed
- mInstall(package, version): Install the package@version 
- mInstall(package): Install the package.
- mList(): List installed packages.
- mUninstall(package, version): Remove package@version
- mUninstall(package): Uninstall package and all versions
- mRemove is an alias for mUninstall


When a maxpack package is installed, as defined in ![package_arch.md], the package will export all
the functions and constants in a variable, the variable shall be named as the package name, I guess
maxima hasn't dictionaries, if it is right, use # to separate the dict and the key, for example:

```maxima
maxpack#mImport := (package, version) block([...
])$
maxpack#version : "1.0.3"$
```
so after including a package, you will have access to all those functions and constants

## CLI interface
Maxpack can be used in a CLI using maxpack application, maxpack must have all the previous 
definitions in CLI mode. Must have help function and also update functions to update latest 
versioned packages, including maxpack itself because is a package.


