-module(isucon3_acsrf).
-export([protect/1, protect/4]).
-include("user.hrl").
-include_lib("eunit/include/eunit.hrl").

protect(Req) ->
    {Method, Req2} = cowboy_req:method(Req),
    protect_from(Method, Req2).

protect_from(<<"POST">>, Req) ->
    {Cookie, Req2} = cowboy_req:cookie(isucon3_config:cookie(), Req),
    case Cookie of
        undefined ->
            {ok, Req3} = cowboy_req:reply(403, Req2),
            Req3;
        Val ->
            {ok, Qs, _Req} = cowboy_req:body_qs(isucon3_config:max_post_size(), Req2),
            Challenge = proplists:get_value(acsrf:default_name(), Qs),
            ?debugVal(Challenge),
            Expected = acsrf:encrypt(Val),
            ?debugVal(Expected),
            case Challenge of
                Expected ->
                    io:format("!!! Excepted~n"),
                    ?debugVal(Req2),
                    Req2;
                _ ->
                    io:format("!!! Not match~n"),
                    {ok, Req3} = cowboy_req:reply(403, Req2),
                    Req3
            end
    end;
protect_from(_Method, Req) ->
    Req.

protect(_Code, _Headers, <<>>, Req) ->
    Req;
protect(200 = Code, Headers, Body, Req) ->
    {Cookie, Req2} = cowboy_req:cookie(isucon3_config:cookie(), Req),
    ?debugVal(Cookie),
    case Cookie of
        undefined ->
            Cookie2 = isucon3_session:gen_anonymous_cookie(),
            Headers2 = lists:keystore(<<"set-cookie">>,
                                      1,
                                      Headers,
                                      {<<"set-cookie">>, Cookie2}),
            {ok, Req3} = cowboy_req:reply(Code, Headers2, Body, Req2),
            Req3;
        Val ->
            Key = Val,
            ?debugVal(Key),
            Body2 = acsrf:hide(Body, Key),
            ?debugVal(Body2),
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
