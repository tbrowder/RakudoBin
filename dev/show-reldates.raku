#!/usr/bin/env raku

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | <secs>

    Shows all release dates from the latest

    HERE
    exit;
}

my $arg = @*ARGS.shift;
my $sec = $arg ~~ /\d+/ ?? $arg !! 1;
show-reldates $sec;
#=== subroutines =====
sub show-reldates($sec = 1) {
    # checks dates to get latest release date

    my @dates;

    my $d = Date.new(now);
    while 1 {
        my $res = check-https :date($d);
        if $res {
            say sprintf("%04d-%02d.01", $d.year, $d.month), 
        }
        $d = $d.earlier(months => 1);
        sleep $sec;
    }
}

sub check-https(:$sys  = 'linux',
                :$arch = 'x86_64',
                :$tool = 'gcc',
                :$type = 'tar.gz',
           Date :$date!,
                :$debug
                --> Bool
               ) is export {
    # checks if a date has a release
    my $month = sprintf "%2d", $date.month;
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
    #my $remote-dir = "https://rakudo.org/downloads/rakudo";

    # files to download:
    #my $r-check   = "{$remote-dir}/{$inbase}.checksums.txt";
    my $r-check   = "{$remote-dir}/{$inbase}.asc";

    # files renamed upon download to:
    my $tmpdir = "/tmp/rel-date";
    mkdir $tmpdir;
    #my $f-check   = "{$tmpdir}/{$filebase}.checksums.txt";
    my $f-check   = "{$tmpdir}/{$filebase}.asc";

    try { so quietly shell "curl -1sLf $r-check   -o $f-check" } // False;
}
