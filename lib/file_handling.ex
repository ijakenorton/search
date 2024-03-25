defmodule FileHandling do
  def serialize_to_file(data, file_path) do
    binary_data = :erlang.term_to_binary(data)
    File.write!(file_path, binary_data)
  end

  def deserialize_from_file(file_path) do
    {:ok, binary_data} = File.read(file_path)
    :erlang.binary_to_term(binary_data)
  end
end
