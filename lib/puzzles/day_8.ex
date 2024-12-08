defmodule Day8 do
  @moduledoc "https://adventofcode.com/2024/day/8"
  import Advent2024

  @doc ~S"""
  ## Example

    iex> part_1(test_input(:part_1))
    14
  """
  def_solution part_1(stream_input) do
    selector = fn
      [_og, first | _] -> [first]
      _ -> []
    end

    do_solve(stream_input, selector)
  end

  @doc ~S"""
  ## Example

    iex> part_2(test_input(:part_1))
    34
  """
  def_solution part_2(stream_input) do
    do_solve(stream_input)
  end

  def do_solve(stream_input, selector \\ &Function.identity/1) do
    stream_input
    |> parse()
    |> find_antinodes(selector)
    |> MapSet.size()
  end

  def find_antinodes(%{min_x: x, min_y: y, max_x: xx, max_y: yy, grouped_nodes: gn}, selector) do
    x_range = x..xx
    y_range = y..yy

    for {_cell, nodes} <- gn,
        {left, right} <- permutations(nodes),
        antinode <- antinodes(left, right, x_range, y_range, selector),
        into: MapSet.new() do
      antinode
    end
  end

  def permutations(list, acc \\ [])
  def permutations([], acc), do: acc

  def permutations([head | rest], acc) do
    next_acc = for r <- rest, reduce: acc, do: (acc -> [{head, r} | acc])
    permutations(rest, next_acc)
  end

  def antinodes({lx, ly} = l, {rx, ry} = r, x_range, y_range, selector) do
    x_diff = rx - lx
    y_diff = ry - ly

    selector.(extend(l, -x_diff, -y_diff, x_range, y_range)) ++
      selector.(extend(r, x_diff, y_diff, x_range, y_range))
  end

  def extend({x, y} = p, x_diff, y_diff, x_range, y_range) do
    if x in x_range and y in y_range do
      next = {x + x_diff, y + y_diff}
      [p | extend(next, x_diff, y_diff, x_range, y_range)]
    else
      []
    end
  end

  def parse(stream_input) do
    for {line, y_idx} <- Enum.with_index(stream_input),
        {cell, x_idx} <- line |> to_charlist() |> Enum.with_index(),
        reduce: %{min_x: 0, min_y: 0, max_x: 0, max_y: 0, grouped_nodes: %{}} do
      %{min_x: x, min_y: y, max_x: xx, max_y: yy, grouped_nodes: gn} ->
        point = {x_idx, y_idx}
        updated_gn = if(cell != ?., do: Map.update(gn, cell, [point], &[point | &1]), else: gn)

        %{
          min_x: min(x, x_idx),
          min_y: min(y, y_idx),
          max_x: max(xx, x_idx),
          max_y: max(yy, y_idx),
          grouped_nodes: updated_gn
        }
    end
  end

  # {4, 4}, {7, 3}
  # {1, 5}, {10, 2}
  def test_input(:part_1) do
    """
    ............
    ........0...
    .....0....p.
    .......0....
    ....0.......
    .p....A.....
    ............
    ............
    ........A...
    .........A..
    ............
    ............
    """
  end

  def test_input(:part_1_2) do
    """
    ..........
    ...#......
    ..........
    ....a.....
    ..........
    .....a....
    ..........
    ......#...
    ..........
    ..........
    """
  end

  def test_input(:part_1_3) do
    """
    ..........
    ...#......
    #.........
    ....a.....
    ........a.
    .....a....
    ..#.......
    ......#...
    ..........
    ..........
    """
  end

  def test_input(:part_1_4) do
    """
    ..........
    ...#......
    #.........
    ....a.....
    ........a.
    .....a....
    ..#.......
    ......A...
    ..........
    ..........
    """
  end

  def test_input(:part_1_5) do
    """
    ......#....#
    ...#....0...
    ....#0....#.
    ..#....0....
    ....0....#..
    .#....A.....
    ...#........
    #......#....
    ........A...
    .........A..
    ..........#.
    ..........#.
    """
  end
end
