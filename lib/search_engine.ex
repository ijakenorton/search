defmodule SearchEngine do
  import FileHandling
  import Serialization
  @file_name "wsj"
  def main(_) do
    input =
      IO.read(:stdio, :all)
      |> String.split(" ")
      |> Enum.map(&String.downcase/1)
      |> Enum.map(&String.trim/1)

    # setup()
    # Indexer.index()

    # index =
    #   File.read!(make_file_input_string("serialized"))
    #   |> Serialization.deserialize_postings()

    # IO.inspect(index, label: "index")

    # IO.inspect(:array.get(0, index))
    search(input)
  end

  def get_posting(word, dict, lengths, file_pid) do
    index = Map.get(dict, word)
    {offset, length} = :array.get(index, lengths)

    {:ok, posting} =
      FileReader.read_specific_offset(file_pid, offset, length)

    posting
    |> Serialization.deserialize_posting()
  end

  def get_common_keys(maps) do
    key_sets = Enum.map(maps, &MapSet.new(Map.keys(&1)))
    common_keys = Enum.reduce(key_sets, &MapSet.intersection/2)
    MapSet.to_list(common_keys)
  end

  def filter_maps_with_common_keys(maps) do
    common_keys = get_common_keys(maps)

    common_keys
    |> Enum.map(fn key ->
      {key,
       Enum.reduce(maps, 0, fn map, acc ->
         acc + Map.get(map, key, 0)
       end)}
    end)
    |> Enum.into(%{})
  end

  def print_sorted_by_score(map, ids) do
    map
    # Convert the map to a list of {key, value} tuples
    |> Enum.to_list()
    # Sort by value in descending order
    |> Enum.sort_by(&elem(&1, 1), &>=/2)
    |> Enum.each(fn {key, value} ->
      {id, _length} = :array.get(key, ids)
      IO.puts("WSJ#{id} #{value}")
    end)
  end

  def search(terms) do
    dict = deserialize_from_file(make_file_input_string("dict_serial"))

    lengths = deserialize_from_file(make_file_input_string("lengths"))
    ids = deserialize_ids(File.read!(make_file_input_string("ids")))

    {:ok, file_pid} = File.open(make_file_input_string("serialized"), [:binary])

    postings =
      terms
      |> Enum.map(&get_posting(&1, dict, lengths, file_pid))

    File.close(file_pid)

    filtered_maps = filter_maps_with_common_keys(postings)
    print_sorted_by_score(filtered_maps, ids)
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
