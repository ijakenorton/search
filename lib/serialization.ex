defmodule Serialization do
  @doc_bit_length 24
  @frequency_bit_length 32
  def deserialize_postings(data) do
    lengths = deserialize_from_file(FileHandling.make_file_input_string("lengths"))
    words = File.read!(FileHandling.make_file_input_string("dictionary")) |> String.split("\n")
    postings = :array.new(length(words))

    Enum.reduce(0..(:array.size(postings) - 1), postings, fn index, acc ->
      {offset, size} = :array.get(index, lengths)
      posting = :binary.part(data, offset, size)
      :array.set(index, deserialize_posting(posting), acc)
    end)
  end

  def deserialize_posting(posting) do
    do_deserialize_posting(
      posting,
      0,
      :array.new(floor(bit_size(posting) / (@doc_bit_length + @frequency_bit_length)))
    )
  end

  defp do_deserialize_posting(<<>>, _index, array), do: array

  defp do_deserialize_posting(
         <<doc_index::@doc_bit_length, frequency::float-@frequency_bit_length, rest::bitstring>>,
         index,
         array
       ) do
    combined = {doc_index, frequency}
    array = :array.set(index, combined, array)
    do_deserialize_posting(rest, index + 1, array)
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
    {:ok, binary_data} = File.read(file_path)
    :erlang.binary_to_term(binary_data)
  end
end
