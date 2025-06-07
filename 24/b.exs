# https://www.reddit.com/r/adventofcode/comments/rnejv5/comment/hpsjfis/

Code.require_file("util.ex", __DIR__)

add_x = [12, 12, 12, -9, -9, 14, 14, -10, 15, -2, 11, -15, -9, -3]
div_z = [1, 1, 1, 26, 26, 1, 1, 26, 1, 26, 1, 26, 26, 26]
add_y = [9, 4, 2, 5, 1, 6, 11, 15, 7, 12, 15, 9, 12, 12]
input = [1, 6, 8, 1, 1, 4, 1, 2, 1, 6, 1, 1, 1, 7]

Util.validate(input, add_x, div_z, add_y) |> IO.inspect()
