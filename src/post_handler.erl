-module(post_handler).
-export([init/3]).
-export([handle_validate/2]).
-export([handle_post/3]).
-export([handle/2]).
-export([terminate/3]).
-include("include/user.hrl").
-include("include/post.hrl").
-include_lib("eunit/include/eunit.hrl").

init(_Transport, Req, State) ->
    ?debugVal(State),
    {ok, Req, State}.

handle_validate(Req, State) ->
    ?debugMsg(handle_validate),
    {ok, Qs, _Req} = cowboy_req:body_qs(Req),
    Content = proplists:get_value(<<"content">>, Qs, <<>>),
    NotNull = form_validator:not_null(Content),
    ?debugVal(NotNull),
    {Req, [{body_qs, [{content, Content}]} | State], NotNull}.

handle_post(Req, State, false) ->
    User = proplists:get_value(user, State),
    UserPorpList = nopaste_user:expand(User),
    Params = [{errors, [not_null]} | UserPorpList],
    ?debugVal(Params),
    {ok, Body} = index_dtl:render(Params),
    {ok, Req2} = cowboy_req:reply(200, [], Body, Req),
    {ok, Req2, State};
handle_post(Req, State, true) ->
    ?debugMsg("handle_post"),
    User = proplists:get_value(user, State),
    ?debugVal(User),
    BodyQs = proplists:get_value(body_qs, State),
    ?debugVal(BodyQs),
    Content = proplists:get_value(content, BodyQs),
    ?debugVal(Content),
    GregorianSeconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
    Post = #post{user_id = User#user.id, content = Content, created_at = GregorianSeconds},
    ok = nopaste_db:add_post(Post),
    {ok, Req2} = cowboy_req:reply(302,
                                  [{<<"location">>, nopaste_url:url_for(<<"/">>)}],
                                  [],
                                  Req),
    {ok, Req2, State}.

handle(Req, State) ->
    ?debugMsg("GET /post"),
    User = proplists:get_value(user, State, undefined),
    UserParams = nopaste_user:expand(User),
    {PostId, Req2} = cowboy_req:binding(post_id, Req, 0),
    ?debugVal(PostId),
    Posts = nopaste_db:q(dirty_read, [post, binary_to_integer(PostId)]),
    handle_get(Req2, State, UserParams, Posts).

handle_get(Req, State, _UserParams, []) ->
    {ok, Req2} = cowboy_req:reply(404, [], <<>>, Req),
    {ok, Req2, State};
handle_get(Req, State, UserParams, [Post]) ->
    ?debugVal(Post),
    PostParams = nopaste_post:expand(Post),
    ?debugVal(UserParams),
    ?debugVal(PostParams),
    {ok, Body} = post_dtl:render([{user, UserParams}, {post, PostParams}]),
    {ok, Req2} = cowboy_req:reply(200, [], Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
