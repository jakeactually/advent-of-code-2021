defmodule Util do
  def expand map, [a | [b | xs]] do
    key = "#{a}#{b}"

    if Map.has_key?(map, key) do
      c = Map.fetch!(map, key)
      [a | [c | expand(map, [b | xs])]]
    else
      [a | expand(map, [b | xs])]
    end
  end

  def expand _, _ do
    []
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

Util.expand(map, ["N", "N", "C", "B"]) |> IO.inspect
