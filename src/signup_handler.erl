-module(signup_handler).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
-include("include/user.hrl").
-include_lib("eunit/include/eunit.hrl").

init(_Transport, Req, []) ->
    {Method, Req2} = cowboy_req:method(Req),
    {ok, Req2, [{method, Method}]}.

handle(Req, [{method, <<"POST">>}] = State) ->
    ?debugVal(State),
    {ok, Qs, _Req2} = cowboy_req:body_qs(isucon3_config:max_post_size(), Req),
    ?debugVal(Qs),
    User = isucon3_user:new_from_query_string(Qs),
    PasswordConfirm = binary_to_list(proplists:get_value(<<"password_confirm">>, Qs)),
    ?debugVal(PasswordConfirm),
    Errors = isucon3_user:get_errors(User, PasswordConfirm),
    ?debugVal(Errors),
    handle_post(Req, [{user, User} | State], Errors);
handle(Req, State) ->
    {ok, Body} = signup_dtl:render([]),
    {ok, Req2} = cowboy_req:reply(200, [], Body, Req),
    {ok, Req2, State}.

handle_post(Req, State, []) ->
    User = proplists:get_value(user, State),
    User2 = isucon3_user:add_user(User),
    Req2 = isucon3_session:signin(User2, Req),
    {ok, Req3} = cowboy_req:reply(302,
                                  [{<<"location">>, isucon3_url:url_for(<<"/">>)}],
                                  [],
                                  Req2),
    {ok, Req3, State};
handle_post(Req, State, Errors) ->
    {ok, Q, Req2} = cowboy_req:body_qs(isucon3_config:max_post_size(), Req),
    Q2 = [{errors, Errors} | Q],
    {ok, Body} = signup_dtl:render(Q2),
    {ok, Req3} = cowboy_req:reply(200, [], Body, Req2),
    {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
    ok.
