defmodule FileHandling do
  def make_file_input_string(type) do
    "./output/#{SearchEngine.file_name()}_#{type}.out"
  end
end
