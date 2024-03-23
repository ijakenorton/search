defmodule Parser do
  @docno_regex ~r/<DOCNO>\s*([^<]*)/i
  @doc_regex ~r/<\/DOC>/
  @token_regex ~r/[^a-zA-Z]+/
  @line_regex ~r/(<\/DOC>)|(<DOCNO>)|([a-zA-Z\-09]+)/

  def parse() do
    file = "wsj"
    content = File.read!("./input/#{file}.xml")
    lines = String.split(content, "\n", trim: true)

    result =
      lines
      |> Flow.from_enumerable()
      |> Flow.map(&do_parse/1)
      |> Enum.to_list()
      |> Enum.reduce(%{docnos: [], words: []}, &accumulate_results/2)

    File.write!("./output/#{file}_docnos.out", Enum.reverse(result.docnos))
    File.write!("./output/#{file}_words.out", Enum.reverse(result.words))
    IO.inspect(length(result.docnos))
  end

  defp do_parse(content) do
    cond do
      Regex.match?(@docno_regex, content) ->
        case Regex.run(@docno_regex, content, capture: :all_but_first, dotall: true) do
          [docno] -> {:docno, [docno]}
          _ -> nil
        end

      Regex.match?(@doc_regex, content) ->
        {:words, [""]}

      true ->
        words =
          content
          |> String.split(@token_regex, trim: true, include_captures: false)
          |> Enum.reject(&(&1 in ["", "DOC", "HL", "DD", "SO", "IN", "DATELINE", "TEXT"]))
          |> Enum.map(&String.downcase/1)

        if Enum.empty?(words), do: nil, else: {:words, words}
    end
  end

  defp accumulate_results(nil, acc), do: acc

  defp accumulate_results({:docno, docno}, %{docnos: docnos, words: words} = acc) do
    updated_docnos = [docno, "\n" | docnos]
    %{acc | docnos: updated_docnos}
  end

  defp accumulate_results({:words, words_new}, %{docnos: docnos, words: words} = acc) do
    updated_words = Enum.reduce(words_new, words, fn word, acc -> [word, "\n" | acc] end)
    %{acc | words: updated_words}
  end
end
