-module(isucon3_string).
-export([hex_from_dec/1]).

hex_from_dec(Digit) when Digit >= 0 andalso Digit < 10 -> $0 + Digit;
hex_from_dec(Digits) when Digits >= 10 andalso Digits < 16 -> $a + Digits - 10.
