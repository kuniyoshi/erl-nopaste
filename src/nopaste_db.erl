-module(nopaste_db).
-export([q/2]).
-export([add_user/1]).
-export([add_session/1]).
-export([delete_session/1]).
-export([add_post/1]).
-export([count_star/1]).
-export([add_star/2]).
-export([head/2]).
-include("include/user.hrl").
-include("include/session.hrl").
-include("include/autoincrement.hrl").
-include("include/post.hrl").
-include("include/star.hrl").
-include_lib("eunit/include/eunit.hrl").

q(FunName, Args) ->
    rpc:call(nopaste_config:db_node(), mnesia, FunName, Args).

add_user(User) when is_record(User, user) ->
    Transaction = nopaste_transaction:add_user(User),
    User2 = q(activity, [transaction, Transaction]),
    User2.

add_session(Session) when is_record(Session, session) ->
    Transaction = nopaste_transaction:add_session(Session),
    ok = q(activity, [transaction, Transaction]).

delete_session(SessionId) ->
    io:format("SessionId:\t~p~n", [SessionId]),
    Transaction = nopaste_transaction:delete_session(SessionId),
    ok = q(activity, [transaction, Transaction]).

add_post(Post) when is_record(Post, post) ->
    Transaction = nopaste_transaction:add_post(Post),
    ok = q(activity, [transaction, Transaction]).

count_star(Post) when is_record(Post, post) ->
    Stars = q(dirty_index_read, [star, Post#post.id, #star.post_id]),
    length(Stars).

add_star(Post, User) when is_record(Post, post), is_record(User, user) ->
    Transaction = nopaste_transaction:add_star(Post, User),
    ok = q(activity, [transaction, Transaction]).

head(Count, post) ->
    Transaction = nopaste_transaction:head(Count, post),
    Posts = q(activity, [transaction, Transaction]),
    Posts.
