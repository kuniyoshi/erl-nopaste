-module(signin_handler).
-export([init/3]).
-export([handle_validate/2, handle_post/3, handle/2]).
-export([terminate/3]).
-include_lib("eunit/include/eunit.hrl").

init(_Transport, Req, State) ->
    {ok, Req, State}.

handle_validate(Req, State) ->
    {ok, Qs, _Req2} = cowboy_req:body_qs(nopaste_config:max_post_size(), Req),
    User = nopaste_user:new_from_query_string(Qs),
    User2 = nopaste_user:get_from_query(User),
    ?debugVal(User),
    ?debugVal(User2),
    {Req, [{user, User2} | State], nopaste_user:can_signin(User2, User)}.

handle_post(Req, State, true) ->
    User = proplists:get_value(user, State),
    Req2 = nopaste_session:signin(User, Req),
    {ok, Req3} = cowboy_req:reply(302,
                                  [{<<"location">>, nopaste_url:url_for(<<"/">>)}],
                                  [],
                                  Req2),
    {ok, Req3, State};
handle_post(Req, State, false) ->
    {ok, Q, Req2} = cowboy_req:body_qs(nopaste_config:max_post_size(), Req),
    Q2 = [{login_error, incorrect} | Q],
    {ok, Body} = signin_dtl:render(Q2),
    {ok, Req3} = cowboy_req:reply(200, [], Body, Req2),
    {ok, Req3, State}.

handle(Req, State) ->
    {ok, Body} = signin_dtl:render([]),
    {ok, Req2} = cowboy_req:reply(200, [], Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
