defmodule Day6 do
  @moduledoc "https://adventofcode.com/2024/day/6"
  import Advent2024

  @doc ~S"""
  ## Example

    iex> part_1(test_input(:part_1))
    41
  """
  def_solution part_1(stream_input) do
    {map, cursor} = parse_map(stream_input)
    {:exit_map, cursors} = [cursor] |> new() |> move(cursor, map)

    count_spots(cursors)
  end

  def new(cursors), do: {MapSet.new(cursors), cursors}
  def get_set({set, _}), do: set
  def get_list({_, list}), do: list
  def update({set, list}, next), do: {MapSet.put(set, next), [next | list]}

  def count_spots(cursors) do
    cursors
    |> get_set()
    |> MapSet.new(fn {key, _val} -> key end)
    |> MapSet.size()
  end

  def move(cursor_set, {{x, y} = _point, {off_x, off_y} = _dir}, map)
      when not is_map_key(map, {x + off_x, y + off_y}),
      do: {:exit_map, cursor_set}

  def move(cursor_set, {{x, y} = point, {off_x, off_y} = dir}, map)
      when :erlang.map_get({x + off_x, y + off_y}, map) == "#" do
    next_cursor = {point, turn(dir)}

    maybe_move(cursor_set, next_cursor, map)
  end

  def move(cursor_set, {point, dir}, map) do
    next_point = apply_move(point, dir)
    next_cursor = {next_point, dir}

    maybe_move(cursor_set, next_cursor, map)
  end

  def maybe_move(cursor_set, next_cursor, map) do
    if next_cursor in get_set(cursor_set) do
      {:loop, cursor_set}
    else
      cursor_set |> update(next_cursor) |> move(next_cursor, map)
    end
  end

  def apply_move({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  @up {0, -1}
  @right {1, 0}
  @down {0, 1}
  @left {-1, 0}

  def turn(@up), do: @right
  def turn(@right), do: @down
  def turn(@down), do: @left
  def turn(@left), do: @up

  def parse_map(stream_input) do
    for {line, y_id} <- Enum.with_index(stream_input),
        {cell, x_id} <- line |> String.codepoints() |> Enum.with_index(),
        reduce: {%{}, nil} do
      {map, cursor} ->
        point = {x_id, y_id}

        if cell == "^" do
          updated_map = Map.put(map, point, "X")
          {updated_map, {point, @up}}
        else
          updated_map = Map.put(map, point, cell)
          {updated_map, cursor}
        end
    end
  end

  @doc ~S"""
  ## Example

    iex> part_2(test_input(:part_1))
    6
  """
  def_solution part_2(stream_input) do
    {map, cursor} = parse_map(stream_input)
    {:exit_map, cursors} = [cursor] |> new() |> move(cursor, map)

    cursors
    |> get_list()
    |> find_loops(map, [])
    |> count_loops()
  end

  def count_loops(tasks) do
    tasks
    |> Task.await_many()
    |> Enum.count(fn {tag, _res} -> tag == :loop end)
  end

  def find_loops([] = _cursor_list, _map, tasks), do: tasks

  def find_loops([{point, dir} = cursor | rest] = cursor_list, map, tasks) do
    next_point = apply_move(point, dir)

    tasks =
      if Map.get(map, next_point) == "." and not visited?(next_point, rest) do
        updated_map = Map.put(map, next_point, "#")
        task = Task.async(fn -> cursor_list |> new() |> move(cursor, updated_map) end)
        [task | tasks]
      else
        tasks
      end

    find_loops(rest, map, tasks)
  end

  def visited?(next_point, rest) do
    rest
    |> MapSet.new(fn {point, _dir} -> point end)
    |> MapSet.member?(next_point)
  end

  def test_input(:part_1) do
    """
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#..^.....
    ........#.
    #.........
    ......#...
    """
  end

  def test_input(:part_1_2) do
    """
    ....#.....
    ....^....#
    ..........
    ..#.......
    .......#..
    ..........
    .#........
    ........#.
    #.........
    ......#...
    """
  end

  def test_input(:part_1_3) do
    """
    ....#.....
    ........>#
    ..........
    ..#.......
    .......#..
    ..........
    .#........
    ........#.
    #.........
    ......#...
    """
  end

  def test_input(:part_1_4) do
    """
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#......v.
    ........#.
    #.........
    ......#...
    """
  end

  def test_input(:part_1_5) do
    """
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#........
    ........#.
    #.........
    ......#v..
    """
  end

  def test_input(:part_1_6) do
    """
    ....#.....
    ....XXXXX#
    ....X...X.
    ..#.X...X.
    ..XXXXX#X.
    ..X.X.X.X.
    .#XXXXXXX.
    .XXXXXXX#.
    #XXXXXXX..
    ......#X..
    """
  end
end
