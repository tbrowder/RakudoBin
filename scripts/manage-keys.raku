#!/usr/bin/env raku

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
    run(
       );
}

sub list-keys() is export {
    run(
       );
}

sub import-key() is export {
    run(
       );
}

sub delete-key() is export {
    run(
       );
}



