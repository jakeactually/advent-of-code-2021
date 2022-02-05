defmodule Util do
  def pairs [a | [b | xs]] do
    [[a, b] | pairs [b | xs]]
  end

  def pairs _ do
    []
  end

  def unpair {[a, b], n} do
    [
      {a, n},
      {b, n}
    ]
  end

  def expand { [a, b], count }, map do
    c = Map.fetch!(map, "#{a}#{b}")

    [
      { [a, c], count },
      { [c, b], count },
    ]
  end

  def expand_many list, map do
    result = list |> Enum.flat_map(fn item -> expand item, map end)

    result
      |> Enum.group_by(&elem(&1, 0))
      |> Enum.map(fn {k, v} -> {k, v |> Enum.map(&elem(&1, 1)) |> Enum.sum} end)
  end
end

{:ok, text} = File.read("input.txt")

map = text
  |> String.split("\n")
  |> Enum.filter(&(&1 != ""))
  |> Enum.map(fn line ->
    [a, b] = String.split(line, " -> ")
    {a, b}
  end)
  |> Map.new

start = "SNPVPFCPPKSBNSPSPSOF"
  |> String.split("")
  |> Enum.filter(&(&1 != ""))
  |> Util.pairs
  |> Enum.map(&{&1, 1})

counts = 0..39
  |> Enum.reduce(start, fn _, acc ->
    Util.expand_many acc, map
  end)
  |> Enum.flat_map(&Util.unpair/1)
  |> Enum.group_by(&elem(&1, 0))
  |> Enum.map(fn {k, v} -> {k, v |> Enum.map(&elem(&1, 1)) |> Enum.sum |> div(2)} end)

max = counts |> Enum.max_by(&elem(&1, 1))
min = counts |> Enum.min_by(&elem(&1, 1))

IO.inspect({min, max})
