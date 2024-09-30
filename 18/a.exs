# elixir -r util.exs a.exs

"input.txt"
|> File.stream!()
|> Stream.map(&String.trim/1)
|> Stream.map(&BracketParser.parse/1)
|> Stream.map(&ListZipper.new/1)
|> Enum.reduce(fn a, b ->
  zipper =
    [:open | b |> ListZipper.to_list()] ++
      ListZipper.to_list(a) ++ [:close]

  zipper
  |> ListZipper.new()
  |> Advent.reduce_zipper()
end)
|> ListZipper.to_list()
|> BracketParser.unparse()
|> elem(0)
|> Magnitude.to_tuple()
|> Magnitude.magnitude()
|> IO.inspect(charlists: false)
