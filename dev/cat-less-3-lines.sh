# antononcube
echo "antononcube: 8 chars"
raku -e 'say $_ for "somefile".IO.lines[^(*-3)]'

# lizmat
echo "lizmat: 10 chars:"
raku -e 'say $_ for "somefile".IO.lines.head(*-3)'

