use Test;
use RakudoPkg;

my $debug = 0;

create-test-dir;

my $dirA = "./tmp/A";
my $dirB = "./tmp/B";
mkdir $dirA;
mkdir $dirB;
my $file = "./tmp/A/file";
spurt $file, "some text";

copy-path2dir $file, $dirB;

sub copy-path2dir($a, $b) {
    # $a.IO.copy($b);
    if $b.IO.d {
        copy $a, "$b/{$a.IO.basename}";
    }
    else {
        copy $a, $b;
    }
}

sub create-test-dir {
   my $dir = mkdir "./tmp/test-dir";
   my $tfile-a = "./tmp/test-file-a";
   my $tfile-b = "./tmp/test-file-b";
   spurt $tfile-a, "some text file A\nline 2";
   spurt $tfile-b, "some text file B\nline 2";

   copy $tfile-a, "$dir/{$tfile-a.IO.basename}";
   copy $tfile-b, "$dir/{$tfile-b.IO.basename}";
   
   my $dirA = mkdir "./tmp/test-dir/dirA";
   copy $tfile-a, "$dirA/{$tfile-a.IO.basename}";
   copy $tfile-b, "$dirA/{$tfile-b.IO.basename}";

   my $dirB = mkdir "./tmp/test-dir/dirB";
   copy $tfile-a, "$dirB/{$tfile-a.IO.basename}";
   copy $tfile-b, "$dirB/{$tfile-b.IO.basename}";
}

END {
    unless $debug {
        shell "rm -rf ./tmp";
    }
}

done-testing;
