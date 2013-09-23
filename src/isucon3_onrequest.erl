-module(isucon3_onrequest).
-export([chain/1]).

chain(Req) ->
    Req2 = isucon3_state:working(Req),
    Req3 = isucon3_acsrf:protect(Req2),
    Req3.


