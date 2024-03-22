defmodule Guards do
  defguard is_letter(char) when char in ?a..?z or char in ?A..?Z
  # defguard is_letter(char) when (char >= 97 and char <= 122) or (char >= 65 and char <= 90)
end
