unit module MyFoo;

sub module-source is export {
    say $?DISTRIBUTION.content("lib/MyFoo.rakumod")
}

sub module-source1 is export {
    say $?DISTRIBUTION.content("lib/MyFoo.rakumod").open.lines.head
}

sub module-source2 is export {
    say $?DISTRIBUTION.content("lib/MyFoo.rakumod").open.slurp
}

sub module-source3 is export {
    say $?DISTRIBUTION.content("lib/MyFoo.rakumod").open
}
