[![Actions Status](https://github.com/tbrowder/RakudoBin/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/RakudoBin/actions) [![Actions Status](https://github.com/tbrowder/RakudoBin/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/RakudoBin/actions) [![Actions Status](https://github.com/tbrowder/RakudoBin/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/RakudoBin/actions)

NAME
====

**RakudoBin** - Provides Raku tools to install or upgrade the Rakudo binary version

SYNOPSIS
========

```raku
use RakudoBin;
rb-install-raku go
```

System dependency
=================

This module requires system executable `curl` to be available. Install it on a Debian system with:

    sudo apt-get install curl

DESCRIPTION
===========

Downloads the latest Rakudo binary archive for the host system's operating system, architecture, compiler, and type of archive. Checks the archive for the proper SHA256 hash value.

Execute the installed binary, `rb-install-raku`, without arguments, to see those download defaults for your host system. They are also shown below.

<table class="pod-table">
<caption>Installation keys and default values</caption>
<thead><tr>
<th>os</th> <th>arch</th> <th>tool</th> <th>type</th> <th>Alternate</th>
</tr></thead>
<tbody>
<tr> <td>linux</td> <td>x86</td> <td>gcc</td> <td>tgz</td> <td></td> </tr> <tr> <td>windows</td> <td>x86</td> <td>msvc</td> <td>msi</td> <td>type=zip</td> </tr> <tr> <td>macos</td> <td>arm</td> <td>clang</td> <td>tgz</td> <td>arch=x86</td> </tr>
</tbody>
</table>

Follwing are examples of specifying the desired values:

```raku
rb-install-raku date=2022-09 os=linux
rb-install-raku date=2022-09 os=windows type=msi  # or type=zip
rb-install-raku date=2022-09 os=macos arch=arm    # or arch=x86
```

Unpacks the archive into directory `/opt/rakudo`. The paths required to use the installed binaries are `/opt/rakudo/bin` and `/opt/rakudo/share/perl6/site/bin`. The download location may be specified with the `dir=/path` option (which may be useful for non-Linux systems).

  * Note for non-Debian systems

    Currently, only Debian systems are further modified in the following steps. Interested users of other systems are encouraged to create a PR for their system.

For Debian systems only, ensures paths are set correctly and the system's `adduser` configuration (in directory `/etc/skel`) has the correct settings for Raku.

Details
=======

This module distribution can be used in several different scenarios for installing or upgrading a host to use the Rakudo binary download archive containing the `raku` and `zef` executables.

In fact, it is designed to maintain and use the native Rakudo system package to bootstrap the binary downloads. Consider the following scenarios:

Scenario one - a new system without Rakudo installed
----------------------------------------------------

Solution:

  * install the system `raku` and `zef`

  * install module RakudoBin using the system `zef`

  * install the Rakudo binary with the executable program of module RakudoBin

  * remove the Rakudo system `zef`

Scenario two - a new system with its system Rakudo package installed
--------------------------------------------------------------------

Solution:

  * install module RakudoBin using the system `zef`

  * install the Rakudo binary with the executable program of module RakudoBin

  * remove the Rakudo system `zef`

Scenario three - upgrading a system already using the Rakudo binary download
----------------------------------------------------------------------------

Solution:

  * upgrade the Rakudo binary with the executable program of module RakudoBin

Scenario four - a system with another Raku installation method
--------------------------------------------------------------

Solution:

**WARNING** Note the Rakudo binary download provides its own `zef` which is normally used by both the root user as well as normal users. If the `zef` executable is found in the root user's own `$HOME` directory, he or she will be offered the choice of either deleting it or aborting the installation. Given the oft-upgraded binary version, retaining the personal copy of `zef` should not be of any benefit. As well, its effect on the dual-Rakudo installation is not tested.

Overview
========

**RakudoBin** currently will install a binary version of Rakudo for Linux hosts. Older versions are available, but the name of a recent Rakudo binary release has the following archive names for the three OSs listed at [https://rakudo.org/downloads](https://rakudo.org/downloads):

    rakudo-moar-2023.10-01-linux-x86_64-gcc.tar.gz
    rakudo-moar-2023.10-01-macos-arm64-clang.tar.gz
    rakudo-moar-2023.10-01-macos-x86_64-clang.tar.gz
    rakudo-moar-2023.10-01-win-x86_64-msvc.msi
    rakudo-moar-2023.10-01-win-x86_64-msvc.zip

Generally, the only thing you need to do is accept the defaults unless you want an older release for some reason. The correct version for your system will be downloaded along with the accompanying files for checking the validity of the archive.

The archive and its sister files will be downloaded into a temporary directory, checked for validity, and unpacked into directory `/opt/rakudo`.

This module may eventually be able to do the same for MacOS and, hopefully, Windows. But at this release, it has only been tested on Debian systems (11 and 12).

Note this package is designed for the purpose of setting up and standardizing multi-user Linux hosts for classrooms or computer laboratories.

Procedures
==========

Normally you will be using this module on a system which has not had Raku installed other than with its normal package installation, but it will uninstall completely any previous `rakudo-pkg` installation in an existing `/opt/rakudo-pkg` directory.

There are three steps to follow.

### Step 1 - Ensure the system `rakudo` package and its `zef` are installed

Since `zef` depends on `raku`, all we need to do is install its package (note the package name is different for different Debian versions):

  * Debian 11

    Install `raku` and `zef`:

        $ sudo aptitude install rakudo perl6-zef

    The result is Raku v2020.12 and zef v0.9.4.

  * Debian 12

    Install `raku` and `zef`:

        $ sudo aptitude install rakudo raku-zef

    The result is Raku v2022.12 and zef v0.13.8. Note that version is probably sufficient for beginning Raku users, but this module aims to make upgrading to a more recent version painless.

### Step 2 - Install this module

    $ sudo zef install RakudoBin

### Step 3 - Remove the system zef

    $ sudo apt-get purge raku-zef # Debian 11

OR

    $ sudo apt-get purge perl6-zef # Debian 12

### Step 4 - Install or upgrade the Rakudo binary system

    $ sudo rb-install-raku go

Note after the first installation, the system package of `zef` should be removed to avoid possible interference between the two versions.

    $ sudo apt-get purge raku-zef # Debian 11

OR

    $ sudo apt-get purge perl6-zef # Debian 12

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2023 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

