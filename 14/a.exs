defmodule Util do
  def expand map, [a | [b | xs]] do
    ab = Map.fetch!(map, "#{a}#{b}")
    [a | [ab | expand(map, [b | xs])]]
  end

  def expand _, xs do
    xs
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

lens = 0..9
  |> Enum.reduce(start, fn _, xs -> Util.expand(map, xs) end)
  |> Enum.group_by(&(&1))
  |> Enum.map(fn {_, v} -> length v end)

IO.inspect (Enum.max(lens) - Enum.min(lens))
