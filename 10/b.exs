defmodule Parse do
  def parse_one [x | xs] do
    case x do
      "(" ->
        {children, [")" | ys]} = parse_many xs
        {:just, {:paren, children}, ys}
      "[" ->
        {children, ["]" | ys]} = parse_many xs
        {:just, {:box, children}, ys}
      "{" ->
        {children, ["}" | ys]} = parse_many xs
        {:just, {:bracket, children}, ys}
      "<" ->
        {children, [">" | ys]} = parse_many xs
        {:just, {:arrow, children}, ys}
      _ -> {:nothing}
    end
  end

  def parse_one _ do
    {:nothing}
  end

  def parse_one_incomplete [x | xs] do
    case x do
      "(" ->
        {children, ys} = parse_many_incomplete xs
        {:just, {:paren, children}, ys |> Enum.drop(1)}
      "[" ->
        {children, ys} = parse_many_incomplete xs
        {:just, {:box, children}, ys |> Enum.drop(1)}
      "{" ->
        {children, ys} = parse_many_incomplete xs
        {:just, {:bracket, children}, ys |> Enum.drop(1)}
      "<" ->
        {children, ys} = parse_many_incomplete xs
        {:just, {:arrow, children}, ys |> Enum.drop(1)}
      _ -> {:nothing}
    end
  end

  def parse_one_incomplete _ do
    {:nothing}
  end

  def parse_many str do
    case parse_one str do
      {:just, node, rest} ->
        {children, new_rest} = parse_many rest
        {[node | children], new_rest}
      _ -> {[], str}
    end
  end

  def parse_many_incomplete str do
    case parse_one_incomplete str do
      {:just, node, rest} ->
        {children, new_rest} = parse_many_incomplete rest
        {[node | children], new_rest}
      _ -> {[], str}
    end
  end

  def is_corrupted str do
    try do
      parse_one str
      false
    rescue
      e in MatchError -> case e.term do
        {_, [_ | _]} -> true
        _ -> false
      end
    end
  end

  def value str do
    case str do
      ")" -> 1
      "]" -> 2
      "}" -> 3
      ">" -> 4
    end
  end

  def serialize node do
    case node do
      {:paren, children} -> ["(" | Enum.flat_map(children, &serialize/1)] ++ [")"]
      {:box, children} -> ["[" | Enum.flat_map(children, &serialize/1)] ++ ["]"]
      {:bracket, children} -> ["{" | Enum.flat_map(children, &serialize/1)] ++ ["}"]
      {:arrow, children} -> ["<" | Enum.flat_map(children, &serialize/1)] ++ [">"]
    end
  end
end

{:ok, text} = File.read("input.txt")

sorted = text
  |> String.split("\n")
  |> Enum.filter(&(&1 != ""))
  |> Enum.map(fn line ->
    line
      |> String.split("")
      |> Enum.filter(&(&1 != ""))
  end)
  |> Enum.reject(&Parse.is_corrupted/1)
  |> Enum.map(fn line ->
    {children, _} = Parse.parse_many_incomplete line
    complete = Enum.flat_map(children, &Parse.serialize/1)
    suffix = Enum.drop(complete, length line)
    Enum.reduce(suffix, 0, fn x, xs -> xs * 5 + Parse.value x end)
  end)
  |> Enum.sort

IO.inspect(Enum.fetch!(sorted, floor(length(sorted) / 2)))
