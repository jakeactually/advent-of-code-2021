# https://www.reddit.com/r/adventofcode/comments/rl6p8y/comment/hpkxh2c/?utm_source=share&utm_medium=web2x&context=3

defmodule Game do
  def wins(_p1, _t1, _p2, t2) when t2 <= 0 do
    {0, 1}
  end

  def wins(p1, t1, p2, t2) do
    rf = [{3, 1}, {4, 3}, {5, 6}, {6, 7}, {7, 6}, {8, 3}, {9, 1}]

    Enum.reduce(rf, {0, 0}, fn {r, f}, {w1, w2} ->
      {c2, c1} = wins(p2, t2, rem(p1 + r, 10), t1 - 1 - rem(p1 + r, 10))
      {w1 + f * c1, w2 + f * c2}
    end)
  end
end

p1 = 7 - 1
p2 = 10 - 1

Game.wins(p1, 21, p2, 21)
|> Tuple.to_list()
|> Enum.max()
|> IO.inspect()
