-module(isucon3_acsrf).
-export([respond/4]).

respond(_Code, _Headers, Body, Req) ->
%    io:format("on response!!!!!!!!~n", []),
    {Cookie, Req2} = cowboy_req:cookie(isucon3_config:get(cookie), Req),
%    io:format("Cookie: ~p~n", [Cookie]),
    case Cookie of
        undefined ->
            Req2 = cowboy_req:set_resp_cookie(isucon3_config:get(cookie),
                                              integer_to_list(isucon3_session:gen_id())),
            Req2;
        Val ->
            Body2 = acsrf:hide(Body, Val),
            Req2 = cowboy_req:set_resp_body(Body2, Req2),
            Req2
    end.
