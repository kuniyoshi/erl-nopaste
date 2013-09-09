-module(isucon3_acsrf).
-export([protect/4]).
-include("user.hrl").
-include_lib("eunit/include/eunit.hrl").

protect(200 = Code, Headers, Body, Req) ->
    {Cookie, Req2} = cowboy_req:cookie(isucon3_config:cookie(), Req),
    ?debugVal(Cookie),
    case Cookie of
        undefined ->
            Req3 = isucon3_session:set_cookie(Req2),
            Req3;
        Val ->
            io:format("NO MORE UNDEFINED~n", []),
            ?debugVal(is_binary(Val)),
            Key = Val,
            Body2 = acsrf:hide(Body, Key),
            Headers2 = lists:keyreplace(<<"content-length">>,
                                        1,
                                        Headers,
                                        {<<"content-length">>,
                                         integer_to_list(iolist_size(Body2))}),
            {ok, Req3} = cowboy_req:reply(Code, Headers2, Body2, Req2),
            Req3
    end;
protect(_Code, _Headers, _Body, Req) ->
    Req.
