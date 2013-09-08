-module(isucon3_reply).
-export([execute/2]).

execute(Req, Env) ->
    case cowboy_req:get(resp_state, Req) of
        waiting ->
            {ok, Req2} = cowboy_req:reply(200, Req),
            {ok, Req2, Env};
        done ->
            {ok, Req, Env}
    end.
