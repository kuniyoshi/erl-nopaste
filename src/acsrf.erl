-module(acsrf).
-export([encrypt/1, encrypt/2]).
-export([hide/2, hide/3]).
-define(ACSRF_KEY, <<"q3cqFqRD2EVVGpYmDa_gbwxz">>).
-define(ACSRF_NAME, atom_to_binary(?MODULE, utf8)).

encrypt(Data) ->
    encrypt(Data, ?ACSRF_KEY).

encrypt(Data, Key) ->
    base64:encode(crypto:hmac(sha256, Key, Data)).

protection_tag(AcsrfName, Encrypted) ->
    OpenTag = <<"<input type=\"hidden\" name=\"">>,
    Attribute = <<"\" value=\"">>,
    CloseTag = <<"\"></form>">>,
    <<OpenTag/binary, AcsrfName/binary, Attribute/binary, Encrypted/binary, CloseTag/binary>>.

hide(Html, Key) ->
    hide(Html, Key, []).

hide(Html, Key, Options) ->
    Options2 = lists:keymerge(1, Options, [{acsrf_key, ?ACSRF_KEY}, {acsrf_name, ?ACSRF_NAME}]),
    {acsrf_key, AcsrfKey} = lists:keyfind(acsrf_key, 1, Options2),
    {acsrf_name, AcsrfName} = lists:keyfind(acsrf_name, 1, Options2),
    Encrypted = ?MODULE:encrypt(Key, AcsrfKey),
    Replaced = protection_tag(AcsrfName, Encrypted),
    Html2 = binary:replace(Html, <<"</form>">>, Replaced, [global]),
    Html2.
