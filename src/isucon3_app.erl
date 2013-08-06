-module(isucon3_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
                                      {'_', [
                                             {"/static/[...]", cowboy_static, [
                                                                        {directory, {priv_dir, isucon3, []}},
                                                                        {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                                                                       ]}
                                            ]}
                                     ]),
    {ok, _} = cowboy:start_http(http, 100, [{port, 8080}], [
                                                            {env, [{dispatch, Dispatch}]}
                                                           ]),
    isucon3_sup:start_link().

stop(_State) ->
    ok.
