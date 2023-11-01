use Test;
use RakudoBin;

my $o = OS.new;

with $o.name {
    # known system names
    when /:i mswin / {
        is 1, 1
    }
    when /:i debian / {
        is 1, 1
    }
    when /:i ubuntu / {
        is 1, 1
    }
    when /:i macos / {
        is 1, 1
    }
    when /:i suse / {
        is 1, 1
    }
    when /:i gentoo / {
        is 1, 1
    }
    default {
       is 1,1;
       # warn of unknown distribution
       note "NOTE: Unknown distro name: '$_'";
       note qq:to/HERE/;
              Please file an issue report and include the
              output of:
                say $*DISTRO.name
                say $*DISTRO.version
       HERE
    }
}

done-testing;
