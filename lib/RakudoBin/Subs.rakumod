unit module RakudoBin::Sub;

our %pub-keys is export = set %(
    'alexander_kiryuhin-FE750D152426F3E50953176ADE8F8F5E97A8FCDE.asc',
    'justin_devuyst-59E634736AFDCF9C6DBAC382602D51EACA887C01.asc',
    'patrick_boeker-DB2BA39D1ED967B584D65D71C09FF113BB6410D0.asc',
    'rakudo_github_automation-3E7E3C6EAF916676AC549285A2919382E961E2EE.asc',
);

# remove spaces between four-character sets
# to make sets of 40-character fingerprints
our %key-fingerprints is export = %(
    '59E634736AFDCF9C6DBAC382602D51EACA887C01' => 'Justin DeVuyst',
    'DB2BA39D1ED967B584D65D71C09FF113BB6410D0' => 'Patrick Böker',
    'FE750D152426F3E50953176ADE8F8F5E97A8FCDE' => 'Alexander Kiryuhin',
    '3E7E3C6EAF916676AC549285A2919382E961E2EE' => 'Rakudo GitHub automation',
);

# need the public key files
=begin comment
=end comment

# Debian releases
our %debian-vnames is export = %(
    etch     =>  4,
    lenny    =>  5,
    squeeze  =>  6,
    wheezy   =>  7,
    jessie   =>  8,
    stretch  =>  9,
    buster   => 10,
    bullsye  => 11,
    bookworm => 12,
    trixie   => 13,
    forky    => 14,
);
our %debian-vnum is export = %debian-vnames.invert;

# Ubuntu releases
our %ubuntu-vnames is export = %(
   trusty => 14,
   xenial => 16,
   bionic => 18,
   focal  => 20,
   jammy  => 22,
   lunar  => 23,
);
our %ubuntu-vnum is export = %ubuntu-vnames.invert;


=begin comment
# sytems confirmed
# name ; version
ubuntu;  22.04.3.LTS.Jammy.Jellyfish
ubuntu;  20.04.6.LTS.Focal.Fossa
macos;   12.6.7
macos;   13.5
macos;   11.7.8
mswin32; 10.0.17763.52
=end comment

=begin comment
from docs: var $*DISTRO
from docs: role Version does Systemic
basically, two methods usable:
  .name
  .version
    .Str
    .parts (a list of dot.separated items: integers, then strings)
=end comment

sub get-dir-paths($dir = '.' --> Hash) is export {
    # Given any directory, recursively collect all files
    # and directories below it.
    my @todo = $dir.IO;
    my @fils;
    my @dirs;
    while @todo {
        for @todo.pop.dir -> $path {
            if $path.d {
                @todo.push: $path;
                @dirs.push: $path;
            }
            else {
                @fils.push: $path;
            }
        }
    }
    my %h = files => @fils, dirs => @dirs;
    %h
} # sub get-dir-paths($dir = '.' --> Hash) is export {

sub my-resources is export {
    %?RESOURCES
}

sub handle-prompt(:$res) is export {
    # $res is the return from a prompt asking
    # for a 'yes' response to take action or quit.
    if $res ~~ /^:i y/ {
        say "Proceeding...";
    }
    else {
        say "Exiting...";
        exit;
    }
}

sub remove-raku($dir) is export {
    my $pkg = "rakudo-pkg";
    if $dir.IO.d {
        my $res = prompt "You really want to remove directory '$dir' (y/N)? ";
        if $res ~~ /^:i y/ {
            say "Proceeding...";
        }
        else {
            say "Exiting...";
            exit;
        }

        # first remove any symlinks to avoid dangling links
        # DO NOT USE manage-symlinks :delete;

        shell "rm -rf $dir" if $dir.IO.d;
        say "Directory '$dir' has been removed.";

        # rm any rakudo-pkg.sh in /etc/profile.d
        my $rfil = "/etc/profile.d/rakudo-pkg.sh";
        if $rfil.IO.f {
            shell "rm -f $rfil";
            say "File '$rfil' has been removed."
        }
    }
    else {
        say "Directory '$dir' does not exist!";
    }
} #sub remove-raku($dir) is export {

