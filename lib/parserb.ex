# defmodule Parser do
#   import Guards

#   def parse() do
#     {:ok, xml} = File.read("./tenthousand.xml")
#     {docnos, binout} = step_through_string(xml, [], [])
#     File.write("nolower_list.parsed", IO.iodata_to_binary(binout))
#     IO.inspect(docnos)
#     IO.inspect(length(docnos))
#   end

#   def parse_tag(<<?>, rest::binary>>, token), do: {token, rest}

#   def parse_tag(<<head, rest::binary>>, token) when head != ?\s,
#     do: parse_tag(rest, token <> <<head>>)

#   def parse_tag(<<_, rest::binary>>, token), do: parse_tag(rest, token)

#   def skip_doc_end(<<?>, rest::binary>>), do: rest
#   def skip_doc_end(<<_, rest::binary>>), do: skip_doc_end(rest)

#   def parse_docno(<<?<, rest::binary>>, token) do
#     {token, skip_doc_end(rest)}
#   end

#   def parse_docno(<<head, rest::binary>>, token) when head != ?\s,
#     do: parse_docno(rest, token <> <<head>>)

#   def parse_docno(<<_head, rest::binary>>, token), do: parse_docno(rest, token)

#   def parse_token(<<head, rest::binary>>, token) when is_letter(head) do
#     parse_token(rest, [head | token])
#   end

#   def parse_token(<<>>, token), do: {token, <<>>}
#   def parse_token(<<?<, rest::binary>>, token), do: {token, <<?<, rest::binary>>}
#   def parse_token(<<_, rest::binary>>, token), do: {token, rest}

#   def step_through_string(<<>>, docnos, binout), do: {Enum.reverse(docnos), binout}

#   def step_through_string(<<?<, rest::binary>>, docnos, binout) do
#     {token, rest} = parse_tag(rest, <<>>)

#     case token do
#       "DOCNO" ->
#         {docno, rest} = parse_docno(rest, <<>>)
#         # IO.inspect(length(docnos))
#         step_through_string(rest, [docno | docnos], binout)

#       "/DOC" ->
#         step_through_string(rest, docnos, [binout, "\n"])

#       _ ->
#         step_through_string(rest, docnos, binout)
#     end
#   end

#   def step_through_string(bin, docnos, binout) do
#     {token, rest} = parse_token(bin, <<>>)

#     case token do
#       [] ->
#         step_through_string(rest, docnos, binout)

#       _ ->
#         binout = [binout | [token |> IO.iodata_to_binary()]]
#         binout = [binout | ["\n"]]

#         step_through_string(rest, docnos, binout)
#     end
#   end
# end
