#!/usr/bin/env raku

use Proc::Easier;
use File::Temp;

my @ifils = <
inst-modules.dedi10
inst-modules.dedi8
inst-modules.juvat3
>;

my $go      = 0;
my $debug   = 0;
my $install = 0;

my $is-root = $*USER eq 'root' ?? True !! False;
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | install [debug]

    Reads files containing Raku modules formerly installed
      on my hosts:

    HERE
    say "  $_" for @ifils;

    print qq:to/HERE/;

    and consolidates them into one list, without adverbs, for
    reinstalling by myself as a normal user with the 'install'
    mode.
    HERE

    if $is-root {
        say "ERROR: The root user should not install modules until some issues are resolved.";
        say "       Exiting...";
        exit;
    }
    exit;
}

for @*ARGS {
    when /^:i d/ { ++$debug   }
    when /^:i g/ { ++$go      }
    when /^:i i/ { ++$install }
}

my %m; # hash for unique modules

sub read-lists(@ifils, %m) {
    for @ifils -> $f {
        for $f.IO.lines -> $line is copy {
            next if $line !~~ /\S/;
            next if $line.contains:  '==>';

            my $in = $line;
            #say "in: $line";

            # eliminate adverbs
            my $idx;
            $idx = $line.index: ':ver<';
            if $idx.defined {
                $line = $line.substr: 0, $idx;
            }

            $idx = $line.index: ':auth<';
            if $idx.defined {
                $line = $line.substr: 0, $idx;
            }

            $idx = $line.index: ':api<';
            if $idx.defined {
                $line = $line.substr: 0, $idx;
            }
    
            if %m{$line}:exists {
                %m{$line}.push: $in;
            }
            else {
                %m{$line} = [];
            }
        }
    }
}

my $n = %m.elems;
say "Found $n unique modules for possible input.";
for %m.keys.sort -> $k {
    say $k;
    if $debug {
        for @(%m{$k}) -> $in {
            note "    $in"
        }
    }
}
say "Found $n unique modules for possible input.";

# determine ones already installed

sub get-installed(%m) {
    # 
    my $tdir = tempdir;
    my $tfil = "$tdit/t";
    my $exe  = "zef list --installed > '$tfil'";
    cmd $exe;
    get the list
}

if $install {
    my $res = prompt "Install now (y/N): ";
    if $res ~~ /:i n/ {
        say "Exiting without installing.";
        exit;
    }
    elsif $res ~~ /:i y/ {
        say "Installing...";
    }
    else {
        say "ERROR: Unexpected respons: '$res'";
        say "Exiting without installing.";
        exit;
    }
}

# TODO report time to complete...
my $start = time;
for %m.keys -> $m {
    next if $m ~~ /:i inline /;
    say "Installing $m...";
    my $exe = "zef install --serial $m";
    my $res = cmd $exe;
}
my $end = time;
my $esec = $end - $start;
my $emin = $esec / 60.0;
say "Finished in $emin minutes (installed {%m.elems}\n   modules plus unlisted dependencies";



=finish

===> Found via /opt/rakudo-pkg/share/perl6/site
App::Prove6:ver<0.0.12>:auth<cpan:LEONT>
Base64:ver<0.0.2>:auth<github:ugexe>:api<0>
