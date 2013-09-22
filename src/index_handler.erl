-module(index_handler).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
-include("include/user.hrl").
-include_lib("eunit/include/eunit.hrl").

init(_Transport, Req, State) ->
    ?debugVal(State),
    {ok, Req, State}.

handle(Req, State) ->
    User = proplists:get_value(user, State),
    ?debugVal(User),
    UserPorpList = isucon3_user:expand(User),
    ?debugVal(UserPorpList),
    {ok, Body} = index_dtl:render(UserPorpList),
    ?debugMsg(ok),
    {ok, Req2} = cowboy_req:reply(200, [], Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
