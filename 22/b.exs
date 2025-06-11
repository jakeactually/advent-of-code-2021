defmodule Day22 do
  defmodule Cuboid do
    defstruct x: nil, y: nil, z: nil, sign: 1
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  #============================================================================
  # Internal implementation
  #============================================================================

  # Parse a single input line into `{on?, cuboid}`
  defp parse_line(line) do
    [state, ranges] = String.split(line, " ")
    {x, y, z} =
      ranges
      |> String.split(",", trim: true)
      |> Enum.map(fn axis ->
        [_, r]   = String.split(axis, "=")
        [a, b]   = String.split(r, "..") |> Enum.map(&String.to_integer/1)
        {a, b}
      end)
      |> List.to_tuple()

    cuboid = %Cuboid{x: x, y: y, z: z, sign: 1}
    {state == "on", cuboid}
  end

  # Core solver using inclusion–exclusion.
  def solve(steps) do
    steps
    |> Enum.reduce([], fn {turn_on?, cuboid}, acc ->
      new_terms =
        acc
        |> Enum.map(&intersect(&1, cuboid))
        |> Enum.filter(& &1)

      acc = acc ++ new_terms

      if turn_on?, do: acc ++ [cuboid], else: acc
    end)
    |> total_volume()
  end

  #----------------------------------------------------------------------------
  # Geometry helpers
  #----------------------------------------------------------------------------

  # Intersection of two cuboids; returns a *signed* cuboid whose sign is the
  # negation of the first cuboid (for inclusion–exclusion) or `nil` if empty.
  defp intersect(c1, c2) do
    {xi, xa} = c1.x; {xj, xb} = c2.x
    {yi, ya} = c1.y; {yj, yb} = c2.y
    {zi, za} = c1.z; {zj, zb} = c2.z

    x0 = max(xi, xj); x1 = min(xa, xb)
    y0 = max(yi, yj); y1 = min(ya, yb)
    z0 = max(zi, zj); z1 = min(za, zb)

    if x0 <= x1 and y0 <= y1 and z0 <= z1 do
      %Cuboid{x: {x0, x1}, y: {y0, y1}, z: {z0, z1}, sign: -c1.sign}
    end
  end

  # Calculate the total volume (number of lit cubes).
  defp total_volume(cuboids) do
    Enum.reduce(cuboids, 0, fn %Cuboid{sign: s} = c, acc -> acc + s * volume(c) end)
  end

  # Volume of a single cuboid (ranges are inclusive).
  defp volume(%Cuboid{x: {xa, xb}, y: {ya, yb}, z: {za, zb}}) do
    (xb - xa + 1) * (yb - ya + 1) * (zb - za + 1)
  end
end

File.read!("input.txt") |> Day22.parse() |> Day22.solve() |> IO.inspect()
