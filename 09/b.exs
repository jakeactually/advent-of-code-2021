defmodule Graph do
  def out(map, {x, y}) do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
      |> Enum.map(fn {ox, oy} ->
        coord = {x + ox, y + oy}

        if Map.has_key?(map, coord) do
          if Map.fetch!(map, coord) == 9 do
            nil
          else
            coord
          end
        else
          nil
        end
      end)
      |> Enum.filter(&(&1 != nil))
  end

  def list_out(map, list) do
    Enum.flat_map(list, &out(map, &1))
  end

  def flood(map, set, coords) do
    result = list_out(map, coords) |> Enum.reject(&MapSet.member?(set, &1))

    if Enum.empty?(result) do
      set
    else
      flood(map, set |> MapSet.union(MapSet.new(result)), result)
    end
  end
end

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
  |> Enum.map(&elem(&1, 0))
  |> Enum.map(&Graph.flood(map, MapSet.new, [&1]))
  |> Enum.map(&MapSet.size/1)
  |> Enum.sort
  |> Enum.reverse
  |> Enum.take(3)
  |> Enum.product
  |> IO.inspect
