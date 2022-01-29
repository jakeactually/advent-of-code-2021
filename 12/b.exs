defmodule Util do
  def out(graph, {node, path, set}) do
    if node == "end" do
      [{node, path, set}]
    else
      if Map.has_key?(graph, node) do
        new_set = if String.match?(node, ~r/[A-Z]/) do
          set
        else
          if MapSet.member?(set, node) do
            MapSet.put(set, "twice")
          else
            MapSet.put(set, node)
          end
        end

        Map.fetch!(graph, node)
          |> Enum.reject(&(&1 == "start"))
          |> Enum.reject(fn item -> MapSet.member?(new_set, item) && MapSet.member?(new_set, "twice") end)
          |> Enum.map(&{&1, [node | path], new_set})
      else
        [{node, path, set}]
      end
    end
  end

  def out_many(graph, nodes) do
    # IO.inspect(nodes)
    Enum.flat_map(nodes, &out(graph, &1))
  end

  def loop(graph, nodes) do
    next = out_many(graph, nodes)

    # IO.inspect(next |> length)

    if Enum.all?(next, fn {node, _, _} -> node == "end" end) do
      next
    else
      loop(graph, next)
    end
  end
end

{:ok, text} = File.read("input.txt")

graph = text
  |> String.split("\n")
  |> Enum.filter(&(&1 != ""))
  |> Enum.reduce(Map.new, fn line, map ->
    [a, b] = String.split(line, "-")
    map |> Map.update(a, [b], &[b | &1]) |> Map.update(b, [a], &[a | &1])
  end)

IO.inspect(Util.loop(graph, [{"start", [], MapSet.new}]) |> length)
