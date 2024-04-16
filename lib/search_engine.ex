defmodule SearchEngine do
  import FileHandling
  import Serialization

  def main(_) do
    Enum.each(IO.stream(), fn line ->
      line
      |> String.downcase
      |> String.split
      |> search
    end)
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
    |> Enum.to_list()
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
end
