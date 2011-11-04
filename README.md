# Complex *rebar* Build Customisation

This is an example project, demonstrating extensive build customisation based
on a combination of rebar plugins and some custom tools.

## Running it

Run it like so.

    $ sh build.sh

## Status and Roadmap

The goals of this (example) project are to determine the best (likely) simple
approaches to

- being able to build required dependencies that are not rebar compatible
    - because they are not packaged according to OTP principles
    - because they are packaged in a way that rebar cannot handle
    - because they rely on *foreign* tools (such as make)
    - because they are not Erlang code (gasp), e.g., Java node(s)
- not depending on autotools/make to preprocess a build for a target environment
- bootstrapping rebar on the target system
    - instead of assuming an embedded binary will fit in any environment
    - allowing for custom forks/branches of rebar
- [*]bootstrapping rebar plugins so that multiple passes are not required to build
- [*]bootstrapping _configure_ with minimal code duplication across projects
- [*]handling multi-phase and/or multi-profile builds
    - e.g., see the differences between `rebar.config` and `release.config`

Items marked with an [*]asterisk are still _in progress_, and most of the
features of this sample are in some way experimental, although I am actively
using all of them in a few other (ongoing) open source projects.

## Implementation Notes

This is all very experimental, and I'm treating it as an incubator for various
rebar plugins, customisations and other things (including a very lightweight
bootstrap/configure tool chain for Erlang/OTP projects).

If you want to know how it works, dig in to build.sh and then follow the yellow
brick road, taking note of your stops at

- the ./bootstrap script, which hocks together a special *build* project
    - I'm going to make this invisible in a future release of the tool(s)
- the `pre_release_plugin`, which is used at various stages of the build
- the [libconf](https://github.com/hyperthunk/libconf) definitions provided by `configure.erl`
    - In future releases, you'll be able to do this with *configuration* __or__ *code*
- the `rebar.config` used to install the plugins and deps
- the `rebar_alien_plugin` and `rebar_alt_deps` plugins (https://github.com/hyperthunk)
- the `release.config` that is used to build the release (using rebar)

## Important Caveats

A number of the tools that this project uses are under development and likely
to see some churn (as of 4th November 2011), so copying the approach taken here
verbatim is probably not a very sustainable (or sensible) thing to do.

In particular, you should look at the roadmap for the following projects, to get
and understanding of how changes to them will affect a build of this type (and
complexity)

- [rebar_alt_deps](https://github.com/hyperthunk/rebar_alt_deps)
- [rebar_alien_plugin](https://github.com/hyperthunk/rebar_alien_plugin)
- [remote_plugin_loader](https://github.com/hyperthunk/remote_plugin_loader)
- [libconf](https://github.com/hyperthunk/libconf)
- [libconf-bootstrap](https://github.com/hyperthunk/libconf-bootstrap)
