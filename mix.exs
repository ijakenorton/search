defmodule SearchEngine.MixProject do
  use Mix.Project

  def project do
    [
      app: :search_engine,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript_config()
    ]
  end

  def application do
    [
      # mod: {SearchEngine, []},
      extra_applications: [:logger, :observer]
    ]
  end

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

  defp deps do
    [
      {:flow, "~> 1.2"}
    ]
  end
end
