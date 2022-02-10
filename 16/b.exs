# elixir -r util.exs b.exs

defmodule Solve do
  def solve {_, operator, value} do
    case operator do
      0 -> value |> Enum.map(&solve/1) |> Enum.sum
      1 -> value |> Enum.map(&solve/1) |> Enum.product
      2 -> value |> Enum.map(&solve/1) |> Enum.min
      3 -> value |> Enum.map(&solve/1) |> Enum.max
      5 ->
        [a, b] = value
        if solve(a) > solve(b) do 1 else 0 end
      6 ->
        [a, b] = value
        if solve(a) < solve(b) do 1 else 0 end
      7 ->
        [a, b] = value
        if solve(a) == solve(b) do 1 else 0 end
    end
  end

  def solve {_, value} do
    value
  end
end

{:ok, text} = File.read("input.txt")

bits = text
  |> String.split("")
  |> Enum.reject(&(&1 == "" || &1 == "\n"))
  |> Enum.flat_map(&Map.fetch!(Util.hexa, &1))

bits |> Util.packet |> elem(0) |> Solve.solve |> IO.inspect
