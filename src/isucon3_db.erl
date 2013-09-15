-module(isucon3_db).
-export([q/2]).
-export([add_user/1]).
-export([add_session/1]).
-include("include/user.hrl").
-include("include/session.hrl").
-include("include/autoincrement.hrl").
-include_lib("eunit/include/eunit.hrl").

q(FunName, Args) ->
    rpc:call(isucon3_config:db_node(), mnesia, FunName, Args).

add_user(User) when is_record(User, user) ->
    Transaction = isucon3_transaction:add_user(User),
    User2 = q(activity, [transaction, Transaction]),
    User2.

add_session(Session) when is_record(Session, session) ->
    Transaction = isucon3_transaction:add_session(Session),
    ok = q(activity, [transaction, Transaction]).
