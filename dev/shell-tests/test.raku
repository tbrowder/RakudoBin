my $out1 = 'out1.txt';
my $out2 = 'out2.txt';
my $out3 = 'out3.txt';

my $err1 = 'err1.txt';
my $err2 = 'err2.txt';
my $err3 = 'err3.txt';

shell("sha256sum -c some-file.sha256sum  1> $out1 2> $err1").so;
shell("sha256sum -c fake-file.sha256sum  1> $out2 2> $err2").so;
shell("sha256sum -c bad-format.sha256sum 1> $out3 2> $err3").so;

=begin comment
my $p1 =
my $p2 =
my $p3 =
=end comment


say qq:to/HERE/;
Expecting success:
  stdout: {$out1.IO.slurp.chomp} 
  stderr: {$err1.IO.slurp.chomp}

Failure:
  stdout: {$out2.IO.slurp.chomp}
  stderr: {$err2.IO.slurp.chomp}

Bad format:
  stdout: {$out3.IO.slurp.chomp}
  stderr: {$err3.IO.slurp.chomp}
HERE


