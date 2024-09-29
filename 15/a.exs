defmodule MatrixPath do
  def read_matrix(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
  end

  # Main function to find the shortest path sum from the top-left to the bottom-right corner
  def shortest_path_sum(matrix) do
    start_pos = {0, 0}
    end_pos = {length(matrix) - 1, length(List.first(matrix)) - 1}

    # Call Dijkstra algorithm to compute the shortest path sum
    dijkstra(matrix, start_pos, end_pos)
  end

  # Dijkstra's algorithm to find the minimum path sum
  defp dijkstra(matrix, start_pos, end_pos) do
    initial_distance_map = %{start_pos => hd(hd(matrix))} # Start with top-left value
    unvisited = [{start_pos, 0}]
    visited = %{}

    dijkstra(matrix, unvisited, visited, initial_distance_map, end_pos)
  end

  defp dijkstra(_, [], _, distance_map, end_pos) do
    Map.get(distance_map, end_pos)
  end

  defp dijkstra(matrix, [{pos, _} | rest], visited, distance_map, end_pos) do
    if pos == end_pos do
      Map.get(distance_map, end_pos)
    else
      neighbors = get_neighbors(pos, matrix)
      updated_data = Enum.reduce(neighbors, {distance_map, rest}, fn neighbor, {dist_map, unvisited} ->
        new_dist = Map.get(dist_map, pos) + get_value(matrix, neighbor)
        if !Map.has_key?(visited, neighbor) and (not Map.has_key?(dist_map, neighbor) or new_dist < Map.get(dist_map, neighbor)) do
          {Map.put(dist_map, neighbor, new_dist), [{neighbor, new_dist} | unvisited]}
        else
          {dist_map, unvisited}
        end
      end)

      {updated_distance_map, updated_unvisited} = updated_data
      visited = Map.put(visited, pos, true)
      dijkstra(matrix, Enum.sort_by(updated_unvisited, &elem(&1, 1)), visited, updated_distance_map, end_pos)
    end
  end

  # Helper to get the value of a matrix at a specific position
  defp get_value(matrix, {row, col}) do
    Enum.at(Enum.at(matrix, row), col)
  end

  # Helper to find valid neighbors of the current position in the matrix
  defp get_neighbors({row, col}, matrix) do
    rows = length(matrix)
    cols = length(List.first(matrix))

    # All possible moves (right, down, left, up)
    [{row + 1, col}, {row, col + 1}, {row - 1, col}, {row, col - 1}]
    |> Enum.filter(fn {r, c} -> r >= 0 and r < rows and c >= 0 and c < cols end) # Ensure within bounds
  end
end

# Example usage:

# Assuming "matrix.txt" has the following content:
# 131
# 251
# 111

matrix = MatrixPath.read_matrix("input.txt")
shortest_sum = MatrixPath.shortest_path_sum(matrix)
IO.inspect(shortest_sum)

# Output (for the above example matrix would be):
# 7 (1 → 3 → 1 → 1 → 1)
