-module(isucon3_url).
-export([url_for/1]).

url_for(Path) when is_binary(Path) ->
    SchemeHost = [<<"http://">>,
                  isucon3_config:get(hostname),
                  <<":">>,
                  integer_to_binary(isucon3_config:get(port))],
    <<SchemeHost/binary, Path/binary>>.
