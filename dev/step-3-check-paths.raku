#!/usr/bin/env raku

constant $raku-path     = "/opt/rakudo-pkg/bin";
constant $site-bin-path = "/opt/rakudo-pkg/share/perl6/site/bin";

if not @*ARGS {
    say qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Checks for the correct paths for using the Raku
    executable and site module executable installed
    by Zef.

    The correct raku path is:
        {$raku-path}
    and the correct site module bin path is:
        {$site-bin-path}
    HERE
    exit;
}

