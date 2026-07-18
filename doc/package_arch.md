# Package design
---
Maxima package shall follow this rules to be recognized with maxpack.

**note* root directory / means the package root directory

## manifest :mandatory:
- Location: /manifest.toml
- Type: file
- File name: manifest.toml
- Description: This file contains meta information.
- Parameters:
    * Optional:
        - url: web page
        - dependencies: [] array of dependencies, each one has to be 
            a package url followed with the version with @ between.
            https://github.com/achengli/maxpack@1.0.3
            also the format achengli/maxpack@1.0.3 must be compatible because
            by default, maxpack will search in github

            in the future maxpack@1.0.3 will be supported having a central cdn 
            to provide package information for maxpack.
        - license: gpl, bsd...
        - copyright: BY, BY-NC...
    * Mandatory:
        - author: e.g. (achengli@github.com)
        - version: e.g. 1.0.1 (github tag)
        - repository: e.g. https://github.com/achengli/maxpack.git or achengli/maxpack.git or 
                    achengli/maxpack
        - name: maxpack
        - description: Maxpack is a maxima package manager
        - minver: minimum maxima version

## src :mandatory:
- Location: /src
- Type: directory
- Description: this directory contains the code of the package.

### src/init.mac :mandatory:
- Location: /src/init.mac
- Type: file
- Description: This file must have all the imports and exports, the exports must be a 
            dict containing pair name function with all exported functions and constants.

### src/install.{sh,ps1} :optional:
- Location: /src/install.{sh,ps1}
- Type: file
- Description: Install script, the script contains automated tasks to install the package
                and must be asked before being executed.

## test :mandatory:
- Location: /test
- Type: directory
- Description: This directory contains the tests for the package. 

## LICENSE :optional:
- Location: /LICENSE
- Type: file
- Description: Detailed license

## NOTICE :optional:
- Location: /NOTICE
- Type: file
- Description: Release information.

