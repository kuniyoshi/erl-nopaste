-module(nopaste_config).
-export([get/1]).
-export([cookie/0,
         port/0,
         child/0,
         max_post_size/0,
         hostname/0,
         db_node/0,
         lifetime/0,
         access_log/0]).

get(Key) -> apply(?MODULE, Key, []).

cookie()        -> <<"nopaste">>.
port()          -> 8080.
child()         -> 100.
max_post_size() -> 65536.
hostname()      -> <<"localhost">>.
db_node()       -> 'db@127.0.0.1'.
lifetime()      -> 3 * 24 * 60 * 60.
access_log()    -> "/tmp/access.log".
