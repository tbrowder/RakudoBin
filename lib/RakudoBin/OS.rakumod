unit class RakudoBin::OS;

# dup of that in my published module QueryOS
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

    my %h = os-version-parts($!version.Str); # $n.Num;    # 10, 11, 20.4, ...
    $!version-serial = %h<version-serial>;
    $!version-name   = %h<version-name>;
    # we have to support multiple integer chunks for numerical comparison
    $!vshort-name    = %h<vshort-name>;
    $!vnum           = %h<vnum>;
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

method is-linux(--> Bool) {
    not (self.is-macos or self.is-windows)
}

method is-macos(--> Bool) {
    my $vnam = $*DISTRO.name.lc;
    $vnam ~~ /macos/
}

method is-windows(--> Bool) {
    my $vnam = $*DISTRO.name.lc;
    $vnam ~~ /mswin/
}

# end of class OS definition
