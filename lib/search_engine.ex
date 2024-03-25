defmodule SearchEngine do
  @file_name "wsj"
  def start(_type, _args) do
    # :observer.start()
    # Parser.parse()
    # Parser.make_dictionary()

    Indexer.parse()
    # Indexer.run()
    # IO.inspect(deserialize_from_file("./output/#{@file_name}_binary.out"))

    Supervisor.start_link([], strategy: :one_for_one)
  end

  def file_name, do: @file_name

  def deserialize_from_file(file_path) do
    {:ok, binary_data} = File.read(file_path)
    :erlang.binary_to_term(binary_data)
  end
end
