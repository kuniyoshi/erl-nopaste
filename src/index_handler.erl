-module(index_handler).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
-include_lib("eunit/include/eunit.hrl").

init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {ok, Body} = index_dtl:render([]),
    {ok, Req2} = cowboy_req:reply(200, [], Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
