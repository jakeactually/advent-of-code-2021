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

  def parse_many str do
    case parse_one str do
      {:just, node, rest} ->
        {children, new_rest} = parse_many rest
        {[node | children], new_rest}
      _ -> {[], str}
    end
  end

  def illegal str do
    try do
      {:ok, parse_one str}
    rescue
      e in MatchError -> case e.term do
        {_, [char | _]} -> {:err, char}
        {_, []} -> {:ok, nil}
      end
    end
  end

  def value str do
    case str do
      ")" -> 3
      "]" -> 57
      "}" -> 1197
      ">" -> 25137
    end
  end
end

{:ok, text} = File.read("input.txt")

text
  |> String.split("\n")
  |> Enum.filter(&(&1 != ""))
  |> Enum.map(fn line ->
    line
      |> String.split("")
      |> Enum.filter(&(&1 != ""))
      |> Parse.illegal
  end)
  |> Enum.filter(fn result ->
    case result do
      {:err, _} -> true
      _ -> false
    end
  end)
  |> Enum.map(&elem(&1, 1))
  |> Enum.map(&Parse.value/1)
  |> Enum.sum
  |> IO.inspect
