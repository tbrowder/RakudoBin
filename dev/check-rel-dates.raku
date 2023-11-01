#!/usr/bin/env raku

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go 

    Gets latest release date for Rakudo binary release.

    HERE
    exit;
}

#check-https;
get-latest-release;

#=== subroutines =====
sub get-latest-release() {
    # checks dates to get latest release date

    # get the latest 6 possible release dates
    my @dates;

    my $d = Date.new(now);
    @dates.push: $d;
    for 1..5 -> $n {
        @dates.push: $d.earlier(months => $n);
    }

    #say "Last six dates:";
    #say "  $_" for @dates;

    for @dates -> $date {
        my $res = check-https :$date;
        if $res {
            say "Latest release is $date";
            return;
        }
    }
    say "Unknown release date";

    =begin comment
        my $year  = $d.year;
        my $month = sprintf "%2d", $d.month;
        # dotted date
        my $reldate = "{$year}.{$month}";
    =end comment
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
    # files to download:
    my $r-check   = "{$remote-dir}/{$inbase}.checksums.txt";
    # files renamed upon download to:
    my $f-check   = "{$filebase}.checksums.txt";

    try { so quietly shell "curl -1sLf $r-check   -o $f-check" } // False;
}

