-module(signout_handler).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
-include_lib("eunit/include/eunit.hrl").

init(_Transport, Req, State) ->
    {ok, Req, State}.

handle(Req, State) ->
    ok = isucon3_session:expire(Req),
    {ok, Req2} = cowboy_req:reply(302,
                                  [{<<"location">>, isucon3_url:url_for(<<"/">>)}],
                                  [],
                                  Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