sub set-skel-scripts(:$user, :$restore, :$debug) is export {
    # add a .xsessionrc file as a copy of the 
    # .profile file

} # sub set-skel-scripts(:$user, :$restore, :$debug) is export {

sub handle-path-file($f, :$user, :$restore, :$debug) is export {
    # For each file:
    #   does it exist yet?
    #   is it original? (it would have a '$f.orig' version in the same directory)
    #   has it been modified? (it would have a line with RAKUDO on it)
    #   shall we restore it to its original form (possibly empty or non-existent)
    my $exists  = $f.IO.f ?? True !! False;
    if not $exists {
        say "  Creating non-existent file: $f";
        spurt $f, "";
        $exists = True;
    }

    my $is-orig = "$f.orig".IO.f ?? False !! True;
    my @lines = $f.IO.lines;
    if $debug {
        say "  Inspecting file '$f'";
        =begin comment
        say "    Contents:";
        say "      $_" for @lines;
        say "    End contents for file '$f'";
        =end comment
        my $tag = "RAKUDO_PATHS";
        for @lines.kv -> $i, $line {
            if $line ~~ /$tag/ {
                say "    Found $tag on line {$i+1}";
            }
        }
        say "    Is it original? $is-orig";
        say "    Number of lines: {@lines.elems}";
    }
    if $is-orig {
        # make a copy
         copy $f, "$f.orig";
    }

    # check for and add missing lines to certain files:
    #   .bash_profile
    #   .xsessionrc
    return unless $f ~~ /\. bash_profile|xsessionrc /;

    my $a = q:to/HERE/;
    if [ -f ~/.profile ]; then
        . ~/.profile
    fi
    HERE

    my $b = q:to/HERE/;
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
    HERE

    my $mlines = 0; # checking for three matching lines
    for @lines {
    }
} # sub handle-path-file($f, :$user, :$restore, :$debug) is export {

sub get-backup-name($f, :$use-date --> Str) is export {
    # Given a file name, return a backup name consisting
    # of the original name with either '.orig' appended
    # or the current time in format '.YYYY-MM-DDThh:mm:ssZ'.
    my $nam;
    if $use-date {
        my $dt = DateTime.now: :timezone(0);
        my $y = sprintf "%02d", $dt.year;
        my $M = sprintf "%02d", $dt.month;
        my $d = sprintf "%02d", $dt.day;
        my $h = sprintf "%02d", $dt.hour;
        my $m = sprintf "%02d", $dt.minute;
        my $s = sprintf "%02d", $dt.second;
        $nam = "{$f}.{$y}-{$M}-{$d}T{$h}{$m}.{$s}Z";
     }
     else {
        $nam = "{$f}.orig";
     }
     $nam
} # sub get-backup-name($f, :$use-date --> Str) is export {

multi sub download-rakudo-bin(
) {
}

