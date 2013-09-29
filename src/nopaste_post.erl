-module(isucon3_post).
-export([expand/1]).
-export([head/1]).
-include("include/post.hrl").
-include("include/user.hrl").
-include_lib("eunit/include/eunit.hrl").

exportable_fields() ->
    [id, content, created_at].

get_field(id,           #post{id = Id})                -> Id;
get_field(content,      #post{content = Content})      -> Content;
get_field(created_at,   #post{created_at = CreatedAt}) -> CreatedAt.

to_string(GregorianSeconds) ->
    {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:gregorian_seconds_to_datetime(GregorianSeconds),
    lists:flatten(io_lib:format("~4w-~2.2.0w-~2.2.0w ~2.2.0w:~2.2.0w:~2.2.0w",
                                [Year, Month, Day, Hour, Minute, Second])).
headline(Bin) ->
    Bin2 = binary:part(Bin, {0, lists:min([byte_size(Bin), 50])}),
    L = unicode:characters_to_list(Bin2, utf8),
    L2 = lists:sublist(L, 30),
    list_to_binary(L2).

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
    Headline = headline(Post#post.content),
    Params3 = lists:keystore(headline, 1, Params2, {headline, Headline}),
    Stars = isucon3_db:count_star(Post),
    [{username, username(Post)} | [{stars, Stars} | Params3]].

head(Count) ->
    isucon3_db:head(Count, post).
