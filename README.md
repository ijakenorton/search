# SearchEngine

Small search engine to fetch documents in xml format

## Installation

I have only run on ubuntu based linux, mileage may vary on other systems

If a erlang and or elixir runtime is required, run the install script below if on ubuntu/apt based distros,  
mise is a package manager which is useful for installing erlang/elixir, I am using
```
elixir  1.16.2-otp-26  ~/.config/mise/config.toml latest   
erlang  26.2.3         ~/.config/mise/config.toml latest   
```
```
`./install.sh`
sudo apt-get -y install curl build-essential autoconf libncurses5-dev libssh-dev 
 curl https://mise.run | sh
 ~/.local/bin/mise use --global erlang@latest
 ~/.local/bin/mise use --global elixir@latest
```

After runtime has been installed, restart or source shell
```
source ~/.zshrc
source ~/.bashrc
```

First time compilation requires some dependency Installation which can be installed using `./first_compile.sh`
```
mix local.hex --force
mix deps.get
```

## Compilation

Compilation of the binaries is done through make using the mix.exs file. There are three different binaries compiled 

- `./bin/parser` Parse the xml files, currently hard coded to wsj, not included in the repo, entry point is `./lib/parser_main.ex`
- `./bin/indexer`Indexes the parsed files to an inverted index, the index is ranked using TFIDF. Entry point is `./lib/indexer_main.ex`
- `./bin/search_engine` Searches the documents and outputs all matches. The query is input using stdin, space delimited words, these 
are then ANDED and outputs through stdout

`make all` Removed previous binaries and compiles all three binaries
`make parser` Compiles parser to `./bin/parser`
`make indexer` Compiles indexer to `./bin/indexer`
`make search_engine` Compiles search_engine to `./bin/search_engine`

These are compiled with the elixir runtime built in. 

## To Run

To run simple run the executable
Default will parse file `./wsj.xml` otherwise pass the file path to ./bin/parser as the first cmdline arg
 `./bin/parser`

 `./bin/indexer`
For the search_engine an example run would be
```
./bin/search_engine < query
```
### Escript build 

If you want to change the escript build step it is located here `./mix.exs`
```elixir

  defp escript_config do
    {main_module, name} =
      case System.get_env("MAIN_MODULE") do
        "parser" -> {ParserMain, "parser"}
        "indexer" -> {IndexerMain, "indexer"}
        "search_engine" -> {SearchEngine, "search_engine"}
        _ -> {SearchEngine, "search_engine"}
      end

    [
      main_module: main_module,
      start_permanent: :prod,
      path: "./bin/#{name}",
      strip_beams: true,
      emu_args: ["+a", "8192", "+ssrct", "+hms", "8192"],
      embed_elixir: true
    ]
  end
```
### Dependency

Uses `{:flow, "~> 1.2"}` for concurrent processing [Flow documentation]{https://hexdocs.pm/flow/Flow.html}
