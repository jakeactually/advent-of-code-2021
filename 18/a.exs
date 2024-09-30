defmodule ListZipper do
  defstruct left: [], focus: nil, right: []

  # Initialize the Zipper with a list
  def from_list([h | t]), do: %ListZipper{left: [], focus: h, right: t}
  def from_list([]), do: %ListZipper{left: [], focus: nil, right: []}

  # Move the focus one position to the left
  def move_left(%ListZipper{left: [], focus: _, right: _} = zipper), do: zipper # can't move left
  def move_left(%ListZipper{left: [new_focus | new_left], focus: current, right: right}) do
    %ListZipper{left: new_left, focus: new_focus, right: [current | right]}
  end

  # Move the focus one position to the right
  def move_right(%ListZipper{left: _, focus: _, right: []} = zipper), do: zipper # can't move right
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
zipper = BracketParser.parse(input_string) |> ListZipper.from_list
zipper
  |> ListZipper.move_right_until({{}, fn {item, state} -> {state, item == 4} end})
  |> IO.inspect
