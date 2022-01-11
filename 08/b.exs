defmodule Util do
  def partition(xs, f) do
    {
      xs |> Enum.find(f),
      xs |> Enum.reject(f)
    }
  end

  def set_size(n) do
    fn set -> MapSet.size(set) == n end
  end

  def size_and_subset(n, subset) do
    fn set -> MapSet.size(set) == n && MapSet.subset?(subset, set) end
  end

  def tokenize(str) do
    str
      |> String.split(" ")
      |> Enum.map(fn word ->
        word
          |> String.split("")
          |> Enum.filter(&(&1 != ""))
          |> MapSet.new
      end)
  end
end

defmodule Solve do
  def solve(string) do
    [left, right] = String.split(string, " | ")

    sets = Util.tokenize(left)
    code = Util.tokenize(right)

    { one, sets } = sets
      |> Util.partition(Util.set_size(2))

    { four, sets } = sets
      |> Util.partition(Util.set_size(4))

    { seven, sets } = sets
      |> Util.partition(Util.set_size(3))

    { eight, sets } = sets
      |> Util.partition(Util.set_size(7))

    { nine, sets } = sets
      |> Util.partition(Util.size_and_subset(6, four))

    { zero, sets } = sets
      |> Util.partition(Util.size_and_subset(6, one))

    { six, sets } = sets
      |> Util.partition(Util.set_size(6))

    { three, sets } = sets
      |> Util.partition(Util.size_and_subset(5, one))

    { five, sets } = sets
      |> Util.partition(fn set -> MapSet.size(set) == 5 && MapSet.subset?(set, six) end)

    [two] = sets

    map = %{
      zero => 0,
      one => 1,
      two => 2,
      three => 3,
      four => 4,
      five => 5,
      six => 6,
      seven => 7,
      eight => 8,
      nine => 9,
    }

    code
      |> Enum.map(fn set -> Map.fetch!(map, set) end)
      |> Enum.reverse
      |> Enum.with_index
      |> Enum.map(fn {n, i} -> n * :math.pow(10, i) end)
      |> Enum.reduce(&(&1 + &2))
  end
end

{:ok, text} = File.read("input.txt")

text
  |> String.split("\n")
  |> Enum.filter(&(&1 != ""))
  |> Enum.map(&Solve.solve/1)
  |> Enum.reduce(&(&1 + &2))
  |> IO.inspect
