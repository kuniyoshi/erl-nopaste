-module(isucon3_session).
-export([gen_anonymous_cookie/0]).
-export([id_to_cookie/1]).
-export([signin/2]).
-export([get_session/1]).
-export([expire/1]).
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
    calendar:datetime_to_gregorian_seconds(calendar:local_time()) + isucon3_config:lifetime().

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

sanitize_session([]) ->
    undefined;
sanitize_session([#session{lives_until = LivesUntil} = Session]) ->
    case LivesUntil > calendar:datetime_to_gregorian_seconds(calendar:local_time()) of
        true ->
            Session;
        false ->
            sanitize_session([])
    end.

get_session(Req) ->
    {Cookie, _Req2} = cowboy_req:cookie(isucon3_config:cookie(), Req),
    ?debugVal(Cookie),
    sanitize_session(isucon3_db:q(dirty_read, [session, Cookie])).

expire(Req) ->
    {Cookie, _Req} = cowboy_req:cookie(isucon3_config:cookie(), Req),
    ?debugVal(Cookie),
    isucon3_db:delete_session(Cookie).
