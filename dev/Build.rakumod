# Put this file in the top level of the module's repo directory
class Build {
    # $dist-path is: repo dir
    method build($dist-path) {
        my $bfile = "gen-hashes";
        # Define the executable builder script:
        my $script = $dist-path.IO.add("build/bin/$bfile").absolute;

        # We need to set this if our script uses any dependencies that
        # may not yet be installed but are in the process of being
        # installed (such as the distribution this module comes with in lib/).
        my @libs = "$dist-path", $*REPO.repo-chain.map(*.path-spec).flat;

        # Do the building
        # (note any needed args for the build script are added after the executable $script!)
        my $proc = run :cwd($dist-path), $*EXECUTABLE, @libs.map({"-I$_"}).flat, $script, "build";
        exit $proc.exitcode;
    }
}
