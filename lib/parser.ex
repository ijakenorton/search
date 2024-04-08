defmodule Parser do
  import FileHandling
  import Serialization
  @docno_regex ~r/<DOCNO>\s*([^<]*)/i
  @token_regex ~r/[^a-zA-Z]+/

  def parse(input_file) do
    input_file = if input_file == [], do: "./#{FileHandling.file_name()}.xml", else: input_file

    documents =
      File.read!(input_file)
      |> preprocess_docnos()
      |> String.split(~r/<\s*DOC\s*>/, trim: true)
      |> Flow.from_enumerable()
      |> Flow.map(&parse_doc/1)
      |> Enum.to_list()
      |> List.flatten()

    documents
  end

  def parse_doc(doc) do
    [head | tail] = String.split(doc, "\n", trim: true)
    [[id | _] | _] = Regex.scan(@docno_regex, head, capture: :all_but_first, trim: true)

    words =
      List.foldr(tail, [], fn line, acc ->
        [do_process_tokens(line) | acc]
      end)

    {String.trim(id), words |> List.flatten()}
  end

  defp do_process_tokens(content) do
    content
    |> String.split(@token_regex, trim: true, include_captures: false)
    |> Enum.flat_map(fn word ->
      case word do
        "" -> []
        # "DOC" -> []
        # "DOCNO" -> []
        # "WSJ" -> []
        # "HL" -> []
        # "DD" -> []
        # "SO" -> []
        # "IN" -> []
        # "DATELINE" -> []
        # "TEXT" -> []
        _ -> [String.downcase(word)]
      end
    end)
  end

  def write_ids(ids_and_lengths) do
    File.write(FileHandling.make_file_input_string("ids"), serialize_ids(ids_and_lengths))
  end

  def write_parsed_and_dict_to_file(documents) do
    IO.puts("writing to file....")
    {:ok, parsed_fd} = File.open("./output/#{file_name()}_parsed.out", [:write])

    {:ok, dictionary_fd} =
      File.open("./output/#{file_name()}_dictionary.out", [:write])

    dictionary =
      documents
      |> Enum.map(fn
        {id, words} ->
          IO.write(parsed_fd, "#{id}\n#{Enum.join(words, "\n")}\n\n")
          words
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort()

    IO.write(dictionary_fd, Enum.join(dictionary, "\n"))

    Serialization.serialize_to_file(documents, "./output/#{file_name()}_binary.out")
    File.close(parsed_fd)
    File.close(dictionary_fd)
  end

  def preprocess_docnos(content) do
    Regex.replace(~r/<DOCNO>\s*\n(.*?)\n\s*<\/DOCNO>/ism, content, fn _match, docno_content ->
      "<DOCNO>#{String.trim(docno_content)}</DOCNO>"
    end)
  end
end
