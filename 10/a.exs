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
end

"[[[[<>({}){}[([])<>]]]]]"
  |> String.split("")
  |> Enum.reject(&(&1 == ""))
  |> Parse.parse_one
  |> IO.inspect
