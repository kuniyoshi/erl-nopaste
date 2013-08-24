-module(isucon3_session).
-export([gen_id/0]).
-export([restore_cookie/1]).
-include("session.hrl").
-define(MAX_RANDOM_NUMBER, 10000000000).

gen_id() ->
    random:uniform(?MAX_RANDOM_NUMBER).

restore_cookie(Req) ->
    Req,
    todo.
