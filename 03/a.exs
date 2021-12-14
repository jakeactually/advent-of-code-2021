{:ok, text} = File.read("input.txt")

lines = text
  |> String.split("\n")
  |> Enum.filter( &(&1 != "") )

gamma = lines
  |> Enum.map(&String.split(&1, "") |> Enum.drop(1) |> Enum.take(12))
  |> Enum.zip
  |> Enum.map(fn xs -> Tuple.to_list(xs)
    |> Enum.group_by(& &1)
    |> Map.values
    |> Enum.sort_by(&length/1)
    |> Enum.fetch!(1)
    |> Enum.fetch!(0)
  end)

epsilon = gamma
  |> Enum.map(fn x ->
    case x do
      "1" -> "0"
      "0" -> "1"
    end
  end)

{parsed_gamma, _} = gamma |> Enum.join("") |> Integer.parse(2)
{parsed_epsilon, _} = epsilon |> Enum.join("") |> Integer.parse(2)

IO.inspect(parsed_gamma * parsed_epsilon)
