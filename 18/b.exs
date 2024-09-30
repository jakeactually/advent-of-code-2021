#  elixir -r util.exs b.exs

lines =
  "input.txt"
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&BracketParser.parse/1)

combinations =
  for a <- lines, b <- lines, a != b do
    [:open | b] ++ a ++ [:close]
  end

combinations
|> Stream.map(fn combination ->
  combination
  |> ListZipper.new()
  |> Advent.reduce_zipper()
  |> ListZipper.to_list()
  |> BracketParser.unparse()
  |> elem(0)
  |> Magnitude.to_tuple()
  |> Magnitude.magnitude()
end)
|> Enum.max()
|> IO.inspect(charlists: false)
