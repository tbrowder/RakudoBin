use Test;
use RakudoPkg;

my $res  = my-resources;
my $mfil = $res<files/modules.txt>.absolute;
ok $mfil.IO.f;
ok $mfil.IO.r;

my $s = $mfil.IO.slurp;
isa-ok $s, Str;

done-testing;
