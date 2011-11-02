%% stored in base_dir as all the other plugins are pre-loaded into
%% lib/remote_plugin_loader/src automatically but this one is project-local
-module(pre_release_plugin).
-export([clean/2]).
-export([preprocess/2]).
-export([configure/2]).
-export([pre_generate/2, post_generate/2]).

configure(Config, _) ->
    rebar_log:log(debug, "configure!~n", []).

preprocess(Config, _) ->
    case rebar_utils:command_info(current) of
        generate ->
            rebar_core:skip_dir(base_dir());
        _ ->
            ok
    end,
    {ok, []}.

pre_generate(Config, RelConfig) ->
    rebar_log:log(debug, "pre_generate: ~p~n", [RelConfig]),
    Notice = "%% NB: this file is generated by our pre_release_plugin",
    GitVsn = case rebar_utils:sh("git describe --abbrev=0", 
                                 [return_on_error]) of
        {error, _} ->
            %% a sensible default prior to any tags existing...
            "0.0.1";
        {ok, Vsn} ->
            string:strip(Vsn, right, $\n)
    end,

    {ok, Bin} = file:read_file(in_base_dir("reltool.config.template")),
    Output = rebar_templater:render(Bin, 
                    dict:from_list([{notice, Notice}, {git_vsn, GitVsn}])),

    %% the return value of file:write_file/3 will instruct rebar_core as
    %% to whether or not we've succeeded in this operation....
    Result = file:write_file("reltool.config", Output, [write]),
    rebar_log:log(info, "Release config (reltool.config) generated? ~p~n", 
                        [Result]),
    Result.

post_generate(Config, RelConfig) ->
    rebar_log:log(debug, "post_generate: ~p~n", [RelConfig]),
    ok.

clean(Config, _) ->
    case lists:member(generate, rebar_utils:command_info(remaining)) of
        true ->
            %% we *do not* want to clean, because the two interaction with
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

in_base_dir(Path) ->
    filename:join(base_dir(), Path).

base_dir() ->
    rebar_config:get_global(base_dir, undefined).
