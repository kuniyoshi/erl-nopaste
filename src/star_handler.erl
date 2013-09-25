-module(star_handler).
-export([init/3]).
-export([handle_validate/2]).
-export([handle_post/3]).
-export([terminate/3]).
-include("include/user.hrl").
-include("include/post.hrl").
-include("include/star.hrl").
-include_lib("eunit/include/eunit.hrl").

init(_Transport, Req, State) ->
    ?debugVal(State),
    {ok, Req, State}.

handle_validate(Req, State) ->
    ?debugMsg(handle_validate),
    {PostId, Req2} = cowboy_req:binding(post_id, Req),
    ?debugVal(PostId),
    Posts = isucon3_db:q(dirty_read, [post, binary_to_integer(PostId)]),
    {Req2, State, Posts}.

handle_post(Req, State, []) ->
    {ok, Req2} = cowboy_req:reply(404, [], <<>>, Req),
    {ok, Req2, State};
handle_post(Req, State, [Post]) when is_record(Post, post) ->
    ?debugMsg("handle_post"),
    ?debugVal(Post),
    User = proplists:get_value(user, State),
    ?debugVal(User),
    ok = isucon3_star:increment(Post, User),
    {ok, Req2} = cowboy_req:reply(302,
                                  [{<<"location">>,
                                    isucon3_url:url_for(list_to_binary(io_lib:format("/post/~w", [Post#post.id])))}],
                                  [],
                                  Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
