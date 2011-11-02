## Sample

Boostrap the build first:

    $ ./bootstrap

Then configure:

    $ ./configure --with-erlydtl=build/deps/erlydtl/ebin --verbose --nocache

Then we install the prerequisites like so:

    ./rebar skip_deps=true get-deps install-plugins install-deps

Then we generate a release:

    ./rebar -C release.config generate

Very experimental.
