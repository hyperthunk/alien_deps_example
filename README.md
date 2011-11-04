## Sample

Run it like so.

    $ sh build.sh

This is very experimental, and I'm treating it as an incubator for various 
rebar plugins, customisations and other things (including a very lightweight 
bootstrap/configure tool chain for Erlang/OTP projects).

If you want to know how it works, dig in to build.sh and then follow the yellow
brick road, taking note of your stops at

- the ./bootstrap script, which hocks together a special *build* project
    - I'm going to make this invisible in a future release of the tool(s)
- the `pre_release_plugin`, which is used at various stages of the build
- the *libconf* definitions provided by `configure.erl`
    - In future releases, such bootstrapping will be *configuration only* 
- the `rebar.config` used to install plugins and deps
- the `rebar_alien_plugin` and `rebar_alt_deps` plugins (https://github.com/hyperthunk)
- the `release.config` that is used to build the release (using rebar)
