-module(isucon3_config).
-export([get/1]).
-define(CONFIG, [{cookie, <<"isucon3">>},
                 {port, 8080},
                 {child, 100},
                 {max_post_size, 65536},
                 {hostname, <<"localhost">>}]).

get(Key) ->
    {Key, Value} = lists:keyfind(Key, 1, ?CONFIG),
    Value.
