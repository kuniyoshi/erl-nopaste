-module(form_validator).
-export([not_null/1, semi_ascii/1, ascii/1, is_same/2]).

not_null([])        -> false;
not_null(undefined) -> false;
not_null(<<>>)      -> false;
not_null(_Name)     -> true.

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

is_same(_Val, _Val) ->
    true;
is_same(_Val1, _Val2) ->
    false.
