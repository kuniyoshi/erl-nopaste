-module(isucon3_validator).
-export([isnt_empty/1]).

isnt_empty([]) ->
    false;
isnt_empty(_) ->
    true.
