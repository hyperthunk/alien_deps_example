#!/usr/bin/env sh

# using the pre_release_plugin, call out to our bootstrap/configure tool chain,
# which is also built on rebar but also uses libconf (which will soon have 
# a replacement for bootstrap scripts which fetches and installs the whole
# build environment locally from the internet)
rebar configure \
    libconf.erlydtl=build/deps/erlydtl/ebin \
    libconf.nocache=true \
    libconf.verbose=true -v

# TODO: add a quiet=true option to rebar_alien_deps 
# for redirecting stdout to dev/null where possible

# gets all required plugins and installs all deps (including ejabberd)
./rebar skip_deps=true get-deps install-plugins install-deps -v

# generates a release, with the pre_release_plugin doing some extra pre/post 
# processing work in order to fix various suprious artefacts of process-one's
# decision to package ejabberd in a rather un-OTP manner
./rebar -C release.config generate -v
