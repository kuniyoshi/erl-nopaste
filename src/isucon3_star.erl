-module(isucon3_star).
-export([increment/2]).
-include("user.hrl").
-include("post.hrl").
-include("star.hrl").

increment(#post{id = PostId}, #user{id = UserId}) ->
    ok = isucon3_db:q(dirty_write, [#star{user_id = UserId, post_id = PostId}]).
