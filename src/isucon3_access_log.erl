-module(isucon3_access_log).
-behaviour(cowboy_middleware).
-export([execute/2]).
-include_lib("eunit/include/eunit.hrl").

to_string(undefined, _Atom) ->
    "undefined";
to_string(Ip, ip_address) ->
    ?debugVal(Ip),
    string:join([integer_to_list(X) || X <- tuple_to_list(Ip)], ".");
to_string(Now, started_at) ->
    {Ymd, Hms} = calendar:now_to_local_time(Now),
    string:join([string:join([integer_to_list(X) || X <- tuple_to_list(Ymd)], "-"),
                 string:join([integer_to_list(X) || X <- tuple_to_list(Hms)], ":")], " ").

format_access_log(Req) ->
    Pid = self(),
    {{Ip, _Port}, _Req} = cowboy_req:peer(Req),
    State = server_status_client:my_state(),
    StartedAt = server_status_client:started_at(State),
    ?debugVal(StartedAt),
    {Method, _Req} = cowboy_req:method(Req),
    {Path, _Req} = cowboy_req:path(Req),
    {Qs, _Req} = cowboy_req:qs(Req),
    Qs2 = case Qs of
        <<>> ->
            <<>>;
        _ ->
            Question = <<"?">>,
            <<Question/binary, Qs/binary>>
    end,
    {Version, _Req} = cowboy_req:version(Req),
    Code = server_status_client:code(State),
    %% It is hard to get transfered bytes, skip this.
    {Referrer, _Req} = cowboy_req:header(<<"referer">>, Req, <<"undefined">>),
    {Agent, _Req} = cowboy_req:header(<<"user-agent">>, Req, <<"undefined">>),
    Us = server_status_client:wall_clock_us(State),
    ?debugVal(Path),
    ?debugVal(Qs),
    ?debugVal(<<Path/binary, Qs/binary>>),
    string:join([pid_to_list(Pid),
                 to_string(Ip, ip_address),
                 to_string(StartedAt, started_at),
                 binary_to_list(Method),
                 binary_to_list(<<Path/binary, Qs2/binary>>),
                 atom_to_list(Version),
                 integer_to_list(Code),
                 binary_to_list(Referrer),
                 binary_to_list(Agent),
                 integer_to_list(Us)], [$\t]).

execute(Req, Env) ->
    server_status_client:done(),
    Log = format_access_log(Req),
    log_funnel_client:append(Log),
    {ok, Req, Env}.
