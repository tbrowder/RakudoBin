unit module  RakudoPkg;

# Debian releases
our %debian-vnames is export = %(
    etch => 4,
    lenny => 5,
    squeeze => 6,
    wheezy => 7,
    jessie => 8,
    stretch => 9,
    buster => 10,
    bullsye => 11,
    bookworm => 12,
    trixie => 13,
    forky => 14,
);
our %debian-vnum is export = %debian-vnames.invert;

# Ubuntu releases
our %ubuntu-vnames is export = %(
   trusty => 14,
   xenial => 16,
   bionic => 18,
   focal => 20,
   jammy => 22,
   lunar => 23,
);
our %ubuntu-vnum is export = %ubuntu-vnames.invert;

# key locations 
# newest key
constant $KEY1 is export = "/usr/share/keyrings/nxadm-pkgs-rakudo-pkg-archive-keyring.gpg";
# key for older versions
constant $KEY2 is export = "/etc/apt/trusted.gpg.d/nxadm-pkgs-rakudo-pkg.gpg";

=begin comment
# sytems confirmed
# name ; version
ubuntu; 22.04.3.LTS.Jammy.Jellyfish
ubuntu; 20.04.6.LTS.Focal.Fossa 
macos;  12.6.7
macos;  13.5  
macos;  11.7.8
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

class OS is export {
    # the two parts of the $*DISTRO object:
    has $.name;              # debian, ubuntu, macos, mswin32, ...
    # the full Version string:
    has $.version;           # 1.0.1.buster, bookworm, ...

    # DERIVED PARTS
    # the serial part
    has $.version-serial = "";    # 10, 11, 20.4, ...
    # the string part
    has $.version-name   = "";      # buster, bookworm, xenial, ...
    # a numerical part for comparison between Ubuntu versions (x.y.z ==> x.y)
    # also used for debian version comparisons
    has $.vshort-name    = "";
    has $.vnum           = 0;

    # a hash to contain the parts
    # %h = %(
    #     version-serial => value,
    #     version-name   => value,
    #     vshort-name    => value,
    #     vnum           => value,
    # )

    # for rakudo-pkg use
    # valid for Debian and Ubuntu
    has $.keyring-location = "";

    submethod TWEAK {
        # TWO METHODS TO INITIATE
        unless $!name.defined and $!version.defined {
            # the two parts of the $*DISTRO object:
            $!name    = $*DISTRO.name.lc;
            $!version = $*DISTRO.version;
        }

        # what names does this module support?
        unless $!name ~~ /:i debian | ubuntu/ {
            note "WARNING: OS $!name is not supported. Please file an issue.";
        }
  
        # other pieces needed for installation by rakudo-pkg
        my %h = os-version-parts($!version.Str); # $n.Num;    # 10, 11, 20.4, ...
        $!version-serial = %h<version-serial>; 
        $!version-name   = %h<version-name>; 
        # we have to support multiple integer chunks for numerical comparison
        $!vshort-name    = %h<vshort-name>; 
        $!vnum           = %h<vnum>; 

        $!keyring-location = key-location($!name, $!vnum);
    }

    # using info from rakudo-pkg, the keyring_location varies:
    #   for Debian Stretch, Ubuntu 16.04 and later:
    #     /usr/share/keyrings/nxadm-pkgs-rakudo-pkg-archive-keyring.gpg
    #   for Debian Jessie, Ubuntu 15.10 and earlier:
    #     /etc/apt/trusted.gpg.d/nxadm-pkgs-rakudo-pkg.gpg
    sub key-location($name, Num $vnum) is export {
        my $keyloc = "N/A";
        if $name eq 'ubuntu' {
            # need to know numerical version number
            if $vnum >= 16.04 {
                $keyloc = $KEY1; #"/usr/share/keyrings/nxadm-pkgs-rakudo-pkg-archive-keyring.gpg";
            }
            else {
                $keyloc = $KEY2; #"/etc/apt/trusted.gpg.d/nxadm-pkgs-rakudo-pkg.gpg";
            }
        }
        elsif $name eq 'debian' {
            # need to know numerical version number of Stretch
            my $dn = %debian-vnames<stretch>;
            if $vnum >= $dn {
                $keyloc = $KEY1; #"/usr/share/keyrings/nxadm-pkgs-rakudo-pkg-archive-keyring.gpg";
            }
            else {
                $keyloc = $KEY2; #"/etc/apt/trusted.gpg.d/nxadm-pkgs-rakudo-pkg.gpg";
            }
        }
        $keyloc
    }

