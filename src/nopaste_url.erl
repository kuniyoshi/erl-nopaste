-module(nopaste_url).
-export([url_for/1]).

%% TODO: Need escape.
url_for(Path) when is_binary(Path) ->
    Scheme = <<"http">>,
    Sep1 = <<"://">>,
    Host = nopaste_config:hostname(),
    Sep2 = <<":">>,
    Port = integer_to_binary(nopaste_config:port()),
    <<Scheme/binary, Sep1/binary, Host/binary, Sep2/binary, Port/binary, Path/binary>>.
