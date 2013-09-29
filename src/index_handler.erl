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
    RecentPosts = isucon3_post:head(10),
    ?debugVal(RecentPosts),
    RecentPosts2 = [isucon3_post:expand(X) || X <- RecentPosts],
    ?debugVal(RecentPosts2),
    {ok, Body} = index_dtl:render([{user, UserPorpList}, {recent_posts, RecentPosts2}]),
    ?debugMsg(ok),
    {ok, Req2} = cowboy_req:reply(200, [], Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
