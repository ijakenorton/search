defmodule SearchEngine do
  import FileHandling
  import Serialization

  def main(_) do
    dict = deserialize_from_file(make_file_input_string("dict_serial"))
    lengths = deserialize_from_file(make_file_input_string("lengths"))
    ids = deserialize_ids(File.read!(make_file_input_string("ids")))
    {:ok, file_pid} = File.open(make_file_input_string("serialized"), [:binary])

    Enum.each(IO.stream(), fn line ->
      line =
        line
        |> String.downcase()
        |> String.split()

      IO.inspect(line)

      line
      |> search(dict, lengths, ids, file_pid)
    end)

    File.close(file_pid)
  end

  def get_posting(index, lengths, file_pid) do
    {offset, length} = :array.get(index, lengths)
    IO.inspect(index, label: "index")
    IO.inspect(offset, label: "offset")
    IO.inspect(length, label: "length")

    # {:ok, posting} =
    posting = FileReader.read_specific_offset(file_pid, offset, length)
    IO.inspect(posting)

    {:ok, posting} = posting

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

  def search(terms, dict, lengths, ids, file_pid) do
    case terms do
      [] ->
        nil

      nil ->
        nil

      _ ->
        indexs =
          terms
          |> Enum.map(&Map.get(dict, &1))
          |> Enum.filter(fn x -> x != nil end)

        case indexs do
          [] ->
            nil

          _ ->
            postings =
              indexs
              |> Enum.map(&get_posting(&1, lengths, file_pid))

            filter_maps_with_common_keys(postings)
            |> print_sorted_by_score(ids)
        end
    end
  end
end
