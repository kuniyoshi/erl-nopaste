-module(nopaste_onrequest).
-export([chain/1]).
-include_lib("eunit/include/eunit.hrl").

chain(Req) ->
    ?debugMsg("nopaste_onrequest:chain/1"),
    ?debugVal(cowboy_req:path(Req)),
    Req2 = nopaste_state:working(Req),
    Req3 = nopaste_acsrf:protect(Req2),
    Req3.