multi sub download-rakudo-bin(
    :reldate($date)! where {/^ \d**4 '-' \d\d $/},
    :OS(:$os)!,
    :$rdir!,
    :$arch,
    :$tool,
    :$type,
    #:$spec,
    :$release is copy where { /^ \d+ $/ } = 1,
    #:$force = False,
    :$debug,
    ) is export {

    my $dotted-date = $date;
    $dotted-date ~~ s/'-'/./;
    my $err;
    my ($sys, $arch, $tool, $type);
    if $os ~~ /:i lin/ {
        $sys = "linux";
        $arch = "x86_64";
        $tool = "gcc";
        $type = "tar.gz";
    }
    elsif $os ~~ /:i win/ {
        $sys = "win";
        $arch = "x86_64";
        $tool = "msvc";
        $type = "msi"; # default, else "zip" if $spec.defined
    }
    elsif $os ~~ /:i mac/ {
        $sys = "macos";
        $tool = "clang";
        $arch = "arm64"; # default, else "x86_64" if $spec.defined
        $type = "tar.gz";
    }
    else {
        say "FATAL: Unrecgnized OS '$os'. Try 'lin', 'win', or 'mac'.";
        exit;
    }

    if 29 < $release < 1 {
        say "FATAL: Release must be between 1 and 29. You entered '$release'.":
        exit;
    }

    if $spec.defined {
        $arch = "x86_84" if $os eq "macos";
        $type = "zip" if $os eq "win";
    }

    $release = sprintf "%02d", $release;

    # final download file name              backend
    #                                            date    release
    #                                                       sys   arch   tool
    #                                                       sys   arch       type
    #   https://rakudo.org/dl/rakudo/rakudo-moar-2023.09-01-linux-x86_64-gcc.tar.gz
    #                                                             spec=arch
    #   https://rakudo.org/dl/rakudo/rakudo-moar-2023.09-01-macos-arm64-clang.tar.gz
    #   https://rakudo.org/dl/rakudo/rakudo-moar-2023.09-01-macos-x86_64-clang.tar.gz
    #                                                                       spec=type
    #   https://rakudo.org/dl/rakudo/rakudo-moar-2023.09-01-win-x86_64-msvc.msi
    #   https://rakudo.org/dl/rakudo/rakudo-moar-2023.09-01-win-x86_64-msvc.zip
    #
    #   "https://rakudo.org/dl/rakudo/rakudo-moar-{$date}-{$release}-{$os}-{$arch}-{$tool}.{$type}";
    #       plus a C<.asc> and C<.checksums.txt> extensions.

    # keys of signers
    #   "https://rakudo.org/keys/*.asc

    # actual download file basename on the remote site:
    my $inbase  = "rakudo-moar-{$dotted-date}-{$release}-{$sys}-{$arch}-{$tool}.{$type}";

    # directory basename to unpack the archive in:
    # final location of the archive
    my $rak-dir = "/opt/rakudo-{$date}-{$release}";
    if $rak-dir.IO.d {
        say "WARNING: Rakudo directory '$rak-dir' exists.";
        my $res = prompt "  Do you want to delete it (y/N)? ";
        if $res ~~ /:i y/ {
            say "  Okay, deleting the directory...";
            shell "rm -rf $rak-dir";
        }
        else {
            say "  Okay, aborting installation.";
            exit;
        }
    }

    my $filebase = "rakudo-{$date}-{$release}.{$type}";

    # remote download directory
    my $remote-dir = "https://rakudo.org/dl/rakudo";

    # files to download:
    my $r-archive = "{$remote-dir}/{$inbase}";
    my $r-asc     = "{$remote-dir}/{$inbase}.asc";
    my $r-check   = "{$remote-dir}/{$inbase}.checksums.txt";

    # files renamed upon download to:
    my $f-archive = "{$filebase}";
    my $f-asc     = "{$filebase}.asc";
    my $f-check   = "{$filebase}.checksums.txt";

    # IMPORTANT: change working dir to /opt/rakudo-YYYY-MM-RR
    # requires root
    say "Creating directory download directory '$rak-dir'...";
    mkdir $rak-dir;
    chdir $rak-dir;

    # don't download the files if they are there
    if $force {
        # Rename the files as they download
        shell "curl -1sLf $r-archive -o $f-archive";
        say "  See file $f-archive";

        shell "curl -1sLf $r-asc     -o $f-asc";
        say "  See file $f-asc";

        shell "curl -1sLf $r-check   -o $f-check";
        say "  See file $f-check";
    }
    else {
        my $has-archive = $f-archive.IO.f ?? True !! False;
        my $has-asc     = $f-asc.IO.f     ?? True !! False;
        my $has-check   = $f-check.IO.f   ?? True !! False;

        # Rename the files as they download
        if not $has-archive {
            shell "curl -1sLf $r-archive -o $f-archive";
            say "  See file $f-archive";
        }
        if not $has-asc {
            shell "curl -1sLf $r-asc     -o $f-asc";
            say "  See file $f-asc";
        }
        if not $has-check {
            shell "curl -1sLf $r-check   -o $f-check";
            say "  See file $f-check";
        }
    }

    print qq:to/HERE/;
    See downloaded files:
        $f-archive
        $f-asc
        $f-check

    Checking binary validity...
    HERE

    my $is-ok = verify-checksum :checksums-file($f-check);
    if $is-ok {
        say "Files pass the binary validity check.";
    }
    else {
        say "WARNING: Files do NOT pass the binary validity check.";
        say "         Exiting.";
    }

    say "You must confirm the signatures on your own for now.";

    # extract the archive
    chdir "$rak-dir";;
    run(
        'tar',
        '--strip-components=1',
        '-xvzf',
        $f-archive,
       );

    # set the path

    # delete other raku executables

} # sub download-rakudo-bin(

