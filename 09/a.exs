{:ok, text} = File.read("input.txt")

map = text
  |> String.split("\n")
  |> Enum.filter(&(&1 != ""))
  |> Enum.with_index
  |> Enum.reduce(Map.new, fn {line, y}, map  -> line
    |> String.split("")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(&elem(&1, 0))
    |> Enum.with_index
    |> Enum.reduce(map, fn {n, x}, map -> Map.put(map, {x, y}, n) end)
  end)

map
  |> Enum.filter(fn {{x, y}, v} ->
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}] |> Enum.all?(fn {ox, oy} ->
      coord = {x + ox, y + oy}
      !Map.has_key?(map, coord) || Map.fetch!(map, coord) > v
    end)
  end)
  |> Enum.map(&elem(&1, 1))
  |> Enum.map(&(&1 + 1))
  |> Enum.sum
  |> IO.inspect
