defmodule Util do
  def validate(input, add_x, div_z, add_y) do
    validate(input, add_x, div_z, add_y, 0, 0, 0)
  end

  defp validate([], _add_x, _div_z, _add_y, _i, z, _x), do: z

  defp validate([w | rest], add_x, div_z, add_y, i, z, _x) do
    x = rem(z, 26) + Enum.at(add_x, i)
    z =
      if Enum.at(div_z, i) != 1 do
        div(z, 26)
      else
        z
      end

    z =
      if x != w do
        z * 26 + w + Enum.at(add_y, i)
      else
        z
      end

    IO.puts("#{w} #{Enum.at(add_x, i)} #{x} #{z}")

    validate(rest, add_x, div_z, add_y, i + 1, z, x)
  end
end
