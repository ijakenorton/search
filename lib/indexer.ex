defmodule Indexer do
  import FileHandling
  import Serialization

  def index() do
    IO.puts("setting up...")
    {words, dict, docs} = setup()
    IO.puts("indexing...")

    postings = array_impl(docs, words, dict) |> tfidf()

    lengths = :array.new(length(words))

    {binary, lengths} =
      Enum.reduce(0..(:array.size(postings) - 1), {[], lengths}, fn index,
                                                                    {bin_acc, length_acc} ->
        current_posting = :array.get(index, postings)
        {posting_binary, posting_length} = serialize_posting(current_posting)

        if index == 0 do
          length_acc = :array.set(index, {0, posting_length}, length_acc)
          {[bin_acc, posting_binary], length_acc}
        else
          {offset, previous_length} = :array.get(index - 1, length_acc)

          length_acc =
            :array.set(
              index,
              {previous_length + offset, posting_length},
              length_acc
            )

          {[bin_acc, posting_binary], length_acc}
        end
      end)

    binary = IO.iodata_to_binary(binary)

    serialize_to_file(lengths, make_file_input_string("lengths"))

    File.write!(make_file_input_string("serialized"), binary)
  end

  def array_impl(docs, words, dict) do
    postings = :array.new(length(words))

    postings =
      Enum.reduce(0..(length(words) - 1), postings, fn index, acc ->
        :array.set(index, [], acc)
      end)

    postings =
      Enum.with_index(docs)
      |> Enum.reduce(postings, fn {doc, doc_index}, acc ->
        frequencies = Enum.frequencies(doc)

        Enum.reduce(Map.keys(frequencies), acc, fn key, postings_acc ->
          word_index = dict[key]
          current = :array.get(word_index, postings_acc)

          updated =
            :array.set(word_index, [{doc_index, frequencies[key]} | current], postings_acc)

          updated
        end)
      end)

    postings
  end

  def tfidf(postings) do
    ids = deserialize_ids(File.read!(make_file_input_string("ids")))
    postings_out = :array.new(:array.size(postings))
    postings_size = :array.size(postings)
    docs_size = :array.size(ids)

    postings_out =
      Enum.reduce(0..(postings_size - 1), postings_out, fn index, acc ->
        current = :array.get(index, postings)
        doc_count = length(current)

        scores =
          current
          |> Enum.map(fn {id, freq} ->
            {_, count} = :array.get(id, ids)

            tf = freq / count
            idf = :math.log10(docs_size / doc_count)
            {id, tf * idf * 10_000_000_000}
          end)
          |> Enum.sort(fn {_, score1}, {_, score2} -> score2 < score1 end)

        :array.set(index, scores, acc)
      end)

    postings_out
  end

  def setup do
    documents = Parser.parse()

    ids_and_lengths =
      Enum.map(documents, fn {id, doc} ->
        {id, length(doc)}
      end)

    Parser.write_ids(ids_and_lengths)

    words =
      documents
      |> Enum.map(fn
        {_id, words} ->
          words
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort()

    dict =
      words
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {element, index}, acc -> Map.put(acc, element, index) end)

    serialize_to_file(dict, make_file_input_string("dict_serial"))

    {words, dict, documents}
  end
end
