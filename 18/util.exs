defmodule ListZipper do
  defstruct left: [], current: nil, right: [], index: 0

  # Create a new Zipper from a list
  def new([h | t]), do: %ListZipper{left: [], current: h, right: t, index: 0}
  def new([]), do: %ListZipper{left: [], current: nil, right: [], index: -1}

  # Move the cursor to the next element (if exists)
  def next(%ListZipper{left: left, current: current, right: [r | rs], index: idx}) do
    %ListZipper{left: [current | left], current: r, right: rs, index: idx + 1}
  end

  # If there's no next, return the same zipper
  def next(zipper), do: zipper

  # Move the cursor to the previous element (if exists)
  def prev(%ListZipper{left: [l | ls], current: current, right: right, index: idx}) do
    %ListZipper{left: ls, current: l, right: [current | right], index: idx - 1}
  end

  # If there's no prev, return the same zipper
  def prev(zipper), do: zipper

  # Get the current element
  def current(%ListZipper{current: current}), do: current

  # Replace the current element
  def replace(%ListZipper{} = zipper, new_elem) do
    %ListZipper{zipper | current: new_elem}
  end

  # Insert an element at the current position
  def insert(%ListZipper{left: left, current: current, right: right, index: idx}, new_elem) do
    %ListZipper{left: left, current: new_elem, right: [current | right], index: idx}
  end

  # Remove the current element and move to the next one
  def remove(%ListZipper{left: left, right: [r | rs], index: idx}) do
    %ListZipper{left: left, current: r, right: rs, index: idx}
  end

  def remove(%ListZipper{left: left, right: [], index: idx}) when length(left) > 0 do
    [new_current | new_left] = Enum.reverse(left)
    %ListZipper{left: new_left, current: new_current, right: [], index: idx - 1}
  end

  # No elements to remove
  def remove(zipper), do: zipper

  # Move left until the condition is met
  def move_left_until(zipper, {context, condition_fn}) do
    {new_context, should_stop} = condition_fn.({zipper.current, context})

    if should_stop or zipper.left == [] do
      {zipper, new_context}
    else
      prev(zipper)
      |> move_left_until({new_context, condition_fn})
    end
  end

  # Move right until the condition is met
  def move_right_until(zipper, {context, condition_fn}) do
    {new_context, should_stop} = condition_fn.({zipper.current, context})

    if should_stop or zipper.right == [] do
      {zipper, new_context}
    else
      next(zipper)
      |> move_right_until({new_context, condition_fn})
    end
  end

  # Move to a specific index n
  def go_to(%ListZipper{index: idx} = zipper, n) when n == idx do
    zipper
  end

  def go_to(%ListZipper{index: idx} = zipper, n) when n > idx do
    zipper |> next() |> go_to(n)
  end

  def go_to(%ListZipper{index: idx} = zipper, n) when n < idx do
    zipper |> prev() |> go_to(n)
  end

  # If n is out of bounds, return zipper unchanged
  def go_to(zipper, _n), do: zipper

  def to_list(%ListZipper{left: left, current: current, right: right}) do
    left ++ [current | right]
  end
end

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
    # To clean up any trailing commas
    |> String.replace(",]", "]")
    |> String.trim(",")
    |> Code.eval_string()
  end

  defp build_string(:open, acc), do: acc <> "["
  defp build_string(:close, acc), do: acc <> "],"
  defp build_string(number, acc) when is_integer(number), do: acc <> "#{number},"
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
          {state, is_number(item) and item > 9}
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
