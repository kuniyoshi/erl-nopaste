-module(isucon3_config).
-export([get/1]).
-export([cookie/0,
         port/0,
         child/0,
         max_post_size/0,
         hostname/0]).

get(Key) -> apply(?MODULE, Key, []).

cookie()        -> <<"isucon3">>.
port()          -> 8080.
child()         -> 100.
max_post_size() -> 65536.
hostname()      -> <<"localhost">>.
