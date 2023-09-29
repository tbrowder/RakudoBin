use Test;
use RakudoPkg;

my (%sys, %sys2); # defined in BEGIN block near the EOF

subtest {
    my $os = OS.new; #os-version;
    isa-ok $os, OS, "native Version info: name '{$*DISTRO.name}', version '{$*DISTRO.version}'";
    is $os.name, $*DISTRO.name, "my distro name '{$os.name}'";
    is $os.version, $*DISTRO.version, "my distro version '{$os.version}'";
    is $os.version.parts, $*DISTRO.version.parts, "my distro version.parts '{$os.version.parts}'";
}, "Testing class OS on native DISTRO object";

# parsing of an arbitrary version string
#    sub os-version-parts(Str $version --> Hash) is export {
subtest {
    my $vs = "2.1.20.Some.OS";
    my %h = os-version-parts $vs;
    isa-ok $vs, Str, "arbitrary version string '{$vs}'";
    isa-ok %h<version-serial>, Str, "arbitrary version num part string '{%h<version-serial>}'";
    isa-ok %h<version-name>, Str, "arbitrary version string part '{%h<version-name>}'";
    isa-ok %h<vnum>, Num, "version number for comparison '{%h<vnum>}'";
}, "Testing parsing of an arbitrary version string";

# parsing version strings from live data on Github workflows
=begin comment 
# sytems confirmed # name ; version
ubuntu; 22.04.3.LTS.Jammy.Jellyfish
ubuntu; 20.04.6.LTS.Focal.Fossa 
macos;  12.6.7
macos;  13.5  
macos;  11.7.8
mswin32; 10.0.17763.52
#         ^   ^
#         |   |_ build number
#         |_____ Windows 10
=end comment

subtest {
    for %sys.keys.sort -> $k {
        # the given
        my $name    = %sys{$k}<name>;
        my $version = %sys{$k}<version>;

        # the distro object
        my $os = OS.new: :$name, :$version; #os-version;

        # to test against

        my $vname = %sys{$k}<vname>;
        is $os.vshort-name, $vname;

        my $serial = %sys{$k}<serial>;
        is $os.version-serial, $serial;

        my $vnum = %sys{$k}<vnum>;
        is $os.vnum, $vnum;
    }
}, "Testing parsing of actual system data";

subtest {
    for %sys2.keys.sort -> $k {
        # the given
        my $name    = %sys2{$k}<name>;
        my $version = %sys2{$k}<version>;

        # the distro object
        my $os = OS.new: :$name, :$version; #os-version;

        # to test against
        my $keyloc = %sys2{$k}<keyloc>;
        is $os.keyring-location, $keyloc, "key location for name/version $name $version";
    }
}, "Testing key location with actual system data";

BEGIN {
%sys2 = %(
    # ubuntu the break point for this and later versions, $KEY1
    uL1 => {
        # input
        name    => "ubuntu", 
        version => "16.04.Xenial",
        # test
        keyloc => $KEY1,
    },
    # debian the break point for this and later versions, 1$KEY1
    dL1 => {
        # input
        name    => "debian", 
        version => "9.Stretch",
        # test
        keyloc => $KEY1,
    },
    # ubuntu the break point for this and earlier versions, $KEY2
    uEh => {
        # input
        name    => "ubuntu", 
        version => "15.10.Wily.Werewolf",
        # test
        keyloc => $KEY2,
    },
    # debian the break point for this and earlier versions, $KEY2
    dE1 => {
        # input
        name    => "debian", 
        version => "8.Jessie",
        # test
        keyloc => $KEY2,
    },

    # add at least one earlier and one later for each system
    uE2 => {
        # input
        name    => "ubuntu", 
        version => "14.Trusty",
        # test
        keyloc => $KEY2,
    },
    uL2 => {
        # input
        name    => "ubuntu", 
        version => "22.04.3.Jammy.Jellyfish",
        # test
        keyloc => $KEY1,
    },
    uL3 => {
        # input
        name    => "ubuntu", 
        version => "20.04.6.LTS.Focal.Fossa",
        # test
        keyloc => $KEY1,
    },

    dE2 => {
        # input
        name    => "debian", 
        version => "4.Etch",
        # test
        keyloc => $KEY2,
    },
    dL2 => {
        # input
        name    => "debian", 
        version => "12.Bookworm",
        # test
        keyloc => $KEY1,
    },
);

%sys = %(
    1 => {
        # input
        name    => "ubuntu", 
        version => "22.04.3.LTS.Jammy.Jellyfish",
        # to test
        vname   => "jammy",
        serial  => "22.04.3",
        vnum    => "22.043",
    },
    2 => {
        # input
        name    => "ubuntu", 
        version => "20.04.6.LTS.Focal.Fossa",
        # to test
        vname   => "focal",
        serial  => "20.04.6",
        vnum    => "20.046",
    },
    3 => {
        # input
        name    => "macos",  
        version => "12.6.7",
        # to test
        vname   => "",
        serial  => "12.6.7",
        vnum    => "12.67",
    },
    4 => {
        # input
        name    => "macos",  
        version => "13.5",
        # to test
        vname   => "",
        serial  => "13.5",
        vnum    => "13.5",
    },
    5 => {
        # input
        name    => "macos",  
        version => "11.7.8",
        # to test
        vname   => "",
        serial  => "11.7.8",
        vnum    => "11.78",
    },
    6 => {
        # input
        name    => "mswin32", 
        version => "10.0.17763.52",
        # to test
        vname   => "",
        serial  => "10.0.17763.52",
        vnum    => "10.017763",
    },
);
} # end of BEGIN block

=begin comment
for %sys.keys.sort -> $k {
    say "System; $s";
    $s ~~ s:g/\s//; # no spaces
    my @w = $s.split(';');
    say "  name/version string: {@w.raku}";
}
=end comment

    

done-testing;
