%% stored in base_dir as all the other plugins are pre-loaded into
%% lib/remote_plugin_loader/src automatically but this one is project-local
-module(pre_release_plugin).
-export([clean/2]).
-export([configure/2]).
-export([pre_generate/2, post_generate/2]).

%% TODO: think about writing a rebar_libconf_plugin...

configure(Config, _) ->
    %% NB: *this* function will run with any stock rebar (@'04/11/2011')
    rebar_log:log(info, "Bootstrapping libconf...~n", []),
    rebar_utils:sh("./bootstrap", []),
    ConfigureOpts = [ opt(Opt) ||
        {K, _}=Opt <- application:get_all_env(rebar_global),
        lists:prefix("libconf.", atom_to_list(K)) == true ],
    erlang:yield(),
    Cmd = "./configure " ++ string:join(ConfigureOpts, " "),
    rebar_utils:sh(Cmd, []),
    ok.

%% TODO: consider moving this into the libconf project

pre_generate(Config, RelConfig) ->
    %% NB: *this* function will run with any stock rebar (@'04/11/2011')

    DirName = filename:basename(rebar_utils:get_cwd()),

    %% because pre/post plugin command hooks *always* run, we have to filter
    %% out "unsuitable" directories ourselves - here based on the dirname
    case DirName of
        "release" ->
            rebar_log:log(debug, "pre_generate: ~p~n", [RelConfig]),
            Notice = "%% NB: this file is generated by our pre_release_plugin",
            GitVsn = case rebar_utils:sh("git describe --abbrev=0",
                                         [return_on_error]) of
                {ok, Vsn} ->
                    string:strip(Vsn, right, $\n);
                _ ->
                    %% a sensible default prior to any tags existing...
                    "0.0.1"
            end,

            {ok, Bin} = file:read_file(in_rel_dir("reltool.config.template")),
            Output = rebar_templater:render(Bin,
                            dict:from_list([{notice, Notice}, {git_vsn, GitVsn}])),

            %% the return value of file:write_file/3 will instruct rebar_core as
            %% to whether or not we've succeeded in this operation....
            Result = file:write_file("reltool.config", Output, [write]),
            rebar_log:log(info, "Release config (reltool.config) generated? ~p~n",
                                [Result]),
            Result;
        _ ->
            rebar_log:log(debug, "Skipping pre_generate in ~s~n", [DirName]),
            ok
    end.

post_generate(Config, _) ->
    %% NB: *this* function will run with any stock rebar (@'04/11/2011')
    DirName = filename:basename(rebar_utils:get_cwd()),
    case DirName of
        "release" ->
            %% because ejabberd is packaged in just about the most awkward
            %% way imaginable when it comes to embedding it within a release,
            %% their app file is out of sync with the actual modules (on disk)
            %% and therefore need to be rewritten.
            %%
            %% This is highly specific to the version of ejabberd we're using
            %% and DOES NOT represent a good solution to this problem - they
            %% SHOULD fix their application resource file!
            %%
            %% An alternative approach to this problem, is to have the release
            %% load code using 'interactive' mode, but that isn't supported 
            %% as part of this build (although it is easy to do)
            fix_ejd_appfile();
        _ ->
            ok
    end.

clean(Config, _) ->
    %% NB: *this* function needs a custom rebar binary, which is built using
    %%      the ./configure script generated by libconf
    case lists:member(generate, rebar_utils:command_info(remaining)) of
        true ->
            %% we *do not* want to clean, because the two interactions with
            %% the same file (reltool.config) can lead to the `generate' command
            %% failing to run sometimes.
            ok;
        false ->
            %% we *could* do this by adding the path to the rebar.config clean_files
            %% element, but IMHO it's better to keep this config in the same place as
            %% the code that creates the file from its template(s)
            [ file:delete(F) || F <- [ "reltool.config", "release.vars" ] ]
    end,
    ok.

fix_ejd_appfile() ->
    [Target] = rebar_utils:find_files(rebar_utils:get_cwd(), "ejabberd\\.app$"),
    Ebin = filename:dirname(Target),
    code:add_patha(Ebin),
    ok = application:load(ejabberd),
    {ok, AppConfig} = application:get_all_key(ejabberd),
    Beams = rebar_utils:find_files(Ebin, ".*\\.beam$"),
    ModNames = sets:from_list([ 
                list_to_atom(filename:basename(Beam, ".beam")) || 
                    Beam <- Beams ]),
    rebar_log:log(debug, "Mods with locatable beams: ~p~n", [ModNames]),
    {modules, Orig} = lists:keyfind(modules, 1, AppConfig),
    ListedMods = sets:from_list(Orig),
    rebar_log:log(debug, "Original Mods: ~p~n", [Orig]),
    Modules = sets:to_list(sets:intersection(ListedMods, ModNames)),
    NewConfig = lists:keyreplace(modules, 1, AppConfig, 
                                    {modules, lists:sort(Modules)}),
    rebar_log:log(debug, "New Config: ~p~n", [NewConfig]),
    file:write_file(Target, pprint(NewConfig), [write]).

pprint(Term) ->
    erl_prettypr:format(erl_parse:abstract(Term)) ++ ".".

opt({K, "true"}) ->
    re:replace(atom_to_list(K), "libconf\.", "--",
                     [{return, list}]);
opt({K, V}) ->
    Opt = re:replace(atom_to_list(K), "libconf\.", "--with-",
                     [{return, list}]),
    Opt ++ "=" ++ V.

in_rel_dir(Path) ->
    filename:join([base_dir(), "release", Path]).

base_dir() ->
    rebar_config:get_global(base_dir, undefined).
