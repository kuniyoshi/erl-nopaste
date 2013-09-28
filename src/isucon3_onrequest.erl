-module(isucon3_onrequest).
-export([chain/1]).
-include_lib("eunit/include/eunit.hrl").

chain(Req) ->
    ?debugMsg("isucon3_onrequest:chain/1"),
    ?debugVal(cowboy_req:path(Req)),
    Req2 = isucon3_state:working(Req),
    Req3 = isucon3_acsrf:protect(Req2),
    Req3.
