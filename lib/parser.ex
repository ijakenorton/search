defmodule Parser do
  @docno_regex ~r/<DOCNO>(.*?)<\/DOCNO>/
  @doc_regex ~r/<\/DOC>/
  @token_regex ~r/[^a-zA-Z]+/

  def parse() do
    content = File.read!("../wsj.xml")

    lines = String.split(content, "\n", trim: true)
    {:ok, words_file} = File.open("./wsj.out", [:write])
    {:ok, docnos_file} = File.open("./docnos.out", [:write])

    out =
      lines
      |> Flow.from_enumerable()
      |> Flow.map(&Parser.do_parse/1)
      |> Enum.to_list()

    Enum.each(out, fn
      [docno: docno_value] when docno_value != [] ->
        IO.puts(docnos_file, docno_value)

      element when element != [] ->
        Enum.each(element, fn word ->
          word = if word == "\n", do: "", else: word
          IO.puts(words_file, word)
        end)

      _ ->
        nil
    end)

    File.close(words_file)
    File.close(docnos_file)
    out
  end

  # def extract_docnos(data) do
  #   Enum.reduce(data, [], fn
  #     [docno: docno_value], acc -> acc ++ docno_value
  #     _, acc -> acc
  #   end)
  # end

  def do_parse(content) do
    cond do
      Regex.match?(@docno_regex, content) ->
        [docno: Regex.run(@docno_regex, content, capture: :all_but_first, dotall: true)]

      Regex.match?(@doc_regex, content) ->
        ["\n"]

      true ->
        content
        |> String.split(@token_regex, trim: true, include_captures: false)
        |> Enum.reduce([], fn word, acc ->
          case word do
            "DOC" -> acc
            "HL" -> acc
            "DD" -> acc
            "SO" -> acc
            "IN" -> acc
            "DATELINE" -> acc
            "TEXT" -> acc
            "" -> acc
            [] -> acc
            _ -> [String.downcase(word) | acc]
          end
        end)
        |> Enum.reverse()
    end
  end
end