sub set-path($rak-dir = "/opt/rakudo-bin") is export {
    # sets the path for the rakudo-bin installation
    # the path must come BEFORE the /usr/bin path
    # make the path look like this:
    #
    #  PATH=/opt/rakudo-pkg/bin:/opt/rakudo-pkg/share/perl6/site/bin:/usr/local/bin:/usr/bin:/bin\
    #    :/usr/local/games:/usr/games
    #
    # make it the same in two files:
    #    /etc/environment
    #    /etc/profile

    =begin comment
    # To be run in /etc/profile.d/
    RAKUDO_PATHS="$rak-dir/bin:$rak-dir/share/perl6/site/bin:/usr/bin"
    if ! echo "$PATH" | /bin/grep -Eq "(^|:)$RAKUDO_PATHS($|:)" ; then
        export PATH="$RAKUDO_PATHS:$PATH"
    fi
    =end comment

    =begin comment
    my $f = "/etc/profile.d/rakudo-paths.sh";
    my $fh = open $f, :w;
    $fh.print: qq:to/HERE/;
    # To be run in /etc/profile.d/
    RAKUDO_PATHS=\"$rak-dir/bin:$rak-dir/share/perl6/site/bin:/usr/bin\"
    if ! echo \"\$PATH\" | /bin/grep -Eq \"(^|:)\$RAKUDO_PATHS(\$|:)\" ; then
        export PATH=\"\$RAKUDO_PATHS:\$PATH\"
    fi
    HERE
    $fh.close;
    =end comment

} # sub set-path($rak-dir = "/opt/rakudo-bin") is export {


sub verify-checksum(:$checksums-file!, :$debug --> Bool) is export {
    # To verify that a downloaded file is not corrupted,
    # download the *.checksums.txt corresponding to the
    # download you want to verify. Then run
    #
    #    $ sha256 -c file_you_downloaded
    #
    # WRONG format for Debian:
    # pertinent line in the checksums file, not in standard format:
    #   SHA256 (rakudo-moar-2023.09-01-linux-x86_64-gcc.tar.gz) = 44ec... (sha256 hash)
    # shell "sha256sum -c $fcheck";

    # reformat it to:  the-check-sum file-name
    #
    # get the hash from the existing file
    my $sha;
    for $checksums-file.IO.lines -> $line is copy {
        next unless $line ~~ /:i sha256 /;
        # elim parens
        $line ~~ s/'('//;
        $line ~~ s/')'//;
        my @w = $line.words;
        $sha  = @w[3];
        last;
    }
    my $fnam = $checksums-file;
    my $fcheck-new = $fnam;
    $fnam ~~ s/\.checksums\.txt//;
    $fcheck-new ~~ s/checksums\.txt/sha256sum/;

    spurt $fcheck-new, "$sha $fnam";
    # collect results
    #   my $resfil = "res.out";
    #   shell "sha256sum -c $fcheck-new > $resfil";

    my $results = run('sha256sum', '-c', '--', $fcheck-new, :merge, :enc<latin1>).out.slurp.chomp;

    # read results from stdout
    # proper output:  file-name: OK
    # failure output: file-name: FAILED
    my $is-ok = False;
    if $results ~~ /:i \s* $fnam \s* ':' \s* OK / {
        $is-ok = True;
    }
    elsif $results ~~ /:i \s* $fnam \s* ':' \s* FAILED / {
        $is-ok = False;
    }
    else {
        die "FATAL: Unexpected output: '$results'; (expected '$fnam')";
    }
    $is-ok;

} # sub verify-checksum(:$checksums-file!, :$debug) is export {

