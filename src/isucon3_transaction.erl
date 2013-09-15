-module(isucon3_transaction).
-export([add_user/1]).
-export([add_session/1]).
-include("include/user.hrl").
-include("include/session.hrl").
-include("include/autoincrement.hrl").

add_user(User) when is_record(User, user) ->
    fun() ->
            Id = mnesia:dirty_update_counter(autoincrement, user, 1),
            User2 = User#user{id = Id},
            ok = mnesia:write(User2),
            User2
    end.

add_session(Session) when is_record(Session, session) ->
    fun() ->
            ok = mnesia:write(Session)
    end.
