-module(acsrf).
-export([encrypt/1]).
-export([hide/2]).
-define(ACSRF_KEY, <<"q3cqFqRD2EVVGpYmDa_gbwxz">>).
-define(ACSRF_NAME, atom_to_binary(?MODULE, utf8)).

encrypt(Data) ->
    encrypt(Data, ?ACSRF_KEY).

encrypt(Data, Key) ->
    base64:encode(crypto:hmac(sha256, Key, Data)).

hide(Html, Key) ->
%    io:format("key: ~p~n", [Key]),
    Encrypted = encrypt(Key),
%    io:format("encrypted: ~p~n", [Encrypted]),
%    io:format("name: ~p~n", [?ACSRF_NAME]),
    re:replace(Html,
               <<"[<]/form[>]">>,
               [<<"<input type=\"hidden\" name=\"">>,
                ?ACSRF_NAME,
                <<"\" value=\"">>,
                Encrypted,
                <<"\"</form>">>],
               [global]).
