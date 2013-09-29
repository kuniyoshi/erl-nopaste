-module(isucon3_state).
-export([working/1]).

working(Req) ->
    {Path, _Req} = cowboy_req:path(Req),
    {Qs, _Req} = cowboy_req:qs(Req),
    server_status_client:working([{path, Path}, {query_string, Qs}]),
    Req.
