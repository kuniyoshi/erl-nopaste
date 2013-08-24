.SUFFIXES:.erl .beam
.erl.beam:
	rebar compile
all: src/*.erl
