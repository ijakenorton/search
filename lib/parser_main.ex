defmodule ParserMain do
  def main(_) do
    input_file = get_input_file_path()

    Parser.parse(input_file)
    |> Enum.each(fn
      {id, words} ->
        IO.write("#{id}\n#{Enum.join(words, "\n")}\n\n")
        words
    end)
  end

  def get_input_file_path() do
    case System.argv() do
      [] ->
        "./input/#{FileHandling.file_name()}.xml"

      [file_path | _] ->
        file_path
    end
  end
end
