-module(isucon3_session).
-export([gen_anonymous_cookie/0]).
-export([id_to_cookie/1]).
-export([signin/2]).
-include("user.hrl").
-include("session.hrl").
-define(MAX_RANDOM_NUMBER, 10000000000000000).
-include_lib("eunit/include/eunit.hrl").

gen_id() ->
    Rand = crypto:rand_uniform(0, ?MAX_RANDOM_NUMBER),
    Hash = crypto:hash(sha256, integer_to_binary(Rand)),
    Id = lists:flatten([io_lib:format("~2.16.0B", [X]) || X <- binary_to_list(Hash)]),
    list_to_binary(string:to_lower(Id)).

id_to_cookie(Id) ->
    Cookie = cowboy_http:cookie_to_iodata(isucon3_config:cookie(),
                                          Id,
                                          [{path, <<"/">>}]),
    Cookie.

gen_anonymous_cookie() ->
    id_to_cookie(gen_id()).

get_lifetime() ->
    calendar:datetime_to_gregorian_seconds(erlang:localtime()) + isucon3_config:lifetime().

set_cookie(Req, Id) ->
    ?debugVal(Id),
    Req2 = cowboy_req:set_resp_cookie(isucon3_config:cookie(),
                                      Id,
                                      [{path, <<"/">>}],
                                      Req),
    Req2.

signin(#user{id = UserId}, Req) ->
    SessionId = gen_id(),
    LivesUntil = get_lifetime(),
    isucon3_db:add_session(#session{id = SessionId,
                                    user_id = UserId,
                                    lives_until = LivesUntil}),
    set_cookie(Req, SessionId).

%% has_been_expired(#session{lives_until=LivesUntil}) ->
%%     LivesUntil < calendar:datetime_to_gregorian_seconds(calendar:local_time()).
%% 
%% restore_cookie(Req) ->
%%     Req,
%%     todo.
%% 
%% %% cowboy handler function.
%% execute(Req, Env) ->
%%     io:format("~p:execute/2~n", [?MODULE]),
%%     {Cookie, Req2} = cowboy_req:cookie(isucon3_config:cookie(), Req),
%%     io:format("Cookie: ~p~n", [Cookie]),
%%     case Cookie of
%%         undefined ->
%%             {Id, Req3} = set_cookie(Req2),
%%             Session = #session{id=Id, user_id=anonymous},
%%             Env2 = lists:keystore(session, 1, Env, {session, Session}),
%%             {ok, Req3, Env2};
%%         Val ->
%%             _Session = mnesia:dirty_read(session, Val),
%%             {ok, Req2, Env}
%%     end.
