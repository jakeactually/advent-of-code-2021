# https://www.reddit.com/r/adventofcode/comments/rnejv5/comment/hpsjfis/

Code.require_file("util.ex", __DIR__)

add_x = [12, 12, 12, -9, -9, 14, 14, -10, 15, -2, 11, -15, -9, -3]
div_z = [1, 1, 1, 26, 26, 1, 1, 26, 1, 26, 1, 26, 26, 26]
add_y = [9, 4, 2, 5, 1, 6, 11, 15, 7, 12, 15, 9, 12, 12]
input = [3, 9, 9, 2, 4, 9, 8, 9, 4, 9, 9, 9, 6, 9]

Util.validate(input, add_x, div_z, add_y) |> IO.inspect()
