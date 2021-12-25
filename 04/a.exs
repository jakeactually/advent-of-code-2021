{:ok, text} = File.read("input.txt")

[head | tail] = text
  |> String.split("\n\n")

numbers = head |> String.split(",")

matrices = tail
  |> Enum.map(fn x -> x
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn x -> Regex.scan(~r/\d+/, x)
    |> List.flatten
    end)
  end)

boards = matrices
  |> Enum.map(fn board -> board |> List.flatten |> MapSet.new end)

rows = matrices
  |> Enum.with_index
  |> Enum.flat_map(fn { x, i } -> x |> Enum.map(fn y -> { y |> MapSet.new, i } end) end)

columns = matrices
  |> Enum.with_index
  |> Enum.flat_map(fn { x, i } -> x |> Enum.zip |> Enum.map(fn y -> { Tuple.to_list(y) |> MapSet.new, i } end) end)

options = List.flatten([rows, columns])

defmodule Loop do
  def loop(boards, options, numbers, i) do
    number = numbers |> Enum.fetch!(i)

    new_boards = boards
      |> Enum.map(fn board ->
        MapSet.delete(board, number)
      end)

    new_options = options |> Enum.map(fn {option, board_id} ->
      { MapSet.delete(option, number), board_id }
    end)

    goal = new_options
      |> Enum.find(fn {option, _} -> Enum.empty?(option) end)

    if goal do
      {_, id} = goal
      {new_boards |> Enum.fetch!(id), number}
    else
      loop(new_boards, new_options, numbers, i + 1)
    end
  end
end

{winner, number} = Loop.loop(boards, options, numbers, 0)

a = winner |> Enum.map(&Integer.parse/1) |> Enum.map(fn {x, _} -> x end) |> Enum.reduce(&(&1 + &2))
{b, _} = Integer.parse(number)

IO.inspect(a * b)
