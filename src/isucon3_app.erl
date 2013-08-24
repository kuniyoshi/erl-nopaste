-module(isucon3_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([{'_',
                                       [{"/static/[...]",
                                         cowboy_static,
                                         [{directory, {priv_dir, isucon3, []}},
                                          {mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
                                        {"/signin", signin_handler, []},
                                        {"/signup", signup_handler, []},
                                        {"/", index_handler, []},
                                        {"/index.html", index_handler, []}]}]),
    {ok, _} = cowboy:start_http(http,
                                isucon3_config:get(child),
                                [{port, isucon3_config:get(port)}],
                                [{env, [{dispatch, Dispatch}]},
                                 {onresponse, fun isucon3_acsrf:respond/4}]),
    isucon3_sup:start_link().

stop(_State) ->
    ok = application:stop(mnesia),
    ok.
