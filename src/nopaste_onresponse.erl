-module(nopaste_onresponse).
-export([chain/4]).

chain(Code, Headers, Body, Req) ->
    server_status_client:done_with(Code),
    nopaste_acsrf:protect(Code, Headers, Body, Req).
