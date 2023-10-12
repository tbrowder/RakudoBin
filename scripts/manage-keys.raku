#!/usr/bin/env raku

# pgpgpg is the Debian prog for using 'gpg' in place of 'pgp'

use lib <../lib>;

#use RakudoBin;

=begin comment
my %keys = set <
    alexander_kiryuhin-FE750D152426F3E50953176ADE8F8F5E97A8FCDE.asc
    justin_devuyst-59E634736AFDCF9C6DBAC382602D51EACA887C01.asc
    patrick_boeker-DB2BA39D1ED967B584D65D71C09FF113BB6410D0.asc
    rakudo_github_automation-3E7E3C6EAF916676AC549285A2919382E961E2EE.asc
>;
=end comment
my %keys = set <
    ak.asc
    jd.asc
    pb.asc
    rg.asc
>;

my $create-keyring = 0;
my $list-keys      = 0;
my $import-key     = 0;
my $delete-key     = 0;

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <mode> [debug]

    Provides PGP key management.

    Modes:
      create-keyring
      list-keys
      import-key
      delete-key
    HERE

    exit;
}

for @*ARGS {
    when /:i ^c/ {
        create-keyring()
    }
    when /:i ^l/ {
        list-keys()
    }
    when /:i ^i/ {
        import-key()
    }
    =begin comment
    when /:i ^d/ {
        delete-key()
    }
    =end comment
}

sub create-keyring() is export {
    # pgp --create-keyrings
    say run(
        'pgpgpg',
        '--create-keyrings',
        :merge,
        :enc<latin1>,
       ).out.slurp;
}

sub list-keys() is export {
    # pgp --list-keys
    say run(
        'pgpgpg',
        '--list-keys',
        :merge,
        :enc<latin1>,
       ).out.slurp;
}

#sub import-key($key-file) is export {
sub import-key() is export {
    for %keys.keys -> $k {
        # the key is a file name
        if not $k.IO.r {
            note "ERROR: Key file '$k' not found.";
            next;
        }
        my $key = $k.IO.slurp;
        say run(
            'pgpgpg',
            '--import',
            $key,
            :merge,
            :enc<latin1>,
           ).out.slurp;
    }
}

sub delete-key($key-id) is export {
    # pgp --remove 0x1234ABCD  # where the input is a key ID
    run(
        'pgpgpg',
        '--remove',
        $key-id,
       );
}



