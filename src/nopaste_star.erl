-module(nopaste_star).
-export([add/2]).
-include("user.hrl").
-include("post.hrl").
-include("star.hrl").

add(Post, User) ->
    ok = nopaste_db:add_star(Post, User).
