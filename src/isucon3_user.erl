-module(isucon3_user).
-export([get_field/2]).
-export([not_null/1, semi_ascii/1, ascii/1, no_duplicate/1, is_same/2]).
-export([get_password_confirm_error/2, get_errors/1]).

-include("include/user.hrl").

get_field(id, U) when is_record(U, user) ->
    U#user.id;
get_field(username, U) when is_record(U, user) ->
    U#user.username;
get_field(password, U) when is_record(U, user) ->
    U#user.password.

not_null([]) ->
    false;
not_null(undefined) ->
    false;
not_null(_Name) ->
    true.

semi_ascii(undefined) ->
    false;
semi_ascii(S) ->
    {ok, M} = re:compile("^[A-Za-z0-9]{2,20}$"),
    case re:run(S, M) of
        {match, _Place} ->
            true;
        nomatch ->
            false
    end.

ascii(undefined) ->
    false;
ascii(S) ->
    {ok, M} = re:compile("^[\x21-\x7E]{2,20}$"),
    case re:run(S, M) of
        {match, _Place} ->
            true;
        nomatch ->
            false
    end.

no_duplicate(undefined) ->
    true;
no_duplicate(Name) ->
    case mnesia:dirty_match_object(#user{id='_', username=Name, password='_'}) of
        [] ->
            true;
        [_] ->
            false
    end.

is_same(_Val, _Val) ->
    true;
is_same(_Val1, _Val2) ->
    false.

get_password_confirm_error(V1, V2) ->
    case is_same(V1, V2) of
        true ->
            [];
        false ->
            [{password, is_same}]
    end.

get_error_acc(_U, [], E) ->
    E;
get_error_acc(U, [Q|T], E) ->
    io:format("q: ~p~n", [Q]),
    {Field, Test} = Q,
    case apply(?MODULE, Test, [get_field(Field, U)]) of
        true ->
            io:format("true~n", []),
            get_error_acc(U, T, E);
        false ->
            io:format("true~n", []),
            get_error_acc(U, T, [{Field, Test}|E])
    end.

get_errors(U) when is_record(U, user) ->
    get_error_acc(U,
                  [{username, not_null},
                   {username, semi_ascii},
                   {password, ascii},
                   {username, no_duplicate}],
                  []).
