-module(signup_handler).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
-include("include/user.hrl").

init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {Method, Req2} = cowboy_req:method(Req),
    case Method of
        <<"GET">> ->
            handle_get(Req2, State);
        <<"POST">> ->
            Errors = get_errors(Req2),
            handle_post(Req2, State, Errors)
    end.

handle_get(Req, State) ->
    io:format("singup_handler:handle_get~n", []),
    {ok, Body} = signup_dtl:render([]),
    Req2 = cowboy_req:set_resp_body(Body, Req),
    {ok, Req2, State}.

get_errors(Req) ->
    {ok, Qs, _Req2} = cowboy_req:body_qs(isucon3_config:get(max_post_size), Req),
    Username = binary_to_list(proplists:get_value(<<"username">>, Qs)),
    Password = binary_to_list(proplists:get_value(<<"password">>, Qs)),
    PasswordConfirm = binary_to_list(proplists:get_value(<<"password_confirm">>, Qs)),
    User = #user{username=Username, password=Password},
    Errors = isucon3_user:get_errors(User),
    Error  = isucon3_user:get_password_confirm_error(Password, PasswordConfirm),
    Errors2 = Error ++ Errors,
    Keys = lists:usort([K || {K, _V} <- Errors2]),
    Errors3 = [{K, [V || {Key, V} <- Errors2, Key == K]} || K <- Keys],
    Errors3.

handle_post(Req, State, []) ->
    SessionId = integer_to_list(isucon3_session:gen_id()),
    Req2 = cowboy_req:set_resp_cookie(isucon3_config:get(cookie),
                                      SessionId,
                                      [{path, <<"/">>}],
                                      Req),
    {ok, Req3} = cowboy_req:reply(302,
                                  [{<<"location">>, isucon3_url:url_for(<<"/">>)}],
                                  [],
                                  Req2),
    {ok, Req3, State};
handle_post(Req, State, Errors) ->
    {ok, Q, Req2} = cowboy_req:body_qs(isucon3_config:get(max_post_size), Req),
    Q2 = [{errors, Errors}|Q],
    {ok, Body} = signup_dtl:render(Q2),
    {ok, Req3} = cowboy_req:reply(200, [], Body, Req2),
    {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
    ok.
