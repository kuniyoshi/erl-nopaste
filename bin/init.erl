#!escript --
-include("../include/user.hrl").
-include("../include/session.hrl").

main([]) ->
    mnesia:create_schema([node()]),
    application:start(mnesia),
    mnesia:delete_table(user),
    mnesia:create_table(user,
                        [{attributes, record_info(fields, user)},
                         {disc_copies, [node()]}]),
    mnesia:create_table(session,
                        [{attributes, record_info(fields, session)}]),
    application:stop(mnesia).
