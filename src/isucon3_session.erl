-module(isucon3_session).
-export([gen_id/0, get_id/0, set_cookie/1]).
-export([restore_cookie/1]).
-export([execute/2]).
-include("session.hrl").
-define(MAX_RANDOM_NUMBER, 10000000000000).

has_been_expired(#session{lives_until=LivesUntil}) ->
    LivesUntil < calendar:datetime_to_gregorian_seconds(calendar:local_time()).

gen_id() ->
    base64:encode(erlang:md5(integer_to_binary(random:uniform(?MAX_RANDOM_NUMBER)))).

get_id() ->
    Retries = 3,
    get_id(Retries).

get_id(Retries) when is_integer(Retries), Retries > 0 ->
    Id = gen_id(),
    case mnesia:dirty_read(session, Id) of
        [] ->
            Id;
        [Session] ->
            case has_been_expired(Session) of
                true ->
                    Id;
                false ->
                    get_id(Retries - 1)
            end;
        _ ->
            get_id(Retries - 1)
    end.

set_cookie(Req) ->
    Id = gen_id(),
    Req2 = cowboy_req:set_resp_cookie(isucon3_config:cookie(),
                                      Id,
                                      [{path, <<"/">>}],
                                      Req),
    Req2.

restore_cookie(Req) ->
    Req,
    todo.

%% cowboy handler function.
execute(Req, Env) ->
    io:format("~p:execute/2~n", [?MODULE]),
    {Cookie, Req2} = cowboy_req:cookie(isucon3_config:cookie(), Req),
    io:format("Cookie: ~p~n", [Cookie]),
    case Cookie of
        undefined ->
            {Id, Req3} = set_cookie(Req2),
            Session = #session{id=Id, user_id=anonymous},
            Env2 = lists:keystore(session, 1, Env, {session, Session}),
            {ok, Req3, Env2};
        Val ->
            _Session = mnesia:dirty_read(session, Val),
            {ok, Req2, Env}
    end.
