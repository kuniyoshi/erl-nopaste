-module(isucon3_onresponse).
-export([chain/4]).

chain(Code, Headers, Body, Req) ->
    server_status_client:done_with(Code),
    isucon3_acsrf:protect(Code, Headers, Body, Req).
