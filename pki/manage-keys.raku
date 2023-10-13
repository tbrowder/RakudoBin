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

my $create-keyring    = 0;
my $list-keys         = 0;
my $list-fingerprints = 0;
my $import-key        = 0;
my $delete-key        = 0;
my $generate-key      = 0;
my $key               = 0;

sub z {
    $create-keyring    = 0;
    $list-keys         = 0;
    $list-fingerprints = 0;
    $import-key        = 0;
    $delete-key        = 0;
    $generate-key      = 0;
}

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <mode> [debug]

    Provides PGP key management.

    Modes:
      cr    - create keyring
      lk    - list keys
      lf    - list key fingerprints

      ik    - import key X
      dk    - delete key X
      gk    - generate key with ID X

      key=X - where X is a detached key.asc to be imported
              or a key ID to be deleted or generated
    HERE

    exit;
}

for @*ARGS {
    when /:i ^c/ {
        z;
        ++$create-keyring;
    }
    when /:i ^lk/ {
        z;
        ++$list-keys;
    }
    when /:i ^lf/ {
        z;
        ++$list-fingerprints;
    }
    when /:i ^ik/ {
        z;
        ++$import-key;
    }
    when /:i ^dk/ {
        z;
        ++$delete-key;
    }
    when /:i ^gk/ {
        z;
        ++$generate-key;
    }

    when /:i ^key '=' (\S+) / {
        $key = ~$0;
    }
}

if $create-keyring {
    create-keyring;
}
elsif $list-keys {
    list-keys;
}
elsif $list-fingerprints {
    list-fingerprints;
}
elsif $import-key {
    if $key {
        import-key :$key;
    }
    else {
        import-key;
    }
}
elsif $delete-key {
    delete-key :$key;
}
elsif $generate-key {
    generate-key :$key;
}

#=== subroutines ====
sub list-fingerprints() is export {
    # gpg --fingerprint
    say run(
        'gpg',
        '--fingerprint',
        :merge,
        :enc<latin1>,
       ).out.slurp;
}

sub create-keyring() is export {
    # gpg --create-keyrings
    say run(
        'gpg',
        '--create-keyrings',
        :merge,
        :enc<latin1>,
       ).out.slurp;
}

sub list-keys() is export {
    # gpg --list-keys
    say run(
        'gpg',
        '--list-keys',
        '--keyid-format',
        'short',
        :merge,
        :enc<latin1>,
       ).out.slurp;
}

sub import-key(:$key) is export {
    if $key.defined {
        # the key is a file name
        if not $key.IO.r {
            note "FATAL: Key file '$key' not found.";
            exit;
        }
        say run(
            'gpg',
            '--import',
            $key,
            :merge,
            :enc<latin1>,
           ).out.slurp;
        return;
    }

    for %keys.keys -> $k {
        # the key is a file name
        if not $k.IO.r {
            note "ERROR: Key file '$k' not found.";
            next;
        }
        say run(
            'gpg',
            '--import',
            $k,
            :merge,
            :enc<latin1>,
           ).out.slurp;
    }
}

sub delete-key($key-id) is export {
    # gpg --remove 0x1234ABCD  # where the input is a key ID
    run(
        'gpg',
        '--remove',
        $key-id,
       );
}

sub generate-key($key-id) is export {
    # gpg --remove 0x1234ABCD  # where the input is a key ID
    run(
        'gpg',
        '--generate-key', 
        $key-id,
       );
}


