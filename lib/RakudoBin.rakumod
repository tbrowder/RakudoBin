unit module RakudoBin;

use RakudoBin::Subs;
use RakudoBin::OS;

constant $RDIR = "/opt/rakudo";
sub run-cli-inst-raku(@args) is export {

    # default directory, may be changed by the user
    # with option dir=/path
    # TODO not fully tested yet
    my $rdir = $RDIR; #"/opt/rakudo";

    # get the latest release date
    my $reldate = get-latest-release;
    my $relnum  = get-release-number $reldate.Date;

    my $os = RakudoBin::OS.new;
    my $is-debian = $os.is-debian;

    my $user    = $*USER.lc;
    my $is-root = $user eq 'root' ?? True !! False;
    my $host    = $*KERNEL.hostname;
    my $system  = $*KERNEL.hardware // "Unknown system";
    my $distro  = $*DISTRO.name;
    my $version = $*DISTRO.version;

    my $rakubin = "/opt/rakudo/bin/raku".IO.e;
    my $verb1   = $rakubin ?? "upgrades" !! "installs";

    my $rakusys = "/usr/bin/raku".IO.e;
    my $verb2   = $rakusys ?? "the" !! "an";

    if not @args.elems {
        say qq:to/HERE/;
        Usage: {$*PROGRAM.basename} go | <other modes, options> | help

        Mode 'go' $verb1 the Rakudo binary system (release 
        $relnum) using $verb2 installed Rakudo system package.

        Use mode 'help' to see other modes and options.

        This is a root-only program:

            User:    $user
            Distro:  $distro
            Version: $version
            System:  $system

        HERE

        unless $is-debian {
            print qq:to/HERE/;
            Note even though this is not a Debian system,
            you can use this module to aid in downloading
            Rakudo binary files for your system.
            HERE
        }

        exit if $rakusys;

        say "To install the Rakudo system package:\n";
        say "    sudo apt-get install rakudo";

        exit;
    }

    =begin comment
    # use this area to test subs without being root
    =begin comment
    say "Downloading...";
    download-rakudo-bin :date<2023-09>, :os<lin>, :debug;

    say "DEBUG exit"; exit;
    =end comment

    # we must be using the Debian rakudo package
    my $rak = "/usr/bin/raku";
    unless $rak.IO.f {
        print qq:to/HERE/;
        FATAL: This program requires the Debian 'rakudo' package to be installed.
               As root, run 'sudo apt-get install rakudo' to do so.
        HERE
        exit;
    }

    if @*ARGS.head ~~ /^ :i h / {
        run-help;
        exit;
    }

    unless $is-root {
        say "FATAL: This program must be executed by the root user.";
        exit;
    }

    my $debug  = 0;

    # date=yyyy-mm
    # os=
    # arch=
    # tool=
    # type=
    # dir=/path
    my $arch;
    my $tool;
    my $type;
    for @*ARGS {
        when /^:i de / { ++$debug }
        when /^:i g / {
            ; # ok
        }
        when /^:i da[te]?'=' (\d**4 '-' \d\d) $/ {
            $reldate = ~$0;
        }
        when /^:i os?'=' (\S+) $/ {
            $os = ~$0;
        }
        when /^:i ar[ch]?'=' (\S+) $/ {
            $arch = ~$0;
        }
        when /^:i to[ol]?'=' (\S+) $/ {
            $tool = ~$0;
        }
        when /^:i ty[pe]?'=' (\S+) $/ {
            $type = ~$0;
        }
        when /^:i dir'=' (\S+) $/ {
            $rdir = ~$0;
        }

        default {
            note "FATAL: Unknown arg '$_'";
            exit;
        }
    }

    # need a reldate

    say "Installing Rakudo binary download in $rdir...";
    if $rdir.IO.d {
        say "Updating an existing '$rdir'...";
        =begin comment
        say "It must be removed along with any";
        say "publicly accessible modules.";
        my $res = prompt "Continue (y/N)? ";
        handle-prompt :$res;
        say "Removing Installing rakudo-pkg in '$rdir'...";
        shell "rm -rf $rdir";
        =end comment
    }

    my $res = prompt "Continue (y/N)? ";

    #=end comment
    #return;
    #=finish

    handle-prompt :$res;

    #install-raku;

    download-rakudo-bin :$reldate, :$os, 
        #:$spec,
        :$release, :$debug;

=begin comment
sub download-rakudo-bin(
    :reldate($date)! where {/^ \d**4 '-' \d\d $/},
    :OS(:$os)!,
    :$rdir!,
    :$arch, :$tool, :$type,
    #:$spec,
    :$release is copy where { /^ \d+ $/ } = 1,
    #:$force = False,
    :$debug,
    ) is export {
=end comment


} # sub run-cli-inst-raku(@args) is export {
