-module(isucon3_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_Type, _Args) ->
    pong = net_adm:ping(isucon3_config:db_node()),
    ok = log_funnel_client:open(isucon3_config:access_log()),
    Dispatch = cowboy_router:compile([{'_',
                                       [{"/static/[...]",
                                         cowboy_static,
                                         [{directory, {priv_dir, isucon3, []}},
                                          {mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
                                        {"/signin", isucon3_handler, [signin_handler, []]},
                                        {"/signup", isucon3_handler, [signup_handler, []]},
                                        {"/", isucon3_handler, [index_handler, []]},
                                        {"/index.html", isucon3_handler, [index_handler, []]}]}]),
    {ok, _} = cowboy:start_http(http,
                                isucon3_config:child(),
                                [{port, isucon3_config:port()}],
                                [{env, [{dispatch, Dispatch}]},
                                 {middlewares, [cowboy_router, cowboy_handler, isucon3_access_log]},
                                 {onrequest, fun isucon3_onrequest:chain/1},
                                 {onresponse, fun isucon3_onresponse:chain/4}]),
    isucon3_sup:start_link().

stop(_State) ->
    ok.
