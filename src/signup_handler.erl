-module(signup_handler).
-export([init/3]).
-export([handle_validate/2, handle_post/3, handle/2]).
-export([terminate/3]).
-include("include/user.hrl").
-include_lib("eunit/include/eunit.hrl").

init(_Transport, Req, State) ->
    {ok, Req, State}.

handle_validate(Req, State) ->
    ?debugVal(State),
    {ok, Qs, _Req2} = cowboy_req:body_qs(nopaste_config:max_post_size(), Req),
    ?debugVal(Qs),
    User = nopaste_user:new_from_query_string(Qs),
    PasswordConfirm = binary_to_list(proplists:get_value(<<"password_confirm">>, Qs)),
    ?debugVal(PasswordConfirm),
    Errors = nopaste_user:get_errors(User, PasswordConfirm),
    ?debugVal(Errors),
    {Req, [{user, User} | State], Errors}.

handle_post(Req, State, []) ->
    User = proplists:get_value(user, State),
    User2 = nopaste_user:add_user(User),
    Req2 = nopaste_session:signin(User2, Req),
    {ok, Req3} = cowboy_req:reply(302,
                                  [{<<"location">>, nopaste_url:url_for(<<"/">>)}],
                                  [],
                                  Req2),
    {ok, Req3, State};
handle_post(Req, State, Errors) ->
    {ok, Q, Req2} = cowboy_req:body_qs(nopaste_config:max_post_size(), Req),
    Q2 = [{errors, Errors} | Q],
    {ok, Body} = signup_dtl:render(Q2),
    {ok, Req3} = cowboy_req:reply(200, [], Body, Req2),
    {ok, Req3, State}.

handle(Req, State) ->
    {ok, Body} = signup_dtl:render([]),
    {ok, Req2} = cowboy_req:reply(200, [], Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
