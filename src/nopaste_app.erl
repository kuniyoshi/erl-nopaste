-module(nopaste_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_Type, _Args) ->
    pong = net_adm:ping(nopaste_config:db_node()),
    ok = log_funnel_client:open(nopaste_config:access_log()),
    Dispatch = cowboy_router:compile([{'_',
                                       [{"/static/[...]",
                                         cowboy_static,
                                         [{directory, {priv_dir, nopaste, []}},
                                          {mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
                                        {"/signin", nopaste_handler, [signin_handler, []]},
                                        {"/signup", nopaste_handler, [signup_handler, []]},
                                        {"/signout", nopaste_handler, [signout_handler, []]},
                                        {"/", nopaste_handler, [index_handler, []]},
                                        {"/post", nopaste_handler, [post_handler, []]},
                                        {"/post/:post_id", nopaste_handler, [post_handler, []]},
                                        {"/star/:post_id", nopaste_handler, [star_handler, []]},
                                        {"/index.html", nopaste_handler, [index_handler, []]}]}]),
    {ok, _} = cowboy:start_http(http,
                                nopaste_config:child(),
                                [{port, nopaste_config:port()}],
                                [{env, [{dispatch, Dispatch}]},
                                 {middlewares, [cowboy_router, cowboy_handler, nopaste_access_log]},
                                 {onrequest, fun nopaste_onrequest:chain/1},
                                 {onresponse, fun nopaste_onresponse:chain/4}]),
    nopaste_sup:start_link().

stop(_State) ->
    ok.