=begin comment
say "Checking signature...";
#verify-signature :asc-file($f-asc), :checksums-file($f-check), :$debug;
verify-signature-gpg :asc-file($f-asc), :checksums-file($f-check), :$debug;
=end comment

=begin comment
#shell "curl -1sLf '$archive'";
# -1 - use TLS 1 or higher
# -s - silent
# -L - follow redirects
# -f - fail quickly with first error
# save to same name, use -O
shell "curl -OL $archive";
# save to different name, use -o
shell "curl -L1sf -o $desired-name $archive";
=end comment

sub verify-signature-gpg(:$asc-file!, :$checksums-file!, :$debug) is export {
    # Uses gpg
    #
    # One can verify the download is authentic
    # by checking its signature. One can validate the
    # .checksums.txt which contains a self contained signature.
    # To verify via the file do
    #
    #    $ gpg --output outfile --verify sigfile datafile
    #
    #    where sigfile  = detached signature file (.asc)
    #          datafile = signed data file        (.checksums.txt)
    #
    # pertinent line out of logfile.txt:
    #

    my $outfile = "outfile.txt";
    #my $logfile = "logfile.txt";
    # $ gpgv --output file --log-file logfile sigfile datafile
    my $res = run('gpg',
                  #'-vv',
                  '--output', $outfile,
                  #'--log-file', $logfile,

                  '--verify',
                  $asc-file,
                  $checksums-file,
                  :merge, :enc<latin1>
                 ).out.slurp.chomp;

    if 1 and $debug {
        note "========================================";
        note "DEBUG: contents of \$res '$res':";
        note "  $_" for $res.lines;
        note "DEBUG: end of contents of \$res '$res':";
        note "========================================";
        note "DEBUG: contents of \$outfile '$outfile':";
        note "  $_" for $outfile.IO.lines;
        note "DEBUG: end of contents of \$outfile '$outfile':";
        note "========================================";
        note "DEBUG: early exit"; exit;
    }

    # We are going to read the outfile signature fingerprints and
    # compare them with known Github key fingerprints keys from
    # our releasers.

    my @keys;
    my @w;
    #    2023-10-10 19:34:05 gpgv[64502]  using EDDSA key DDA5BDA3F5CDCE99F9ED56C12CC6E973818F386B
    note "DEBUG: checking \$outfile $outfile";
    for $outfile.IO.lines {
        #note "DEBUG: logfile line: $_";
        #                                         FINGERPRINT
        when /:i \h+ using \h+ eddsa \h+ key \h+ (\S+) \h* / {
            my $k = ~$0;
            note "DEBUG: found a key: $k";
            die "FATAL: Key length is NOT 40 characters" if $k.comb.elems != 40;
            @keys.push: $k.uc;
        }
    }

    # check the keys
    my $ok = False;
    for @keys -> $k {
        # all we need is one hit
#our %key-fingerprints = %(
        if %key-fingerprints{$k}:exists {
            # bingo!
            my $signer = %key-fingerprints{$k};
            note "DEBUG: signer=$signer; fingerprint: $k";
            $ok = True;
            last;
        }
    }
    die "FATAL: Signer key not found among known signers." unless $ok;;


} # sub verify-signature-gpg(:$asc-file!, :$checksums-file!, :$debug) is export {

