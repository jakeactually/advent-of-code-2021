defmodule Util do
  def hexa do
    %{
      "0" => [0, 0, 0, 0],
      "1" => [0, 0, 0, 1],
      "2" => [0, 0, 1, 0],
      "3" => [0, 0, 1, 1],
      "4" => [0, 1, 0, 0],
      "5" => [0, 1, 0, 1],
      "6" => [0, 1, 1, 0],
      "7" => [0, 1, 1, 1],
      "8" => [1, 0, 0, 0],
      "9" => [1, 0, 0, 1],
      "A" => [1, 0, 1, 0],
      "B" => [1, 0, 1, 1],
      "C" => [1, 1, 0, 0],
      "D" => [1, 1, 0, 1],
      "E" => [1, 1, 1, 0],
      "F" => [1, 1, 1, 1],
    }
  end

  def packet [v1, v2, v3, t1, t2, t3 | body] do
    version = parse [v1, v2, v3]
    op = parse [t1, t2, t3]

    if [t1, t2, t3] == [1, 0, 0] do
      {value, size, next} = literal body
      {{version, parse(value)}, size + 6, next}
    else
      {value, size, next} = operator body
      {{version, op, value}, size + 6, next}
    end
  end

  def parse bits do
    bits |> Enum.join |> Integer.parse(2) |> elem(0)
  end

  def literal [continue, b1, b2, b3, b4 | rest] do
    if continue == 1 do
      {value, size, next} = literal rest
      {[b1, b2, b3, b4 | value], size + 5, next}
    else
      {[b1, b2, b3, b4], 5, rest}
    end
  end

  def operator [flag | rest] do
    if flag == 1 do
      goal_len = rest |> Enum.take(11) |> parse
      {values, size, next} = by_len(rest |> Enum.drop(11), 0, goal_len, 0)
      {values, size + 12, next}
    else
      goal_size = rest |> Enum.take(15) |> parse
      {values, size, next} = by_size(rest |> Enum.drop(15), 0, goal_size)
      {values, size + 16, next}
    end
  end

  def by_size bits, acc_size, goal_size  do
    {value, size, next} = packet bits
    current_size = acc_size + size

    if current_size >= goal_size do
      {[value], current_size, next}
    else
      {values, size, next} = by_size(next, current_size, goal_size)
      {[value | values], size, next}
    end
  end

  def by_len bits, acc_len, goal_len, acc_size  do
    {value, size, next} = packet bits
    current_size = acc_size + size
    current_len = acc_len + 1

    if current_len >= goal_len do
      {[value], current_size, next}
    else
      {values, size, next} = by_len(next, current_len, goal_len, current_size)
      {[value | values], size, next}
    end
  end

  def sum {version, _, value} do
    version + (value |> Enum.map(&sum/1) |> Enum.sum)
  end

  def sum {version, _} do
    version
  end
end
