# elixir -r util.exs a.exs

{:ok, text} = File.read("input.txt")

bits = text
  |> String.split("")
  |> Enum.reject(&(&1 == "" || &1 == "\n"))
  |> Enum.flat_map(&Map.fetch!(Util.hexa, &1))

bits |> Util.packet |> elem(0) |> Util.sum |> IO.inspect
