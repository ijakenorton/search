defmodule ParserMain do
  def main(_) do
    Parser.parse()
    |> Enum.each(fn
      {id, words} ->
        IO.write("#{id}\n#{Enum.join(words, "\n")}\n\n")
        words
    end)
  end
end
