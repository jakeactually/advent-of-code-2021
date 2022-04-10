{:ok, text} = File.read("input.txt")

cuboids = text
  |> String.split("\n")
  |> Enum.reject(&(&1 == ""))
  |> Enum.map(fn line -> Regex.scan(~r/on|off|\-?\d+/, line) |> Enum.map(&Enum.fetch!(&1, 0)) end)
  |> Enum.map(fn [command | coords] ->
    [x1, x2, y1, y2, z1, z2] = coords |> Enum.map(fn number ->
      Integer.parse(number) |> elem(0)
    end)

    {command, x1, x2, y1, y2, z1, z2}
  end)

result = cuboids |> Enum.reduce(MapSet.new, fn {command, x1, x2, y1, y2, z1, z2}, set ->
  IO.inspect({command, x1, x2, y1, y2, z1, z2})

  x1..x2 |> Enum.reduce(set, fn x, set ->
    y1..y2 |> Enum.reduce(set, fn y, set ->
      z1..z2 |> Enum.reduce(set, fn z, set ->
        case command do
          "on" -> MapSet.put(set, {x, y, z})
          "off" -> MapSet.delete(set, {x, y, z})
        end
      end)
    end)
  end)
end)

result |> MapSet.size |> IO.inspect
