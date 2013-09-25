-module(isucon3_post).
-export([expand/1]).
-include("include/post.hrl").
-include("include/user.hrl").
-include_lib("eunit/include/eunit.hrl").

exportable_fields() ->
    [id, content, created_at].

get_field(id,           #post{id = Id})                -> Id;
get_field(content,      #post{content = Content})      -> Content;
get_field(created_at,   #post{created_at = CreatedAt}) -> CreatedAt.

to_string(Now) ->
    {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:now_to_local_time(Now),
    lists:flatten(io_lib:format("~4w-~2.2.0w-~2.2.0w ~2.2.0w:~2.2.0w:~2.2.0w",
                                [Year, Month, Day, Hour, Minute, Second])).

username_from([]) ->
    "undefined";
username_from([#user{username = Username}]) ->
    Username.

username(#post{user_id = UserId}) ->
    Users = isucon3_db:q(dirty_read, [user, UserId]),
    ?debugVal(Users),
    username_from(Users).

expand(undefined) ->
    [];
expand(Post) when is_record(Post, post) ->
    Params = [{F, get_field(F, Post)} || F <- exportable_fields()],
    CreatedAt = proplists:get_value(created_at, Params),
    Params2 = lists:keystore(created_at, 1, Params, {created_at, to_string(CreatedAt)}),
    Stars = isucon3_db:count_star(Post),
    [{username, username(Post)} | [{stars, Stars} | Params2]].
