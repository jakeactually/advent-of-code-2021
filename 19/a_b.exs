defmodule Day19 do
  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn block ->
      block
      |> String.split("\n", trim: true)
      |> tl() # drop the header line "--- scanner N ---"
      |> Enum.map(fn line ->
        line
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
    end)
  end

  def solve(input) do
    scanners = parse(input)
    {beacons, positions} = align_scanners(scanners)
    {
      MapSet.size(beacons),     # Part 1
      max_manhattan(positions)  # Part 2
    }
  end

  # Breadth‑first alignment of every scanner relative to scanner 0.
  defp align_scanners([base | rest]) do
    beacons   = MapSet.new(base)
    positions = %{0 => {0, 0, 0}}
    unmatched = Enum.with_index(rest, 1) |> Map.new(fn {b, i} -> {i, b} end)
    resolve(beacons, positions, unmatched)
  end

  defp resolve(beacons, positions, unmatched) when map_size(unmatched) == 0,
    do: {beacons, positions}

  defp resolve(beacons, positions, unmatched) do
    {id, placed, offset} =
      Enum.find_value(unmatched, fn {id, scanner} ->
        case locate(scanner, beacons) do
          {:ok, p, o} -> {id, p, o}
          :error -> nil
        end
      end) || raise "No alignment found—input might be malformed."

    resolve(
      MapSet.union(beacons, MapSet.new(placed)),
      Map.put(positions, id, offset),
      Map.delete(unmatched, id)
    )
  end

  # Attempts to align one scanner against the current global beacon set.
  defp locate(scanner, global_beacons) do
    rotations()
    |> Enum.find_value(fn rot ->
      rotated = Enum.map(scanner, rot)
      offsets = for p1 <- rotated, p2 <- global_beacons, do: diff(p2, p1)

      case Enum.find(offsets, fn off ->
             rotated
             |> Enum.map(&add(&1, off))
             |> Enum.count(&MapSet.member?(global_beacons, &1)) >= 12
           end) do
        nil -> nil
        off ->
          placed = Enum.map(rotated, &add(&1, off))
          {:ok, placed, off}
      end
    end) || :error
  end

  defp rotations do
    [
      fn {x, y, z} -> { x,  y,  z} end,
      fn {x, y, z} -> { x,  z, -y} end,
      fn {x, y, z} -> { x, -y, -z} end,
      fn {x, y, z} -> { x, -z,  y} end,
      fn {x, y, z} -> {-x,  y, -z} end,
      fn {x, y, z} -> {-x,  z,  y} end,
      fn {x, y, z} -> {-x, -y,  z} end,
      fn {x, y, z} -> {-x, -z, -y} end,
      fn {x, y, z} -> { y,  x, -z} end,
      fn {x, y, z} -> { y,  z,  x} end,
      fn {x, y, z} -> { y, -x,  z} end,
      fn {x, y, z} -> { y, -z, -x} end,
      fn {x, y, z} -> {-y,  x,  z} end,
      fn {x, y, z} -> {-y,  z, -x} end,
      fn {x, y, z} -> {-y, -x, -z} end,
      fn {x, y, z} -> {-y, -z,  x} end,
      fn {x, y, z} -> { z,  x,  y} end,
      fn {x, y, z} -> { z,  y, -x} end,
      fn {x, y, z} -> { z, -x, -y} end,
      fn {x, y, z} -> { z, -y,  x} end,
      fn {x, y, z} -> {-z,  x, -y} end,
      fn {x, y, z} -> {-z,  y,  x} end,
      fn {x, y, z} -> {-z, -x,  y} end,
      fn {x, y, z} -> {-z, -y, -x} end
    ]
  end

  # --------------------------------------------------------
  # Vector helpers
  # --------------------------------------------------------
  defp add({a, b, c}, {x, y, z}),   do: {a + x, b + y, c + z}
  defp diff({a, b, c}, {x, y, z}),  do: {a - x, b - y, c - z}
  defp manhattan({a, b, c}, {x, y, z}), do: abs(a - x) + abs(b - y) + abs(c - z)

  # Pair‑wise maximum Manhattan distance between scanner positions.
  defp max_manhattan(pos_map) do
    positions = Map.values(pos_map)

    positions
    |> Enum.with_index()
    |> Enum.flat_map(fn {p1, idx} ->
      positions
      |> Enum.drop(idx + 1)
      |> Enum.map(&manhattan(p1, &1))
    end)
    |> Enum.max()
  end
end

File.read!("input.txt")
  |> Day19.solve()
  |> IO.inspect()
