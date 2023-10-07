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

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2023 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

