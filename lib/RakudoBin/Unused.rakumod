unit module Unused;

# temp storage for unused code from earlier attempt

=begin comment
sub install-path(:$user, :$restore, :$debug) is export {
    # fix for root user only
    say "NOT USED NOW. EXITING EARLY"; exit;

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
    RAKUDO_PATHS=/opt/rakudo/bin:/opt/rakudo/share/perl6/bin:/
    if ! echo "$PATH" | /bin/grep -Eq "(^|:)$RAKUDO_PATHS($|:)" ; then
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
=end comment

=begin comment
# this is from the RakudoPkg effort, discontinued
sub install-raku(:$debug) is export {
    my $dir = "/opt/rakudo-bin";
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
=end comment
