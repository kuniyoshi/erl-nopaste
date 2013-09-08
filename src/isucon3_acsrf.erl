-module(isucon3_acsrf).
-export([execute/2]).
-include("user.hrl").

execute(Req, Env) ->
    {Cookie, Req2} = cowboy_req:cookie(isucon3_config:get(cookie), Req),
    io:format("Cookie: ~p~n", [Cookie]),
    case Cookie of
        undefined ->
            Req3 = isucon3_session:set_cookie(Req2),
%            io:format("Req3: ~p~n", [Req3]),
            io:format("Env: ~p~n", [Env]),
            {ok, Req3, Env};
        Val ->
            io:format("NO MORE UNDEFINED~n", []),
            Key = Val,
            Body = cowboy_req:get(resp_body, Req),
            Body2 = acsrf:hide(Body, Key),
            Req3 = cowboy_req:set_resp_body(Body2, Req2),
            Req3
    end.
