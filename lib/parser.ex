defmodule Parser do
  @docno_regex ~r/<DOCNO>\s*([^<]*)/i
  @token_regex ~r/[^a-zA-Z]+/

  import FileHandling

  def parse() do
    documents =
      File.read!("./input/#{SearchEngine.file_name()}.xml")
      |> preprocess_docnos()
      |> String.split(~r/<\s*\/DOC\s*>/, trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))
      |> Enum.flat_map(&process_document/1)

    # result =
    #   documents
    #   |> Flow.from_enumerable()
    #   |> Flow.flat_map(&process_document/1)
    #   |> Enum.to_list()

    File.write!("./output/#{SearchEngine.file_name()}_combined.out", documents)
    # File.write!("./output/#{SearchEngine.file_name()}_combined.out", result)
  end

  def make_dictionary() do
    documents =
      File.read!("./input/#{SearchEngine.file_name()}.xml")
      |> preprocess_docnos()
      |> String.split(~r/<\s*\/DOC\s*>/, trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    result =
      documents
      |> Flow.from_enumerable()
      |> Flow.flat_map(&process_to_dictionary(&1))
      |> Enum.to_list()
      |> Enum.uniq()
      |> Enum.sort(fn a, b -> a - b end)
      |> Enum.join("\n")

    File.write!(
      "./output/#{SearchEngine.file_name()}_dictionary.out",
      result
    )
  end

  def preprocess_docnos(content) do
    Regex.replace(~r/<DOCNO>\s*\n(.*?)\n\s*<\/DOCNO>/ism, content, fn _match, docno_content ->
      "<DOCNO>#{String.trim(docno_content)}</DOCNO>"
    end)
  end

  defp process_to_dictionary(doc_lines) do
    Enum.flat_map(doc_lines, fn
      content ->
        match = Regex.scan(@docno_regex, content, capture: :all_but_first, trim: true)

        case match do
          [_] ->
            []

          _ ->
            content |> do_process_tokens()
        end
    end)
  end

  defp process_document(doc_lines) do
    Enum.flat_map(doc_lines, fn
      content ->
        match = Regex.scan(@docno_regex, content, capture: :all_but_first, trim: true)

        case match do
          [docno] ->
            ["\n", docno, "\n"]

          _ ->
            content |> do_process_tokens()
        end
    end)
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
        _ -> [String.downcase(word), "\n"]
      end
    end)
  end
end
