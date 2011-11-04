%% -----------------------------------------------------------------------------
%%
%% Copyright (c) 2011 Tim Watson (watson.timothy@gmail.com)
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.
%% -----------------------------------------------------------------------------
-module(configure).

-include_lib("libconf/include/libconf.hrl").
-compile(export_all).

%% TODO: replace this with a libconf-bootstrap compatible bootstrap.config
%%      so that the module (configure.erl) can be generated on the fly
%%      (which also means we can avoid managing the 'build' directory 
%%      structure and let libconf generate it on the fly)

main(Args) ->
    libconf:configure(Args, options(), rules()).

options() ->
    [{"--(?<option>.*)=(?<value>.*)", fun erlang:list_to_tuple/1,
        [option, value],
        [{"prefix",
            "Base install directory - defaults to the release folder", "./"},
         {"resolve_format", "resolve-conf format (see "
            "http://www.erlang.org/doc/apps/erts/inet_cfg.html for details)",
            "resolv"},
         {"resolve_file", "location of the resolve file", 
            "/etc/resolv.conf"}]}].

rules() ->
    [{checks, [
        #check{ type=rebar, name=rebar, mandatory=true,
                capture=filename:join("build", "deps"),
                data={"git://github.com/hyperthunk/rebar.git",
                      "pub-cmd-alt-deps" }}
     ]},
     {templates, [
        #template{ name=rebar, output="rebar",
                   overwrite=true, checks=[rebar] },
        #template{ name=release_vars, overwrite=true,
                   output="release/release.vars" }]},
     {actions, [
        #action{ type=chmod, target="rebar",
                 config={mode, 8#00100},
                 checks=[rebar] }
     ]}].
