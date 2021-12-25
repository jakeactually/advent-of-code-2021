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

remaining = MapSet.new(0..length(matrices) - 1)

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
  def loop(boards, options, numbers, last_winner, i) do
    number = numbers |> Enum.fetch!(i)

    new_boards = boards
      |> Enum.map(fn board ->
        MapSet.delete(board, number)
      end)

    new_options = options |> Enum.map(fn {option, board_id} ->
      { MapSet.delete(option, number), board_id }
    end)

    goal = new_options
      |> Enum.filter(fn {option, _} -> Enum.empty?(option) end)

    new_options = if length(goal) > 0 do
      finished = goal |> Enum.map(&elem(&1, 1)) |> MapSet.new
      new_options
        |> Enum.reject(fn {_, id} -> finished |> MapSet.member?(id) end)
    else
      new_options
    end

    new_last_winner = if length(goal) > 0 do
      goal
    else
      last_winner
    end

    if new_options |> Enum.empty? do
      {new_last_winner, number, boards |> Enum.fetch!(14)}
    else
      loop(new_boards, new_options, numbers, new_last_winner, i + 1)
    end
  end
end

winner = Loop.loop(boards, options, numbers, nil, 0)

IO.inspect(winner)
