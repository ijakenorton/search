defmodule ParserMain do
  def main(_) do
    parsed = Parser.parse()

    {:ok, parsed_fd} = File.open("./output/#{SearchEngine.file_name()}_parsed.out", [:write])

    parsed
    |> Enum.each(fn
      {id, words} ->
        IO.write(parsed_fd, "#{id}\n#{Enum.join(words, "\n")}\n\n")
        words
    end)
  end
end
