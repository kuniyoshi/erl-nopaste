-module(signin_handler).
-export([init/3]).
-export([handle_validate/2, handle_post/3, handle/2]).
-export([terminate/3]).

init(_Transport, Req, State) ->
    {ok, Req, State}.

handle_validate(Req, State) ->
    {ok, Qs, _Req2} = cowboy_req:body_qs(isucon3_config:max_post_size(), Req),
    User = isucon3_user:new_from_query_string(Qs),
    {Req, [{user, User} | State], isucon3_user:can_signin(User)}.

handle_post(Req, State, true) ->
    User = proplists:get_value(user, State),
    Req2 = isucon3_session:signin(User, Req),
    {ok, Req3} = cowboy_req:reply(302,
                                  [{<<"location">>, isucon3_url:url_for(<<"/">>)}],
                                  [],
                                  Req2),
    {ok, Req3, State};
handle_post(Req, State, false) ->
    {ok, Q, Req2} = cowboy_req:body_qs(isucon3_config:max_post_size(), Req),
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
