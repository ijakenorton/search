defmodule SearchEngine do
  def start(_type, _args) do
    Parser.parse()

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
