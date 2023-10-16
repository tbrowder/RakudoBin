[![Actions Status](https://github.com/tbrowder/RakudoBin/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/RakudoBin/actions) [![Actions Status](https://github.com/tbrowder/RakudoBin/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/RakudoBin/actions) [![Actions Status](https://github.com/tbrowder/RakudoBin/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/RakudoBin/actions)

NAME
====

**RakudoBin** - Provides Raku and system scripting bash tools to install and remove the Rakudo binary version

SYNOPSIS
========

```raku
use RakudoBin;

install-rakudo-bin :date<2022-09>, :os<linux>;
install-rakudo-bin :date<2022-09>, :os<windows>, :spec<msi>; # or :spec<zip>
install-rakudo-bin :date<2022-09>, :os<macos>, :spec<arm>;   # or :spec<x86>
```

DESCRIPTION
===========

This module distribution can be used in several different scenarios for installing or upgrading a host to use the Rakudo binary download archive containing `rakudo` and <zef> executables.

Scenario one - a new system without Rakudo installed
----------------------------------------------------

Scenario two - a new system with its system Rakudo package installed
--------------------------------------------------------------------

Scenario three - upgrading a system already using the Rakudo binary download
----------------------------------------------------------------------------

**WARNING** Note the Rakudo binary download provides its own zef which is normally used by both the root user as well as normal users. If the `.raku` or `.zef` directories are found in the root user's own `$HOME` directory, he or she will be offered the choice of either deleting them or aborting the installation. 

This module is not designed to be installed by `zef` before its use on a new system. Its repository must be downloaded onto the desired host and then used by the root user from the module's top-level directory following the instructions below.

The package contains programs for the root user to bootstrap the `rakudo` binary download installation by use of a system `rakudo` package installation. After successful bootstrapping, the system's `rakudo` package should be deleted to avoid conflicts.

**RakudoBin** currently will install a binary version of Rakudo for Linux hosts. For example, the name of a recent Rakudo binary release has the following archive names for the three OSs listed at [https://rakudo.org/downloads](https://rakudo.org/downloads):

    rakudo-moar-2023.09-01-linux-x86_64-gcc.tar.gz
    rakudo-moar-2023.09-01-macos-arm64-clang.tar.gz
    rakudo-moar-2023.09-01-macos-x86_64-clang.tar.gz
    rakudo-moar-2023.09-01-win-x86_64-msvc.msi
    rakudo-moar-2023.09-01-win-x86_64-msvc.zip

Generally, the only thing you need to choose is the date and the OS and enter it into the binary `install-rakudo-bin :$date, :$os` and it will be downloaded along with the accompanying files for checking the validity of the archive.

The `:spec` argument has a default of `msi` for Windows and `arm` for MacOS. The release will be `01` unless you enter another valid number with `:release`.

The archive and its sister files will be downloaded into a temporary directory, checked for valididty, and unpacked into directory `/opt/rakudo-YYYY-MM-RR`. 

This module may eventually be able to do the same for MacOS and, hopefully, Windows.

Note this package is designed for the purpose of setting up and standardizing multi-user Linux hosts for classrooms or computer laboratories.

Procedures
----------

Normally you will be using this module on a system which has not had Raku installed other than with its normal package installation, but it will uninstall completely any previous `rakudo-pkg` installation in an existing `/opt/rakudo-pkg` directory.

There are three steps to follow.

### Step 1 - Install the Debian or Ubuntu `rakudo` package and its `zef`

Since `zef` depends on `raku`, all we need to do is install its package (note the package name is different):

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2023 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

