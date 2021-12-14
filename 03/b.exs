{:ok, text} = File.read("input.txt")

lines = text
  |> String.split("\n")
  |> Enum.filter( &(&1 != "") )

numbers = lines
  |> Enum.map(&String.split(&1, "") |> Enum.drop(1) |> Enum.take(12))

defmodule Util do
  def gamma(a, b) do
    cond do
      length(a) == length(b) -> "1"
      length(a) > length(b) -> Enum.fetch!(a, 0)
      true -> Enum.fetch!(b, 0)
    end
  end

  def epsilon(a, b) do
    cond do
      length(a) == length(b) -> "0"
      length(a) > length(b) -> Enum.fetch!(b, 0)
      true -> Enum.fetch!(a, 0)
    end
  end

  def calculate(numbers, function) do
    0..11 |> Enum.reduce(numbers, fn x, xs ->
      if length(xs) > 1 do
        [a, b] = xs
          |> Enum.map(&Enum.fetch!(&1, x))
          |> Enum.group_by(& &1)
          |> Map.values
          |> Enum.sort_by(&length/1)

        selection = function.(a, b)

        xs |> Enum.filter( &(Enum.fetch!(&1, x) == selection) )
      else
        xs
      end
    end)
  end
end

{gamma, _} = Util.calculate(numbers, &Util.gamma/2) |> Enum.join("") |> Integer.parse(2)
{epsilon, _} = Util.calculate(numbers, &Util.epsilon/2) |> Enum.join("") |> Integer.parse(2)

IO.inspect(gamma * epsilon)