    sub os-version-parts(Str $version --> Hash) is export { 
        # break version.parts into serial and string parts
        # create a numerical part for serial comparison
        my @parts = $version.split('.');
        my $s = ""; # string part
        my $n = ""; # serial part
        my @c;      # numerical parts
        for @parts -> $p {
            if $p ~~ /^\d+$/ { # Int {
                # assign to the serial part ($n, NOT a Num)
                # separate parts with periods
                $n ~= '.' if $n;
                $n ~= $p;
                # save the integers for later use
                @c.push: $p;
            }
            elsif $p ~~ Str {
                # assign to the string part ($s)
                # separate parts with spaces
                $s ~= ' ' if $s;
                $s ~= $p;
            }
            else {
                die "FATAL: Version part '$p' is not an Int nor a Str";
            }
        }
        my $vname   = $s; # don't downcase here.lc;
        # extract the short name
        my $vshort = $vname.lc;
        if $vshort {
            $vshort ~~ s:i/lts//;
            $vshort = $vshort.words.head;
        }
        
        my $vserial = $n; # 10, 11, 20.04.2, ...
        if not @c.elems {
            # not usual, but there is no serial part, so make it zero
            @c.push: 0;
            $vserial = 0;
        }

        # for numerical comparison
        # use the first two parts as is, for now add any third part to the
        # second by concatenation 
        my $vnum = @c.elems > 1 ?? (@c[0] ~ '.' ~ @c[1]) !! @c.head;
        if @c.elems > 2 {
            $vnum ~= @c[2];
        }

        # return the hash
        my %h = %(
            version-serial => $vserial,
            version-name   => $vname,
            vshort-name    => $vshort.lc,
            vnum           => $vnum.Num, # it MUST be a number
        );
        %h
    }
}

sub get-paths($dir = '.' --> Hash) is export {
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
}
 
sub my-resources is export {
    %?RESOURCES
}

sub is-debian(--> Bool) {
    my $vnam = $*DISTRO.name.lc;
    $vnam eq 'debian';
}

