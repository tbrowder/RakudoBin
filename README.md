[![Actions Status](https://github.com/tbrowder/RakudoBin/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/RakudoBin/actions) [![Actions Status](https://github.com/tbrowder/RakudoBin/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/RakudoBin/actions) [![Actions Status](https://github.com/tbrowder/RakudoBin/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/RakudoBin/actions)

NAME
====

**RakudoBin** - Provides Raku tools to install and upgrade the Rakudo binary version

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

In fact, it is designed to maintain and use the native Rakudo package to bootstrap the binary downloads. Consider the following scenarios:

Scenario one - a new system without Rakudo installed
----------------------------------------------------

Solution: 

  * install the system Raku and Zef

  * install module RakudoBin using the system Zef

  * install the Rakudo binary with the executable program of module RakudoBin

Scenario two - a new system with its system Rakudo package installed
--------------------------------------------------------------------

Solution: 

  * install module RakudoBin using the system Zef

  * install the Rakudo binary with the executable program of module RakudoBin

Scenario three - upgrading a system already using the Rakudo binary download
----------------------------------------------------------------------------

Solution: 

  * upgrade the Rakudo binary with the executable program of module RakudoBin

Scenario four - a system with another Raku installation method
--------------------------------------------------------------

Solution: 

**WARNING** Note the Rakudo binary download provides its own `zef` which is normally used by both the root user as well as normal users. If the `zef` executable is found in the root user's own `$HOME` directory, he or she will be offered the choice of either deleting it or aborting the installation. Given the oft-upgraded binary version, retaining the personal copy of `zef` should not be of any benefit. As well, its effect on the dual-Rakudo installation is not tested.

**RakudoBin** currently will install a binary version of Rakudo for Linux hosts. Older versions are available, but the name of a recent Rakudo binary release has the following archive names for the three OSs listed at [https://rakudo.org/downloads](https://rakudo.org/downloads):

    rakudo-moar-2023.10-01-linux-x86_64-gcc.tar.gz
    rakudo-moar-2023.10-01-macos-arm64-clang.tar.gz
    rakudo-moar-2023.10-01-macos-x86_64-clang.tar.gz
    rakudo-moar-2023.10-01-win-x86_64-msvc.msi
    rakudo-moar-2023.10-01-win-x86_64-msvc.zip

Generally, the only thing you need to choose is the date and the OS and enter it into the binary `install-rakudo-bin :$date, :$os` and it will be downloaded along with the accompanying files for checking the validity of the archive.

The `:spec` argument has a default of `msi` for Windows and `arm` for MacOS. The release will be `01` unless you enter another valid number with `:release`.

The archive and its sister files will be downloaded into a temporary directory, checked for valididty, and unpacked into directory `/opt/rakudo`. 

This module may eventually be able to do the same for MacOS and, hopefully, Windows. But at this release, it has only been tested on Debian systems (11 and 12).

Note this package is designed for the purpose of setting up and standardizing multi-user Linux hosts for classrooms or computer laboratories.

Procedures
----------

Normally you will be using this module on a system which has not had Raku installed other than with its normal package installation, but it will uninstall completely any previous `rakudo-pkg` installation in an existing `/opt/rakudo-pkg` directory.

There are three steps to follow.

### Step 1 - Install the Debian `rakudo` package and its `zef`

Since `zef` depends on `raku`, all we need to do is install its package (note the package name is different for different Debian versions):

  * Debian 11

    Install `raku` and `zef`:

        $ sudo aptitude install perl6-zef

    The result is Raku v2020.12 and zef v0.9.4.

  * Debian 12

    Install `raku` and `zef`:

        $ sudo aptitude install raku raku-zef

    The result is Raku v2022.12 and zef v0.13.8. Note that version is probably sufficient for beginning Raku users, but this module aims to make upgrading painless.

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2023 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

