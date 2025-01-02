defmodule ScannerParser do
  @moduledoc """
  Parses a file containing scanner data into structured data.
  """

  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n\n") # Split blocks by empty lines
    |> Enum.map(&parse_scanner_block/1)
  end

  defp parse_scanner_block(block) do
    [header | coordinates] = String.split(block, "\n", trim: true)
    scanner_id = parse_scanner_header(header)
    parsed_coordinates = Enum.map(coordinates, &parse_coordinates/1)

    %{scanner_id: scanner_id, beacons: parsed_coordinates}
  end

  defp parse_scanner_header(header) do
    [_, scanner_id] = Regex.run(~r/--- scanner (\d+) ---/, header)
    String.to_integer(scanner_id)
  end

  defp parse_coordinates(line) do
    line
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end
end

defmodule Vector3 do
  # Function to calculate Manhattan distance between two 3D vectors
  def manhattan_distance({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end

  # Function to compute the desired map
  def distances_map(vectors) do
    # Generate the map where each vector is the key
    Enum.reduce(vectors, %{}, fn vector, acc ->
      # Calculate the Manhattan distances to all other vectors
      distances =
        vectors
        |> Enum.reject(&(&1 == vector)) # Exclude the current vector itself
        |> Enum.map(&manhattan_distance(vector, &1))
        |> Enum.sort() # Sort the distances

      # Add the key-value pair to the map
      Map.put(acc, vector, distances)
    end)
  end
end
