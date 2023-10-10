my $out1 = 'out1.txt';
my $out2 = 'out2.txt';
my $out3 = 'out3.txt';

my $err1 = 'err1.txt';
my $err2 = 'err2.txt';
my $err3 = 'err3.txt';

shell("sha256sum -c some-file.sha256sum  1> $out1 2> $err1").so;
shell("sha256sum -c fake-file.sha256sum  1> $out2 2> $err2").so;
shell("sha256sum -c bad-format.sha256sum 1> $out3 2> $err3").so;

my $merge1 = run('sha256sum', '-c', '--', 'some-file.sha256sum',  :merge).out.slurp.chomp;
my $merge2 = run('sha256sum', '-c', '--', 'fake-file.sha256sum',  :merge).out.slurp.chomp;
my $merge3 = run('sha256sum', '-c', '--', 'bad-format.sha256sum', :merge).out.slurp.chomp;


say qq:to/HERE/;
Expecting success:
  stdout: {$out1.IO.slurp.chomp} 
  stderr: {$err1.IO.slurp.chomp}
  merge:
    {$merge1}

Failure:
  stdout: {$out2.IO.slurp.chomp}
  stderr: {$err2.IO.slurp.chomp}
  merge:
    {$merge2}

Bad format:
  stdout: {$out3.IO.slurp.chomp}
  stderr: {$err3.IO.slurp.chomp}
  merge:
    {$merge3}
HERE

my $io = IO::Handle.new: :encoding<iso-8859-1>;
for $merge1, $merge2, $merge3 -> $f {
    $f.$io.lines -> $line {
        say "  $line";
    }
}

