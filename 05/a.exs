{:ok, text} = File.read("input.txt")

lines = text
  |> String.split("\n")
  |> Enum.filter(&(&1 != ""))
  |> Enum.map(fn x -> Regex.scan(~r/\d+/, x)
    |> List.flatten
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(fn {n, _} -> n end)
  end)

result = lines |> Enum.reduce(Map.new(), fn [x1, y1, x2, y2], map ->
  cond do
    x1 == x2 -> y1..y2 |> Enum.reduce(map, fn y, map -> Map.update(map, {x1, y}, 1, &(&1 + 1)) end)
    y1 == y2 -> x1..x2 |> Enum.reduce(map, fn x, map -> Map.update(map, {x, y1}, 1, &(&1 + 1)) end)
    true -> map
  end
end)

IO.inspect(result |> Enum.filter(fn {_, v} -> v > 1 end) |> Enum.count)
