{:ok, text} = File.read("input.txt")

[algorithm_str, image_str] = text |> String.split("\n\n")

algorithm = algorithm_str
  |> String.split("")
  |> Enum.filter(&(&1 != ""))
  #|> Enum.map(fn x -> if x == "#" do "." else "#" end end)

image = image_str
  |> String.split("\n")
  |> Enum.filter(&(&1 != ""))
  |> Enum.with_index
  |> Enum.reduce(Map.new, fn {line, y}, map  -> line
    |> String.split("")
    |> Enum.filter(&(&1 != ""))
    |> Enum.with_index
    |> Enum.reduce(map, fn {n, x}, map -> Map.put(map, {x, y}, n) end)
  end)

base_min = -1
base_max = 100
iters = 49

square = [-1, 0, 1] |> Enum.flat_map(fn y ->
  [-1, 0, 1] |> Enum.map(fn x ->
    {x, y}
  end)
end)

new_map = 0..iters |> Enum.reduce(image, fn iter, start_map ->
  min = base_min - iter
  max = base_max + iter

  result = min..max |> Enum.reduce(start_map, fn y, map ->
    min..max |> Enum.reduce(map, fn x, map ->
      string = square
        |> Enum.map(fn {ox, oy} ->
          default = if rem(iter, 2) == 0 do "." else "#" end
          if Map.get(start_map, {x + ox, y + oy}, default) == "#" do "1" else "0" end
        end)
        |> Enum.join("")

      # IO.inspect(string)

      index = string |> Integer.parse(2)
      |> elem(0)

      # IO.inspect(index)

      value = algorithm |> Enum.fetch!(index)

      # IO.inspect(value)

      map |> Map.put({x, y}, value)
    end)
  end)

  result
end)

min = base_min - iters
max = base_max + iters

min..max |> Enum.each(fn y ->
  min..max
    |> Enum.map(fn x ->
      new_map |> Map.get({x, y}, ".")
    end)
    |> Enum.join
    |> IO.inspect
end)

min..max |> Enum.flat_map(fn y ->
  min..max
    |> Enum.map(fn x ->
      new_map |> Map.get({x, y}, ".")
    end)
    |> Enum.filter(&(&1 == "#"))
end)
|> length
|> IO.inspect
