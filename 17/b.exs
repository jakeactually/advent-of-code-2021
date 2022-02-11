# target area: x=94..151, y=-156..-103

defmodule Curve do
  def curve {x, y, vx, vy}, {x1, x2, y1, y2} do
    cond do
      x > x2 || y < y1 -> nil
      x >= x1 && x <= x2 && y >= y1 && y <= y2 -> [{x, y, vx, vy}]
      true ->
        box = {x1, x2, y1, y2}

        moved = {
          x + vx,
          y + vy,
          vx + cond do
            vx > 0 -> -1
            vx < 0 -> 1
            true -> 0
          end,
          vy - 1
        }

        next = curve(moved, box)

        if next do
          [{x, y, vx, vy} | next]
        else
          nil
        end
    end
  end
end

heights =
  -200..200 |> Enum.flat_map(fn y ->
    -200..200 |> Enum.map(fn x ->
      Curve.curve({0, 0, x, y}, {94, 151, -156, -103})
    end)
  end)
  |> Enum.reject(&(&1 == nil))
  |> Enum.map(fn x -> x |> Enum.max_by(&elem(&1, 1)) end)

heights
  |> length
  |> IO.inspect
