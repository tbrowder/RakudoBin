#!/usr/bin/env raku

my %keys = set %(
    'alexander_kiryuhin-FE750D152426F3E50953176ADE8F8F5E97A8FCDE.asc',
    'justin_devuyst-59E634736AFDCF9C6DBAC382602D51EACA887C01.asc',
    'patrick_boeker-DB2BA39D1ED967B584D65D71C09FF113BB6410D0.asc',
    'rakudo_github_automation-3E7E3C6EAF916676AC549285A2919382E961E2EE.asc',
);

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <mode> [debug]

    Provides PGP key management.


    HERE


    exit;
}

for @*ARGS {
}

sub create-keyring() is export {
    # pgp --create-keyrings
    run(
       );
}

sub list-keys() is export {
    # pgp --list-keys
    run(
        'pgp',
        '--list-keys',
       );
}

sub import-key($key-file) is export {
    # pgp --import "joe user.asc"
    run(
        'pgp',
        '--import',
        $key-file,
       );
}

sub delete-key($key-id) is export {
    # pgp --remove 0x1234ABCD  # where the input is a key ID
    run(
        'pgp',
        '--remove',
        $key-id,
       );
}



