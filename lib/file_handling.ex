defmodule FileHandling do
  @file_name "wsj"
  def make_file_input_string(type) do
    "./output/#{file_name()}_#{type}.out"
  end

  def file_name, do: @file_name
end
