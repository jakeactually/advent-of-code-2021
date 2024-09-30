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
