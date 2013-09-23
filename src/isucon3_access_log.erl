-module(isucon3_access_log).
-behaviour(cowboy_middleware).
-export([execute/2]).

execute(Req, Env) ->
    server_status_client:done(),
    {ok, Req, Env}.
