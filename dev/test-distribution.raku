#!/usr/bin/env raku

# note: this is under git version control in https://github.com/tbrowder/SysAdmin/dev

use lib "lib";
use MyFoo;

say "== Current docs:";
say();
module-source;
say();

say "== New Example (first line):";
say();
module-source1;

=finish
module-source2;
module-source3;


