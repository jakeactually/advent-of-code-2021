{:ok, text} = File.read("input.txt")

steps = text
  |> String.split("\n")
  |> Enum.filter( &(&1 != "") )
  |> Enum.map(&String.split/1)
  |> Enum.map(fn [step, n] -> {step, Integer.parse(n) |> elem(0)} end)

{x, y, _} = steps
  |> Enum.reduce({0, 0, 0}, fn step, {x, y, a} ->
    case step do
      {"forward", n} -> {x+n, y+n*a, a}
      {"down", n} -> {x, y, a+n}
      {"up", n} -> {x, y, a-n}
    end
  end)

IO.inspect(x * y)
