# Maxpack
---
![maxpack icon](maxpack.png)

Maxima has a lot of useful libraries and scripts were done but are 
decentralized and not formalized into packages or utilities.

This projects aims to be that package manager with a minimalistic and 
universal availability philosophy. It's inspired in Plug vim's package
manager.

## Installation
---
Instalation is done using install.sh script for Linux,BSD and OSX 
systems, and install.ps for Windows systems.

+ For Linux, BSD and OSX systems perform:
```sh
git clone https://github.com/achengli/maxpack.git && cd maxpack
chmod +x install.sh
./install.sh
```

+ For Microsoft windows systems:
```powershell
git clone https://github.com/achengli/maxpack.git && cd maxpack
.\install.ps
```

## Usage
---
To use the package manager, go to `$HOME/.maxpack/packages.list` and 
write in a separate line the owner of the package and the package itself
separated by a slash, for example *achengli/maxpack* only in the case
the package is located in github, in other case you must type the full
path to clone the package.

If you want to install specific version of the package and it's available
as a tag, then you must insert an **@** symbol between the package 
name/location and the version, for example *achengli/maxpack@1.0.1*.

To install packages, open maxima and type `maxpack#install();` then it 
will install all packages inside packages.list file.

If you want to delete some package, you can uninstall it deleting the 
package line from package.list and performing `maxpack#install();` again
in maxima, or also you can use the function 
`maxpack#delete("name of your package");`.

To update package that are in latest version, then run `maxpack#update()`.

