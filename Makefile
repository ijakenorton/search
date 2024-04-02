.PHONY: all parser indexer search_engine clean

all: clean parser indexer search_engine

parser:
	MIX_ENV=prod MAIN_MODULE=parser mix escript.build

indexer:
	MIX_ENV=prod MAIN_MODULE=indexer mix escript.build

search_engine:
	MIX_ENV=prod MAIN_MODULE=search_engine mix escript.build

clean:
	rm -f ./bin/parser ./bin/indexer ./bin/search_engine
