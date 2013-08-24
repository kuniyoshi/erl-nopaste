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
            io:format("getting errors~n", []),
            Errors = get_errors(Req2),
            io:format("errors: ~p~n", [Errors]),
            handle_post(Req2, State, Errors)
    end.

handle_get(Req, State) ->
    io:format("get~n", []),
    io:format("State: ~p~n", [State]),
    NewValue = integer_to_list(random:uniform(1000000)),
    Req2 = cowboy_req:set_resp_cookie(<<"server">>,
                                      NewValue,
                                      [{path, <<"/">>}],
                                      Req),
    {ClientCookie, Req3} = cowboy_req:cookie(<<"client">>, Req2),
    {ServerCookie, Req4} = cowboy_req:cookie(<<"server">>, Req3),
    io:format("client cookie: ~p~n", [ClientCookie]),
    io:format("server cookie: ~p~n", [ServerCookie]),
    {ok, Body} = signup_dtl:render([]),
    {ok, Req5} = cowboy_req:reply(200,
                                  [{<<"content-type">>, <<"text/html">>}],
                                  Body,
                                  Req4),
    {ok, Req5, State}.

get_errors(Req) ->
    io:format("get_errors~n", []),
    {ok, Qs, _Req2} = cowboy_req:body_qs(isucon3_config:get(max_post_size), Req),
    Username = binary_to_list(proplists:get_value(<<"username">>, Qs)),
    io:format("username: ~p~n", [Username]),
    Password = binary_to_list(proplists:get_value(<<"password">>, Qs)),
    io:format("password: ~p~n", [Password]),
    PasswordConfirm = binary_to_list(proplists:get_value(<<"password_confirm">>, Qs)),
    io:format("password confirm: ~p~n", [PasswordConfirm]),
    User = #user{username=Username, password=Password},
    io:format("user: ~p~n", [User]),
    Errors = isucon3_user:get_errors(User),
    io:format("errors: ~p~n", [Errors]),
    Error  = isucon3_user:get_password_confirm_error(Password, PasswordConfirm),
    io:format("error: ~p~n", [Error]),
    Errors2 = Error ++ Errors,
    io:format("errors2: ~p~n", [Errors2]),
    Keys = lists:usort([K || {K, _V} <- Errors2]),
    Errors3 = [{K, [V || {Key, V} <- Errors2, Key == K]} || K <- Keys],
    io:format("errors3: ~p~n", [Errors3]),
    Errors3.

handle_post(Req, State, []) ->
    io:format("handle_post with empty~n", []),
    SessionId = integer_to_list(isucon3_session:gen_id()),
    Req2 = cowboy_req:set_resp_cookie(isucon3_config:get(cookie),
                                      SessionId,
                                      [{path, <<"/">>}],
                                      Req),
    {ClientCookie, Req3} = cowboy_req:cookie(<<"client">>, Req2),
    {ServerCookie, Req4} = cowboy_req:cookie(<<"server">>, Req3),
    io:format("client cookie: ~p~n", [ClientCookie]),
    io:format("server cookie: ~p~n", [ServerCookie]),
    io:format("State: ~p~n", [State]),
    {ok, ReqRedirect} = cowboy_req:reply(302,
                                         [{<<"location">>, isucon3_url:url_for(<<"/">>)}],
                                         [],
                                         Req4),
    io:format("req redirect~n", []),
    {ok, ReqRedirect, State};
handle_post(Req, State, Errors) ->
    io:format("handle_post~n", []),
    io:format("State: ~p~n", [State]),
    io:format("errors: ~p~n", [Errors]),
    {ok, Q, Req2} = cowboy_req:body_qs(isucon3_config:get(max_post_size), Req),
    Q2 = [{errors, Errors}|Q],
    io:format("query: ~p~n", [Q2]),
    {ok, Body} = signup_dtl:render(Q2),
    {ok, Req3} = cowboy_req:reply(200,
                                  [],
                                  Body,
                                  Req2),
    {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
    ok.
