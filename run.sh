#!/bin/zsh
local input="$(< /dev/stdin)"
mix compile && mix escript.build && echo $input | time ./search_engine
