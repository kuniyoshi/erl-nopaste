-module(isucon3_handler).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
-include_lib("eunit/include/eunit.hrl").

init(Transport, Req, [Module, [] = Args]) ->
    {Method, Req2} = cowboy_req:method(Req),
    Args2 = [{module, Module}, {method, Method}],
    Args3 = lists:keymerge(1, Args, Args2),
    ?debugVal(Args3),
    Module:init(Transport, Req2, Args3).

handle(Req, Args) ->
    {value, {method, Method}} = lists:keysearch(method, 1, Args),
    {value, {module, Module}} = lists:keysearch(module, 1, Args),
    handle(Req, Args, Method, Module).

handle(Req, Args, <<"POST">>, Module) ->
    ?debugVal(Module),
    PostFunName = handle_post,
    ValidateFunName = handle_validate,
    case erlang:function_exported(Module, ValidateFunName, 2) of
        true ->
            {Req, Args2, Errors} = Module:ValidateFunName(Req, Args),
            ?debugVal(Errors),
            Module:PostFunName(Req, Args2, Errors);
        false ->
            handle(Req, Args, <<"PSEUDO-POST">>, Module)
    end;
handle(Req, Args, _Method, Module) ->
    Module:handle(Req, Args).

terminate(Reason, Req, Args) ->
    {value, {module, Module}} = lists:keysearch(module, 1, Args),
    Module:terminate(Reason, Req, Args).
