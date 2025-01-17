defmodule Serialization do
  @doc_bit_length 24
  @frequency_bit_length 32
  def deserialize_posting(posting) do
    do_deserialize_posting(
      posting,
      %{}
    )
  end

  defp do_deserialize_posting(<<>>, map), do: map

  defp do_deserialize_posting(
         <<doc_index::@doc_bit_length, frequency::float-@frequency_bit_length, rest::bitstring>>,
         map
       ) do
    map = Map.put(map, doc_index, frequency)
    do_deserialize_posting(rest, map)
  end

  def serialize_posting(posting) do
    Enum.reduce(posting, {[], 0}, fn {doc_index, frequency}, {acc, length} ->
      {
        [
          acc,
          [
            <<doc_index::@doc_bit_length, frequency::float-@frequency_bit_length>>
          ]
        ],
        length + trunc((@doc_bit_length + @frequency_bit_length) / 8)
      }
    end)
  end

  def serialize_ids(ids_and_lengths) do
    Enum.reduce(ids_and_lengths, <<>>, fn {id, number}, acc ->
      <<acc::bitstring, id::88-bitstring, number::14>>
    end)
  end

  def deserialize_ids(data) do
    do_deserialize_ids(data, 0, :array.new(floor(bit_size(data) / 102)))
  end

  defp do_deserialize_ids(<<>>, _index, array), do: array

  defp do_deserialize_ids(<<id::88-bitstring, number::14, rest::bitstring>>, index, array) do
    combined = {id, number}
    do_deserialize_ids(rest, index + 1, :array.set(index, combined, array))
  end

  def serialize_to_file(data, file_path) do
    binary_data = :erlang.term_to_binary(data)
    File.write!(file_path, binary_data)
  end

  def deserialize_from_file(file_path) do
    file = File.read(file_path)
    {:ok, binary_data} = file
    :erlang.binary_to_term(binary_data)
  end
end
