defmodule SearchEngine do
  import FileHandling
  import Serialization
  @file_name "wsj"
  def main(args) do
    input =
      IO.read(:stdio, :all)
      |> String.split(" ")
      |> Enum.map(&String.trim/1)

    # IO.inspect(args)
    setup()
    Indexer.index()

    # index =
    #   File.read!(make_file_input_string("serialized"))
    #   |> Serialization.deserialize_postings()

    # IO.inspect(index, label: "index")

    # IO.inspect(:array.get(0, index))
    # search(input)
  end

  def search(query) do
    dict = deserialize_from_file(make_file_input_string("dict_serial"))

    lengths = deserialize_from_file(make_file_input_string("lengths"))
    ids = deserialize_ids(File.read!(make_file_input_string("ids")))

    Enum.each(query, fn word ->
      index = Map.get(dict, word)
      {offset, length} = :array.get(index, lengths)

      {:ok, posting} =
        FileReader.read_specific_offset(make_file_input_string("serialized"), offset, length)

      posting =
        posting
        |> Serialization.deserialize_posting()

      Enum.each(0..(:array.size(posting) - 1), fn index ->
        {id, freq} = :array.get(index, posting)
        id = :array.get(id, ids)
        IO.inspect({id, freq})
      end)
    end)

    # IO.inspect(is_bitstring(posting))

    # IO.inspect(posting, label: "posting")k

    # query
    # |> String.split(" ")
    # |> Enum.map(&String.trim/1)
    # |> Enum.map(&String.downcase/1)
    # |> Enum.map(fn word -> Map.get(dict, word) end)
    # |> Enum.map(fn index -> :array.get(index, words) end)
    # |> IO.inspect()
  end

  def setup do
    documents = Parser.parse()

    ids_and_lengths =
      Enum.map(documents, fn {id, doc} ->
        {String.slice(id, 3, String.length(id)) |> String.trim(), length(doc)}
      end)

    Parser.write_parsed_and_dict_to_file(documents)
    Parser.write_ids(ids_and_lengths)
    content = File.read!("./output/#{SearchEngine.file_name()}_dictionary.out")

    words =
      String.split(content, "\n", trim: true)

    dict =
      words
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {element, index}, acc -> Map.put(acc, element, index) end)

    serialize_to_file(dict, make_file_input_string("dict_serial"))
  end

  def file_name, do: @file_name
end