sub verify-signature(:$asc-file!, :$checksums-file!, :$debug) is export {
    # Uses gpgv
    #
    # One can verify the download is authentic
    # by checking its signature. One can validate the
    # .checksums.txt which contains a self contained signature.
    # To verify via the file do
    #
    #    $ gpgv --output outfile --log-file logfile sigfile datafile
    #
    #    where sigfile  = detached signature file (.asc)
    #          datafile = signed data file        (.checksums.txt)
    #
    # pertinent line out of logfile.txt:
    #
    #    2023-10-10 19:34:05 gpgv[64502]  using EDDSA key DDA5BDA3F5CDCE99F9ED56C12CC6E973818F386B

    my $logfile = "logfile.txt";
    my $outfile = "outfile.txt";
    # $ gpgv --output file --log-file logfile sigfile datafile
    my $res = run('gpgv', '-vv', '--output', $outfile,
                  '--log-file', $logfile, '--',
                  $checksums-file, :merge, :enc<latin1>).out.slurp.chomp;

    if 0 and $debug {
        note "========================================";
        note "DEBUG: contents of \$logfile '$logfile':";
        note "  $_" for $logfile.IO.lines;
        note "DEBUG: end of contents of \$logfile '$logfile':";
        note "========================================";
        note "DEBUG: contents of \$res '$res':";
        note "  $_" for $res.lines;
        note "DEBUG: end of contents of \$res '$res':";
        note "========================================";
        note "DEBUG: contents of \$outfile '$outfile':";
        note "  $_" for $outfile.IO.lines;
        note "DEBUG: end of contents of \$outfile '$outfile':";
        note "========================================";
    }

    # We are going to read the logfile signature fingerprints and
    # compare them with known Github key fingerprints keys from
    # our releasers.

    my @keys;
    my @w;
    #    2023-10-10 19:34:05 gpgv[64502]  using EDDSA key DDA5BDA3F5CDCE99F9ED56C12CC6E973818F386B
    note "DEBUG: checking \$logfile $logfile";
    for $logfile.IO.lines {
        #note "DEBUG: logfile line: $_";
        #                                         FINGERPRINT
        when /:i \h+ using \h+ eddsa \h+ key \h+ (\S+) \h* / {
            my $k = ~$0;
            note "DEBUG: found a key: $k";
            die "FATAL: Key length is NOT 40 characters" if $k.comb.elems != 40;
            @keys.push: $k.uc;
        }
    }

    # check the keys
    my $ok = False;
    for @keys -> $k {
        # all we need is one hit
        if %key-fingerprints{$k}:exists {
            # bingo!
            my $signer = %key-fingerprints{$k};
            note "DEBUG: signer=$signer; fingerprint: $k";
            $ok = True;
            last;
        }
    }
    die "FATAL: Signer key not found among known signers." unless $ok;;

} # sub verify-signature(:$asc-file!, :$debug) is export {

sub run-cli-inst-mods(@args) is export {

    my $user    = $*USER.lc;
    my $is-root = $user eq 'root' ?? True !! False;
    my $host    = $*KERNEL.hostname;
    my $system  = $*KERNEL.hardware // "Unknown system";
    my $distro  = $*DISTRO.name;
    my $version = $*DISTRO.version;

    # we MUST have /opt/rakudo-bin installed
    my $raku = "/opt/rakudo/bin/raku".IO.e;
    my $zef  = "/opt/rakudo/bin/zef".IO.e;

    if not @args.elems {
        say qq:to/HERE/;
        Usage: {$*PROGRAM.basename} go

        This is a root-only program currently running on:

            Host:    $host
            User:    $user
            Distro:  $distro
            Version: $version
            System:  $system

        It requires an installed Rakudo binary package.
        HERE

        if $raku and $zef {
            say "You have the Rakudo binary installed.";
        }
        else {
            say "You do NOT have the Rakudo binary installed.";
        }

        exit;
    }

    unless $raku and $zef {
        say "FATAL: You do NOT have the Rakudo binary installed.";
        exit;
    }

} # sub run-cli-inst-mods(@args) is export {

