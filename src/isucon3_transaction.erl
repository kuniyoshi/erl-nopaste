-module(isucon3_transaction).
-export([add_user/1]).
-export([add_session/1]).
-export([delete_session/1]).
-export([add_post/1]).
-export([add_star/2]).
-export([head/2]).
-include("include/user.hrl").
-include("include/session.hrl").
-include("include/autoincrement.hrl").
-include("include/post.hrl").
-include("include/star.hrl").
-include_lib("stdlib/include/qlc.hrl").

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

delete_session(SessionId) ->
    fun() ->
            ok = mnesia:delete({session, SessionId})
    end.

add_post(Post) when is_record(Post, post) ->
    fun() ->
            Id = mnesia:dirty_update_counter(autoincrement, post, 1),
            Post2 = Post#post{id = Id},
            ok = mnesia:write(Post2)
    end.

add_star(#post{id = PostId}, #user{id = UserId}) ->
    fun() ->
            Id = mnesia:dirty_update_counter(autoincrement, star, 1),
            Star = #star{id = Id, user_id = UserId, post_id = PostId},
            ok = mnesia:write(Star)
    end.

head(Count, post) ->
    fun() ->
            Q1 = qlc:q([X || X <- mnesia:table(post)]),
            Q2 = qlc:keysort(#post.created_at, Q1),
            C = qlc:cursor(Q2),
            L = qlc:next_answers(C, Count),
            qlc:delete_cursor(C),
            L
    end.
