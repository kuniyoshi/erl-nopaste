-record(post,
        {id :: integer(),
         user_id :: integer(),
         content :: binary(),
         created_at :: erlang:timestamp()}).
