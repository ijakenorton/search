defmodule FileReader do
  def read_specific_offset(file_path, offset, length) do
    # Open the file in binary mode to handle bytes
    with {:ok, file} <- File.open(file_path, [:binary]),
         # Position the file cursor at the desired offset
         {:ok, _} <- :file.position(file, offset) do
      # Read the specified number of bytes from the current position
      data = IO.binread(file, length)
      IO.inspect(data, label: "data")

      # Always good practice to close the file when you're done
      File.close(file)

      # Return the read data
      {:ok, data}
    else
      # Handle errors, such as file not found
      error -> error
    end
  end
end
