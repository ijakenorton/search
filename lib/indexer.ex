defmodule Indexer do
  @token_regex ~r/[^a-zA-Z]+/
  @docno_regex ~r/<DOCNO>\s*([^<]*)/i
  import FileHandling

  def parse() do
    documents =
      File.read!("./input/#{SearchEngine.file_name()}.xml")
      |> preprocess_docnos()
      |> String.split(~r/<\s*DOC\s*>/, trim: true)
      |> Flow.from_enumerable()
      |> Flow.map(&parse_doc/1)
      |> Enum.to_list()
      |> List.flatten()

    documents |> write_parsed_to_file()

    serialize_to_file(documents, "./output/#{SearchEngine.file_name()}_binary.out")
  end

  def write_parsed_to_file(documents) do
    IO.puts("writing to file....")
    {:ok, fd} = File.open("./output/#{SearchEngine.file_name()}_parsed.out", [:write])

    documents
    |> Enum.each(fn
      {id, words} ->
        IO.write(fd, "#{id}\n#{Enum.join(words, "\n")}\n\n")
    end)

    File.close(fd)
  end

  def parse_doc(doc) do
    [head | tail] = String.split(doc, "\n", trim: true)
    [[id | _] | _] = Regex.scan(@docno_regex, head, capture: :all_but_first, trim: true)

    words =
      Enum.reduce(tail, [], fn line, acc ->
        [do_process_tokens(line) | acc]
      end)

    {String.trim(id), Enum.reverse(words) |> List.flatten()}
  end

  defp do_process_tokens(content) do
    content
    |> String.split(@token_regex, trim: true, include_captures: false)
    |> Enum.flat_map(fn word ->
      case word do
        "" -> []
        "DOC" -> []
        "DOCNO" -> []
        "WSJ" -> []
        "HL" -> []
        "DD" -> []
        "SO" -> []
        "IN" -> []
        "DATELINE" -> []
        "TEXT" -> []
        _ -> [String.downcase(word)]
      end
    end)
  end

  def index() do
    content = File.read!("./output/#{SearchEngine.file_name()}_dictionary.out")

    words = String.split(content, "\n", trim: true)

    docs = deserialize_from_file("./output/#{SearchEngine.file_name()}_binary.out")

    map =
      Enum.reduce(words, %{}, fn word, acc ->
        Map.put(acc, word, %{})
      end)

    updated_map =
      Enum.reduce(docs, map, fn {id, doc}, acc ->
        Enum.reduce(doc, acc, fn line, inner_acc ->
          if Map.has_key?(inner_acc, line) do
            Map.update!(inner_acc, line, fn id_map ->
              Map.update(id_map, id, 1, &(&1 + 1))
            end)
          else
            inner_acc
          end
        end)
      end)

    IO.inspect(updated_map)

    serialize_to_file(updated_map, "./output/#{SearchEngine.file_name()}indexed_binary.out")
  end

  def preprocess_docnos(content) do
    Regex.replace(~r/<DOCNO>\s*\n(.*?)\n\s*<\/DOCNO>/ism, content, fn _match, docno_content ->
      "<DOCNO>#{String.trim(docno_content)}</DOCNO>"
    end)
  end
end
