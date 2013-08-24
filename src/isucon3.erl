-module(isucon3).
-export([start/0]).
-include("include/user.hrl").

start() ->
    ok = erlydtl:compile("templates/base.dtl", base_dtl),
    ok = erlydtl:compile("templates/sidebar.dtl", sidebar_dtl),
    ok = erlydtl:compile("templates/index.dtl", index_dtl),
    ok = erlydtl:compile("templates/signin.dtl", signin_dtl),
    ok = erlydtl:compile("templates/signup.dtl", signup_dtl),
    ok = application:start(mnesia),
    ok = application:start(crypto),
    ok = application:start(ranch),
    ok = application:start(cowboy),
    ok = application:start(isucon3).
