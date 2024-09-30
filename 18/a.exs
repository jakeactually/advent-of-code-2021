defmodule BracketParser do
  def parse(string) do
    string
    |> String.replace("[", ":open ")
    |> String.replace("]", " :close")
    |> String.split(~r{[\s,]+}, trim: true)
    |> Enum.map(&convert/1)
  end

  defp convert(":open"), do: :open
  defp convert(":close"), do: :close
  defp convert(number_string), do: String.to_integer(number_string)

  def unparse(list) do
    list
    |> Enum.reduce("", &build_string/2)
    |> String.replace(",]", "]") # To clean up any trailing commas
    |> String.replace("][", "],[")
    |> Code.eval_string
  end

  defp build_string(:open, acc), do: acc <> "["
  defp build_string(:close, acc), do: acc <> "]"
  defp build_string(number, acc) when is_integer(number), do: acc <> "#{number},"
end

defmodule Advent do
  # Remove one item to the left of the focus, the focus itself, and two items to the right
  def remove_items_around_focus(zipper) do
    zipper = zipper |> ListZipper.prev() |> ListZipper.remove()
    a = zipper |> ListZipper.current()
    zipper = zipper |> ListZipper.remove()
    b = zipper |> ListZipper.current()
    zipper = zipper |> ListZipper.remove() |> ListZipper.remove()
    {a, b, zipper}
  end

  def try_explode(zipper) do
    {zipper, _} =
      zipper
      |> ListZipper.move_right_until({
        %{depth: 0},
        fn {item, state} ->
          new_state =
            case item do
              :open -> %{state | depth: state.depth + 1}
              :close -> %{state | depth: state.depth - 1}
              _ -> state
            end

          {new_state, state.depth == 5}
        end
      })

    case zipper.right do
      [] -> {:error, zipper |> ListZipper.go_to(0)}
      _ -> {:ok, explode(zipper) |> ListZipper.go_to(0)}
    end
  end

  def explode(zipper) do
    {a, b, zipper} = zipper |> Advent.remove_items_around_focus()
    index = zipper.index
    zipper = zipper |> ListZipper.insert(0) |> ListZipper.prev()

    {zipper, _} =
      zipper |> ListZipper.move_left_until({nil, fn {item, st} -> {st, is_number(item)} end})

    zipper =
      case zipper.left do
        [] -> zipper
        _ -> zipper |> ListZipper.replace(zipper.current + a)
      end

    zipper = zipper |> ListZipper.go_to(index) |> ListZipper.next()

    {zipper, _} =
      zipper |> ListZipper.move_right_until({nil, fn {item, st} -> {st, is_number(item)} end})

    zipper =
      case zipper.right do
        [] -> zipper
        _ -> zipper |> ListZipper.replace(zipper.current + b)
      end
  end

  def try_split(zipper) do
    {zipper, _} =
      zipper
      |> ListZipper.move_right_until({
        %{},
        fn {item, state} ->
          new_state = {state, is_number(item) and item > 9}
        end
      })

    case zipper.right do
      [] -> {:error, zipper |> ListZipper.go_to(0)}
      _ -> {:ok, split(zipper) |> ListZipper.go_to(0)}
    end
  end

  def split(zipper) do
    left = Float.ceil(zipper.current / 2) |> trunc
    right = Float.floor(zipper.current / 2) |> trunc

    zipper
    |> ListZipper.remove()
    |> ListZipper.insert(:close)
    |> ListZipper.insert(left)
    |> ListZipper.insert(right)
    |> ListZipper.insert(:open)
  end

  def reduce_zipper(zipper) do
    case try_explode(zipper) do
      {:ok, new_zipper} ->
        reduce_zipper(new_zipper)

      {:error, _} ->
        case try_split(zipper) do
          {:ok, new_zipper} ->
            reduce_zipper(new_zipper)

          {:error, _} ->
            zipper
        end
    end
  end
end

defmodule Magnitude do
  # Base case: If the element is a number, return the number
  def magnitude(n) when is_number(n), do: n

  # Recursive case: If the element is a tuple, calculate the magnitude recursively
  def magnitude({left, right}) do
    3 * magnitude(left) + 2 * magnitude(right)
  end

  # Helper function to convert lists to tuples, which is needed to handle nested lists
  def to_tuple([left, right]) do
    {to_tuple(left), to_tuple(right)}
  end

  def to_tuple(n) when is_number(n), do: n
end

# Example usage
input_string = "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"
zipper = BracketParser.parse(input_string) |> ListZipper.new()
zipper = Advent.reduce_zipper(zipper)

"input.txt"
|> File.stream!()
|> Stream.map(&String.trim/1)
|> Stream.map(&BracketParser.parse/1)
|> Stream.map(&ListZipper.new/1)
|> Enum.reduce(fn a, b ->
  zipper =
    [:open | b |> ListZipper.to_list()] ++
      ListZipper.to_list(a) ++ [:close]

  zipper
  |> ListZipper.new()
  |> Advent.reduce_zipper()
end)
|> ListZipper.to_list
|> BracketParser.unparse()
|> elem(0)
|> Magnitude.to_tuple()
|> Magnitude.magnitude()
|> IO.inspect(charlists: false)
