PROJECT = isucon3

DEPS = cowboy mimetypes erlydtl server_status log_funnel
dep_cowboy = pkg://cowboy master
dep_mimetypes = git://github.com/kuniyoshi/mimetypes for_relx
dep_erlydtl = pkg://erlydtl master
dep_server_status = git://github.com/kuniyoshi/erl-server-status master
dep_log_funnel = git://github.com/kuniyoshi/erl-log_funnel master

.PHONY: release clean-release

release: clean-release all
	relx

clean-release:
	rm -rf _rel

include erlang.mk
