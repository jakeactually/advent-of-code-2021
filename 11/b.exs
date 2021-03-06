defmodule Util do
  @dirs [
    {0, 1}, {0, -1}, {1, 0}, {-1, 0},
    {-1, -1}, {1, -1}, {1, 1}, {-1, 1},
  ]

  def plus(map, coord) do
    if Map.has_key?(map, coord) do
      point = Map.fetch!(map, coord)

      if point == 9 do
        map = Map.delete(map, coord)

        map = @dirs |> Enum.reduce(map, fn {ox, oy}, acc_map ->
          {x, y} = coord
          new_coord = {x + ox, y + oy}
          plus(acc_map, new_coord)
        end)

        Map.put(map, coord, point + 1)
      else
        Map.put(map, coord, point + 1)
      end
    else
      map
    end
  end

  def floor(map, coord) do
    if Map.has_key?(map, coord) do
      point = Map.fetch!(map, coord)

      if point > 9 do
        Map.put(map, coord, 0)
      else
        Map.put(map, coord, point)
      end
    else
      map
    end
  end

  def loop(map, i) do
    new_map = map
      |> Map.keys
      |> Enum.reduce(map, fn coord, acc_map ->
        Util.plus(acc_map, coord)
      end)

    new_flashed = new_map
      |> Map.keys
      |> Enum.filter(fn coord ->
        Map.fetch!(new_map, coord) > 9
      end)
      |> length

    if new_flashed == 100 do
      i
    else
      result = new_map
        |> Map.keys
        |> Enum.reduce(new_map, fn coord, acc_map ->
          Util.floor(acc_map, coord)
        end)

      loop(result, i + 1)
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

IO.inspect(Util.loop(map, 1))
