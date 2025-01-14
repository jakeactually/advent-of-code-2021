# skipped

# elixir -r util.exs a.exs

file_path = "input.txt"
scanner_data = ScannerParser.parse_file(file_path)

a = scanner_data |> Enum.at(0)

dic = scanner_data
|> Enum.map(fn x -> Vector3.distances_map(x.beacons) end)

s1 = dic |> Enum.at(0) |> Enum.at(0) |> elem(1) |> MapSet.new
IO.inspect(dic |> Enum.at(0) |> Enum.at(0))


result = dic |> Enum.drop(1) |> Enum.find(fn scanner ->
  scanner |>
  Enum.find(fn {beacon, beacons} ->
    size = MapSet.intersection(s1, MapSet.new(beacons)) |> MapSet.size
    size > 10
  end)
end)

IO.inspect(result |>
Enum.find(fn {beacon, beacons} ->
  size = MapSet.intersection(s1, MapSet.new(beacons)) |> MapSet.size
  size > 10
end))
