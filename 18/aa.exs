defmodule ListZipper do
  defstruct left: [], focus: nil, right: []

  # Initialize the Zipper with a list
  def from_list([h | t]), do: %ListZipper{left: [], focus: h, right: t}
  def from_list([]), do: %ListZipper{left: [], focus: nil, right: []}

  # Move the focus one position to the left
  # can't move left
  def move_left(%ListZipper{left: [], focus: _, right: _} = zipper), do: zipper

  def move_left(%ListZipper{left: [new_focus | new_left], focus: current, right: right}) do
    %ListZipper{left: new_left, focus: new_focus, right: [current | right]}
  end

  # Move the focus one position to the right
  # can't move right
  def move_right(%ListZipper{left: _, focus: _, right: []} = zipper), do: zipper

  def move_right(%ListZipper{left: left, focus: current, right: [new_focus | new_right]}) do
    %ListZipper{left: [current | left], focus: new_focus, right: new_right}
  end

  # Convert the Zipper back to a list
  def to_list(%ListZipper{left: left, focus: focus, right: right}) do
    Enum.reverse(left) ++ [focus] ++ right
  end

  # Move left until the condition is met
  def move_left_until(zipper, {context, condition_fn}) do
    {new_context, should_stop} = condition_fn.({zipper.focus, context})

    if should_stop or zipper.left == [] do
      {zipper, new_context}
    else
      move_left(zipper)
      |> move_left_until({new_context, condition_fn})
    end
  end

  # Move right until the condition is met
  def move_right_until(zipper, {context, condition_fn}) do
    {new_context, should_stop} = condition_fn.({zipper.focus, context})

    if should_stop or zipper.right == [] do
      {zipper, new_context}
    else
      move_right(zipper)
      |> move_right_until({new_context, condition_fn})
    end
  end

  # Remove one item to the left of the focus, the focus itself, and two items to the right
  def remove_items_around_focus(%ListZipper{left: [left_item | left_rest], focus: focus, right: [right1, right2 | right_rest]}) do
    # The removed items
    removed_items = [left_item, focus, right1, right2]

    # Update the zipper: focus is now on the first item in the remaining right list
    new_zipper = %ListZipper{left: left_rest, focus: hd(right_rest), right: tl(right_rest)}

    {removed_items, new_zipper}
  end

  # Handle cases with insufficient items to remove
  def remove_items_around_focus(%ListZipper{left: _, right: right}) when length(right) < 2 do
    {:error, "Not enough items to remove"}
  end

  # Insert a new item to the left of the focus
  def insert_left(zipper = %ListZipper{left: left, focus: focus, right: right}, new_item) do
    %ListZipper{left: [new_item | left], focus: focus, right: right}
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
end

# Example usage
input_string = "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"
zipper = BracketParser.parse(input_string) |> ListZipper.from_list()

{zipper, state} = zipper
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

{[_, a, b, _], zipper} = zipper |> ListZipper.remove_items_around_focus

zipper = zipper |> ListZipper.insert_left(0) |> ListZipper.move_left
zipper = zipper |> ListZipper.add_to_nearest_left_and_right(a, b)
IO.inspect(zipper)
IO.inspect(removed_items)
