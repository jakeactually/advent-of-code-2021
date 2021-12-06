{:ok, text} = File.read("input.txt")

nums = text
  |> String.split("\n")
  |> Enum.filter( &(&1 != "") )
  |> Enum.map( &Integer.parse/1 )
  |> Enum.map(fn {x, _} -> x end)

diff = 3..Enum.count(nums) - 1
  |> Enum.map(fn i -> { Enum.fetch(nums, i), Enum.fetch(nums, i - 1), Enum.fetch(nums, i - 2), Enum.fetch(nums, i - 3) } end)
  |> Enum.map(fn {{_, a}, {_, b}, {_, c}, {_, d}} -> (a + b + c) - (b + c + d) end)
  |> Enum.filter( &(&1 > 0) )
  |> Enum.count

IO.inspect(diff)
