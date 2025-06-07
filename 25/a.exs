defmodule Day25 do
  def parse!(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Enum.with_index()
    |> Enum.reduce(
      %{width: 0, height: 0, east: MapSet.new(), south: MapSet.new()},
      fn {line, y}, acc ->
        acc
        |> update_in([:width], &max(&1, String.length(line)))
        |> Map.update!(:height, fn _ -> y + 1 end)
        |> add_line(line, y)
      end
    )
  end

  defp add_line(acc, line, y) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(acc, fn
      {">", x}, a -> update_in(a[:east], &MapSet.put(&1, {x, y}))
      {"v", x}, a -> update_in(a[:south], &MapSet.put(&1, {x, y}))
      {_, _},  a -> a
    end)
  end

  def step(%{width: w, height: h, east: east0, south: south0} = state) do
    #########################################################
    # 1. east-facing phase  (uses *original* occupied grid) #
    #########################################################
    occupied0 = MapSet.union(east0, south0)

    {east1, moved_east?} =
      Enum.reduce(east0, {east0, false}, fn {x, y}, {east_acc, moved?} ->
        nx          = rem(x + 1, w)
        target      = {nx, y}

        if MapSet.member?(occupied0, target) do
          {east_acc, moved?}                                   # can’t move
        else
          {east_acc |> MapSet.delete({x, y}) |> MapSet.put(target), true}
        end
      end)

    ###########################################################
    # 2. south-facing phase  (uses grid *after* east moves)   #
    ###########################################################
    occupied1 = MapSet.union(east1, south0)

    {south1, moved_south?} =
      Enum.reduce(south0, {south0, false}, fn {x, y}, {south_acc, moved?} ->
        ny          = rem(y + 1, h)
        target      = {x, ny}

        if MapSet.member?(occupied1, target) do
          {south_acc, moved?}                                  # can’t move
        else
          {south_acc |> MapSet.delete({x, y}) |> MapSet.put(target), true}
        end
      end)

    ###########################################################
    # 3. assemble next state                                  #
    ###########################################################
    moved? = moved_east? or moved_south?

    {%{state | east: east1, south: south1}, moved?}
  end

  def run_until_stop(state) do
    do_run(state, 0)
  end

  # Tail-recursive worker
  defp do_run(state, n) do
    {next_state, moved?} = step(state)

    if moved? do
      do_run(next_state, n + 1)
    else
      {next_state, n + 1}   # include the final (non-moving) step
    end
  end
end

Day25.parse!("input.txt") |> Day25.run_until_stop() |> IO.inspect()
