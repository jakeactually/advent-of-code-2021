{:ok, text} = File.read("input.txt")

lengths = text
  |> String.split("\n")
  |> Enum.filter(&(&1 != ""))
  |> Enum.flat_map(fn x -> x
    |> String.split(" | ")
    |> Enum.fetch!(1)
    |> String.split(" ")
    |> Enum.map(&String.length/1)
  end)
  |> Enum.filter(fn len ->
    len == 2 || len == 3 || len == 4 || len == 7
  end)
  |> Enum.count

IO.inspect(lengths)
