-module(isucon3_transaction).
-export([add_user/1]).
-export([add_session/1]).
-export([add_post/1]).
-include("include/user.hrl").
-include("include/session.hrl").
-include("include/autoincrement.hrl").
-include("include/post.hrl").

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

add_post(Post) when is_record(Post, post) ->
    fun() ->
            Id = mnesia:dirty_update_counter(autoincrement, post, 1),
            Post2 = Post#post{id = Id},
            ok = mnesia:write(Post2)
    end.
