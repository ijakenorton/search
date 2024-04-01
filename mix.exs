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
    [
      main_module: SearchEngine,
      start_permanent: Mix.env() == :prod,
      # emu_args: ["+S"],
      embed_elixir: true
    ]
  end

  defp deps do
    [
      {:flow, "~> 1.2"}
    ]
  end
end
