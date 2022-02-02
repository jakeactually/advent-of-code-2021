{:ok, text} = File.read("input.txt")

folds = [
  {655, 0},
]

set = text
  |> String.split("\n")
  |> Enum.filter(&(&1 != ""))
  |> Enum.map(fn line ->
    [a, b] = String.split(line, ",")
    {n, _} = Integer.parse(a)
    {m, _} = Integer.parse(b)
    {n, m}
  end)

  |> Enum.map(fn {x, y} ->
    Enum.reduce(folds, {x, y}, fn {fx, fy}, {cx, cy} ->
      new_x = if cx < fx || fx == 0 do cx else fx - (cx - fx) end
      new_y = if cy < fy || fy == 0 do cy else fy - (cy - fy) end
      {new_x, new_y}
    end)
  end)

  |> MapSet.new

set |> MapSet.size |> IO.inspect
