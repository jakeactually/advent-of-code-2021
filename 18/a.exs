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
end

defmodule Advent do
  # Remove one item to the left of the focus, the focus itself, and two items to the right
  def remove_items_around_focus(zipper) do
    zipper = zipper |> ListZipper.prev()
    zipper = zipper |> ListZipper.remove()
    a = zipper |> ListZipper.current()
    zipper = zipper |> ListZipper.remove()
    b = zipper |> ListZipper.current()
    zipper = zipper |> ListZipper.remove()
    zipper = zipper |> ListZipper.remove()
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
end

# Example usage
input_string = "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"
zipper = BracketParser.parse(input_string) |> ListZipper.new()
{_, zipper} = Advent.try_explode(zipper)
{_, zipper} = Advent.try_explode(zipper)

IO.inspect(zipper)
