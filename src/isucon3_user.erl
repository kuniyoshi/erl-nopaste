-module(isucon3_user).
-export([no_duplicate/1]).
-export([get_errors/2]).
-export([new_from_query_string/1]).
-export([add_user/1]).
-export([get_from_query/1]).
-export([can_signin/2]).
-export([get_user/1]).
-export([expand/1]).
-include("include/user.hrl").
-include("include/session.hrl").
-include_lib("eunit/include/eunit.hrl").
-define(PKEY, <<"zErsG3DoWVBW1jBhZ0VzaY5dzuwvSgPx">>).

get_field(id,       #user{id = Ret})        -> Ret;
get_field(username, #user{username = Ret})  -> Ret;
get_field(password, #user{password = Ret})  -> Ret.

no_duplicate(undefined) ->
    true;
no_duplicate(Name) ->
    case isucon3_db:q(dirty_index_read, [user, Name, username]) of
        [] ->
            true;
        [_] ->
            false
    end.

get_error_acc(_U, [], E) ->
    E;
get_error_acc(U, [Q | T], E) ->
    {Field, TestName, Test} = Q,
    FieldValue = get_field(Field, U),
    ?debugVal({Field, FieldValue, TestName, Test}),
    case Test(FieldValue) of
        true ->
            get_error_acc(U, T, E);
        false ->
            get_error_acc(U, T, [{Field, TestName} | E])
    end.

get_errors(U) when is_record(U, user) ->
    get_error_acc(U,
                  [{username, not_null, fun form_validator:not_null/1},
                   {username, semi_ascii, fun form_validator:semi_ascii/1},
                   {password, ascii, fun form_validator:ascii/1},
                   {username, no_duplicate, fun ?MODULE:no_duplicate/1}],
                  []).

get_password_confirm_error(V1, V2) ->
    case form_validator:is_same(V1, V2) of
        true ->
            [];
        false ->
            [{password, is_same}]
    end.

get_errors(User, PasswordConfirm) ->
    Errors = get_errors(User),
    ?debugVal(Errors),
    Error  = get_password_confirm_error(User#user.password, PasswordConfirm),
    ?debugVal(Error),
    Errors2 = Error ++ Errors,
    Keys = lists:usort([K || {K, _V} <- Errors2]),
    Errors3 = [{K, [V || {Key, V} <- Errors2, Key == K]} || K <- Keys],
    Errors3.

new_from_query_string(Qs) ->
    Username = binary_to_list(proplists:get_value(<<"username">>, Qs)),
    ?debugVal(Username),
    Password = binary_to_list(proplists:get_value(<<"password">>, Qs)),
    ?debugVal(Password),
    User = #user{username = Username, password = Password},
    User.

hmac(Data) ->
    crypto:hmac(sha256, ?PKEY, Data).

add_user(User) when is_record(User, user) ->
    User2 = User#user{password = hmac(User#user.password)},
    User3 = isucon3_db:add_user(User2),
    User3.

get_from_query(#user{username = Username}) ->
    case isucon3_db:q(dirty_index_read, [user, Username, username]) of
        [] ->
            undefined;
        [#user{} = User] ->
            User
    end.

can_signin(undefined, _Query) ->
    false;
can_signin(Db, Query) when is_record(Db, user) andalso is_record(Query, user) ->
    ?debugVal(Db),
    ?debugVal(Query),
    hmac(Query#user.password) =:= Db#user.password.

sanitize_user([]) ->
    undefined;
sanitize_user([User]) when is_record(User, user) ->
    User.

get_user(undefined) ->
    undefined;
get_user(#session{user_id = UserId}) ->
    sanitize_user(isucon3_db:q(dirty_read, [user, UserId])).

expand(undefined) ->
    [];
expand(User) when is_record(User, user) ->
    [{username, User#user.username}].
