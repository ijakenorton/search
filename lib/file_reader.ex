defmodule FileReader do
  def read_specific_offset(file_pid, offset, length) do
    :file.position(file_pid, offset)
    data = IO.binread(file_pid, length)

    {:ok, data}
  end
end