sub get-latest-release(--> Str) is export {
    # checks dates to get latest release date

    # get the latest 6 possible release dates
    my @dates;

    my $d = Date.new(now);
    @dates.push: $d;
    for 1..5 -> $n {
        @dates.push: $d.earlier(months => $n);
    }

    #say "Last six dates:";
    #say "  $_" for @dates;

    for @dates -> $date {
        my $res = check-https :$date;
        if $res {
            #say "Latest release is $date";
            return $date.Str; # $res;
        }
    }
    return "Unknown release date";

    =begin comment
        my $year  = $d.year;
        my $month = sprintf "%02d", $d.month;
        # dotted date
        my $reldate = "{$year}.{$month}";
    =end comment
} # sub get-latest-release(--> Str) {

sub check-https(:$sys  = 'linux',
                :$arch = 'x86_64',
                :$tool = 'gcc',
                :$type = 'tar.gz',
           Date :$date!,
                :$debug
                --> Bool
               ) is export {
    # checks if a date has a release
    my $month = sprintf "%02d", $date.month;
    my $year  = $date.year;
    my $release = "01";

    # check file
    my $reldate = "{$year}.{$month}";

    # actual download file basename on the remote site:
    my $inbase  = "rakudo-moar-{$reldate}-{$release}-{$sys}-{$arch}-{$tool}.{$type}";

    # final download file name              backend
    #                                            date    release
    #                                                       sys   arch   tool
    #                                                       sys   arch       type
    #   https://rakudo.org/dl/rakudo/rakudo-moar-2023.09-01-linux-x86_64-gcc.tar.gz
    #
    #                                                             spec=arch
    #   https://rakudo.org/dl/rakudo/rakudo-moar-2023.09-01-macos-arm64-clang.tar.gz
    #   https://rakudo.org/dl/rakudo/rakudo-moar-2023.09-01-macos-x86_64-clang.tar.gz
    #
    #                                                                       spec=type
    #   https://rakudo.org/dl/rakudo/rakudo-moar-2023.09-01-win-x86_64-msvc.msi
    #   https://rakudo.org/dl/rakudo/rakudo-moar-2023.09-01-win-x86_64-msvc.zip
    #
    #   "https://rakudo.org/dl/rakudo/rakudo-moar-{$date}-{$release}-{$os}-{$arch}-{$tool}.{$type}";
    #       plus a C<.asc> and C<.checksums.txt> extensions.

    my $filebase = "rakudo-{$reldate}-{$release}.{$type}";
    # remote download directory
    my $remote-dir = "https://rakudo.org/dl/rakudo";
    # files to download:
    my $r-check   = "{$remote-dir}/{$inbase}.checksums.txt";

    # files renamed upon download to:
    my $tmpdir = "/tmp/rel-date";
    mkdir $tmpdir;
    my $f-check   = "{$tmpdir}/{$filebase}.checksums.txt";

    try { so quietly shell "curl -1sLf $r-check   -o $f-check" } // False;
} # sub check-https(:$sys  = 'linux',

sub get-release-number(Date $reldate --> Str) is export {
    # input Date, return "yyyy-mm"
    my $mon = sprintf "%02d", $reldate.month;
    "{$reldate.year}-$mon.01"
} # sub get-release-number(Date $reldate --> Str) is export {

sub run-help is export {
    print qq:to/HELP/;
    Other modes and options:


    HELP
} # sub run-help {