sub is-ubuntu(--> Bool) {
    my $vnam = $*DISTRO.name.lc;
    $vnam eq 'ubuntu';
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

sub manage-symlinks(:$delete, :$debug) is export {
    note "WARNING: this sub is no longer used";
    return;
    # for now set just bin progs in /opt-rakudo-pkg/bin
    # run this after installation is complete at
    # the end of sub install-raku

    =begin comment
    # file: rakudo-pkg.sh
    # To be run in /etc/profile.d/
    RAKUDO_PATHS=/opt/rakudo-pkg/bin:/opt/rakudo-pkg/share/perl6/bin
    if ! echo "$PATH" | /bin/grep -Eq "(^|:)$RAKUDO_PATHS($|:)" ; then
        export PATH="$PATH:$RAKUDO_PATHS"
    fi
    =end comment
    #=begin comment
    # instead, try to symlink the paths to /usr/local/bin:
    # but it may not work...
    # collect the files in a hash
    # delete those in the %ignore hash
    my %ignore = set <
        install-zef
        rakudo-pkg_path.sh
        fix-windows10
        add-rakudo-to-path
    >;
    my $dir = "/opt/rakudo-pkg/bin";
    my @fils = dir $dir;
    if $debug {
        say "DEBUG: files in dir '$dir' to symlink:";
        say "  $_" for @fils;
    }
    for @fils -> $path {
        #say "DEBUG: skipping ignored file {$path.IO.basename}" if %ignore{$path.IO.basename}:exists;
        next if %ignore{$path.IO.basename}:exists;

        # symlink to /usr/local/bin
        # ln -sf /opt/rakudo-pkg/bin/$f /usr/local/bin/$f.IO.basename
        my $srcpath = $path;
        my $link = "/usr/local/bin/{$path.IO.basename}";
        # create the symlink OR remove it
        # if it exists, leave it alone unless unlinking
        my $link-exists = $link.IO.s ?? True !! False;
        if $link-exists {
            unlink $link if $delete;
        }
        else {
            next if $delete;
            symlink $srcpath, $link;
        }
    }
    #=end comment
}

sub install-raku(:$debug) is export {
    my $dir = "/opt/rakudo-pkg";
    if $dir.IO.d {
       say qq:to/HERE/;
       Directory '$dir' already exists. It must be removed first
       by the 'remove raku' mode.
       HERE
    }
    else {
       say "Directory '$dir' does not exist.";
       say "Installing 'rakudo-pkg'...";
    }
    my $os = OS.new;

    if $debug {
       print qq:to/HERE/;
       DEBUG: sub 'install-raku' is not yet usable...
       OS = {$os.name}
       version = {$os.version}
       number = {$os.vnum};
       nxadm's keyring location = {$os.keyring-location}
       HERE
    }

    if $os.name !~~ /:i debian / {
        say "FATAL: Only Debian can be handled for now.";
        say "       File an issue if you want another distro.";
        say "       Exiting.";
        exit;
    }
    say "Continuing...";

    if $os.name ~~ /:i debian / {
        shell "apt-get install -y debian-keyring";          # debian only
        shell "apt-get install -y debian-archive-keyring";  # debian only
    }
    if $os.name ~~ /:i debian|ubuntu / {
        shell "apt-get install -y apt-transport-https";
    }

    # only debian or ubuntu past here
    shell "curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/gpg.0DD4CA7EB1C6CC6B.key' |  gpg --dearmor >> {$os.keyring-location}";

    shell "curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/config.deb.txt?distro={$os.name}&codename={$os.version-name}' > /etc/apt/sources.list.d/nxadm-pkgs-rakudo-pkg.list";
    shell "apt-get update";
    shell "apt-get install rakudo-pkg";

    =begin comment
    set-sym-links();
    # take care of the PATH for all
    note "Log out and login to update your path for 'raku' to be found";
    note "Use this program to install 'zef'":
    note "Installation of raku via rakudo-pkg is complete";
    note "Removal of OS package 'rakudo' is complete";
    =end comment

    # add path info to /etc/profile.d/rakudo-pkg.sh
    my $f = "/etc/profile.d/rakudo-pkg.sh";
    my $rpath = q:to/HERE/;
    RAKUDO_PATHS=/opt/rakudo-pkg/bin:/opt/rakudo-pkg/share/perl6/bin:/
    if ! echo "$PATH" | /bin/grep -Eq "(^|:)$RAKUDO_PATHS($|:)" ; then
        export PATH="$PATH:$RAKUDO_PATHS"
    fi
    HERE
    if not $f.IO.f {
        say "Adding new PATH component in file '$f'...";
        spurt $f, $rpath;   
    }
    else {
        # dang!
    }

} # sub install-raku

sub remove-raku() is export {
    my $dir = "/opt/rakudo-pkg";
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

        shell "apt-get remove rakudo-pkg";
        shell "rm -rf $dir" if $dir.IO.d;
        say "Package '$pkg' and directory '$dir' have been removed.";
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
}

sub install-zef() is export {
    #    shell "/opt/rakudo-pkg/bin/install-zef"; # for root or normal user
    say "DEBUG: sub 'install-zef' is not yet usable...";
}

sub remove-zef() is export {
    say "DEBUG: sub 'remove-zef' is not yet usable...";
}

sub install-path(:$user, :$restore, :$debug) is export {
    # $user is 'root' or other valid user name.
    my $home;
    if $user eq 'root' {
        $home = "/root";
    }
    else {
        $home = "/home/$user";
    }

    # Files needing changing or updating on Debian for Bash users:
    # We add a couple of lines as an embedded Bash action
    # based on the RAKUDO_PKG script:
    # except: put the rakudo-pkg path 
    # script in FRONT of the existing $PATH
    #=begin comment
    my $rpath = q:to/HERE/;
    RAKUDO_PATHS=/opt/rakudo-pkg/bin:/opt/rakudo-pkg/share/perl6/bin:/
    if ! echo "$PATH" | /bin/grep -Eq "(^|:)$RAKUDO_PATHS($|:)" ; then
        #export PATH="$PATH:$RAKUDO_PATHS"
        export PATH="$RAKUDO_PATHS:$PATH"
    fi
    HERE
    #=end comment

    # Affected files
    # For all users:
    my $a1 = "/etc/bash.bashrc";
    my $a2 = "/etc/profile";
    my $a3 = "/etc/profile.d/rakudo-pkg.sh";

    # Particular users:
    my $u1 = "{$home}/.bashrc";
    my $u2 = "{$home}/.profile";
    my $u3 = "{$home}/.bash_aliases";
    my $u4 = "{$home}/.bash_profile";
    my $u5 = "{$home}/.xsessionrc";

    for $u1, $u2, $u3, $u4, $u5 -> $f {
        handle-path-file $f, :$user, :$restore, :$debug;
    }
    return if $user ne "root";

    for $a1, $a2, $a3 -> $f {
        handle-path-file $f, :$user, :$restore, :$debug;
    }
}

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


}

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
}

