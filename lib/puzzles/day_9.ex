defmodule Day9 do
  @moduledoc "https://adventofcode.com/2024/day/9"
  import Advent2024
  import :erlang, only: [map_get: 2]

  @doc ~S"""
  ## Example

    iex> part_1(test_input(:part_1))
    1928
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> expand()
    |> compact()
    |> checksum()
  end

  def checksum(map) do
    Enum.reduce(map, 0, fn
      {_idx, "."}, acc -> acc
      {idx, file_id}, acc -> idx * file_id + acc
    end)
  end

  def compact(expanded) do
    {max_idx, map} =
      expanded
      |> Enum.with_index()
      |> Enum.reduce({0, %{}}, fn {value, idx}, {_max_idx, map} ->
        {idx, Map.put(map, idx, value)}
      end)

    compact(0, max_idx, map)
  end

  def compact(h_id, t_id, map) when h_id >= t_id, do: map
  def compact(h_id, t_id, m) when map_get(h_id, m) != ".", do: compact(h_id + 1, t_id, m)
  def compact(h_id, t_id, m) when map_get(t_id, m) == ".", do: compact(h_id, t_id - 1, m)

  def compact(h_id, t_id, m),
    do: compact(h_id + 1, t_id - 1, Map.merge(m, %{h_id => m[t_id], t_id => "."}))

  def expand(digits) do
    digits
    |> Enum.chunk_every(2)
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {[file, space], file_id} -> List.duplicate(file_id, file) ++ List.duplicate(".", space)
      {[file], file_id} -> List.duplicate(file_id, file)
    end)
  end

  def parse(stream_input) do
    Enum.flat_map(stream_input, fn line ->
      line |> String.codepoints() |> Enum.map(&String.to_integer/1)
    end)
  end

  @doc ~S"""
  ## Example

    iex> part_2(test_input(:part_1))
    2858
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> expand_2()
    |> compact_2()
    |> expand_3()
    |> checksum()
  end

  def expand_3(compacted) do
    compacted
    |> Enum.flat_map(fn {n, id} -> List.duplicate(id, n) end)
    |> Enum.with_index()
    |> Map.new(fn {k, v} -> {v, k} end)
  end

  def compact_2(expanded) do
    expanded
    |> Enum.reduce([], fn
      {_size, "."}, acc -> acc
      file, acc -> [file | acc]
    end)
    |> Enum.reduce(expanded, &compact_2/2)
  end

  def compact_2(file, [file | _] = remainder), do: remainder
  def compact_2(f1, [{_file_size, file_id} = f2 | rest]) when file_id != ".", do: [f2 | compact_2(f1, rest)]
  def compact_2({file_size, _} = f, [{empty_space, "."} = empty | rest]) when empty_space < file_size, do: [empty | compact_2(f, rest)]
  def compact_2({file_size, _} = f, [{file_size, "."} | rest]), do: [f | clean_up(rest, f)]
  def compact_2({file_size, _file_id} = f, [{empty_space, "."} | rest]), do: [f, {empty_space - file_size, "."} | clean_up(rest, f)]

  def clean_up(rest, {size, _id} = file) do
    Enum.map(rest, fn
      ^file -> {size, "."}
      other -> other
    end)
  end

  def expand_2(digits) do
    digits
    |> Enum.chunk_every(2)
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {[file, space], file_id} -> [{file, file_id}, {space, "."}]
      {[file], file_id} -> [{file, file_id}]
    end)
  end

  def test_input(:part_1) do
    """
    2333133121414131402
    """
  end

  def test_input(:part_1_2) do
    """
    0..111....22222
    """
  end

  def test_input(:part_1_3) do
    """
    00...111...2...333.44.5555.6666.777.888899
    """
  end

  def test_input(:part_1_4) do
    """
    0..111....22222
    02.111....2222.
    022111....222..
    0221112...22...
    02211122..2....
    022111222......
    """
  end

  def test_input(:part_1_5) do
    """
    00...111...2...333.44.5555.6666.777.888899
    009..111...2...333.44.5555.6666.777.88889.
    0099.111...2...333.44.5555.6666.777.8888..
    00998111...2...333.44.5555.6666.777.888...
    009981118..2...333.44.5555.6666.777.88....
    0099811188.2...333.44.5555.6666.777.8.....
    009981118882...333.44.5555.6666.777.......
    0099811188827..333.44.5555.6666.77........
    00998111888277.333.44.5555.6666.7.........
    009981118882777333.44.5555.6666...........
    009981118882777333644.5555.666............
    00998111888277733364465555.66.............
    0099811188827773336446555566..............
    """
  end
end
