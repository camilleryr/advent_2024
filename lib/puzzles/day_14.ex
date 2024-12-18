defmodule Day14 do
  @moduledoc "https://adventofcode.com/2024/day/14"
  import Advent2024

  def_solution part_1(stream_input) do
    do_solve_pt1(stream_input, 101, 103)
  end

  @doc ~S"""
  ## Example

    iex> do_solve_pt1(test_input(:part_1), 11, 7)
    12
  """
  def do_solve_pt1(stream_input, width, height) do
    mx = div(width, 2)
    my = div(height, 2)

    quarters =
      %{
        q1: {0..(mx - 1), 0..(my - 1)},
        q2: {(mx + 1)..(width - 1), 0..(my - 1)},
        q3: {0..(mx - 1), (my + 1)..(height - 1)},
        q4: {(mx + 1)..(width - 1), (my + 1)..(height - 1)}
      }

    stream_input
    |> Enum.map(&parse_line/1)
    |> Enum.map(&move(&1, 100, width, height))
    |> Enum.reduce(%{q1: 0, q2: 0, q3: 0, q4: 0}, fn {x, y}, acc ->
      case Enum.find_value(quarters, fn {key, {x_range, y_range}} ->
             if x in x_range and y in y_range do
               key
             end
           end) do
        nil -> acc
        quarter -> Map.update!(acc, quarter, &(&1 + 1))
      end
    end)
    |> Map.values()
    |> Enum.reduce(&Kernel.*/2)
  end

  def_solution part_2(stream_input) do
    do_solve_pt2(stream_input, 101, 103)
  end

  def do_solve_pt2(stream_input, width, height) do
    points = Enum.map(stream_input, &parse_line/1)

    move_and_print(0, points, width, height)
  end

  def move_and_print(s, p, w, h) do
    p
    |> Enum.map(&move(&1, s, w, h))
    |> then(fn points ->
      points = MapSet.new(points)

      if Enum.any?(points, fn point ->
           Enum.all?(neighbors(point), &MapSet.member?(points, &1))
         end) do
        IO.inspect(s, label: "seconds:")
        Advent2024.print_grid(Enum.frequencies(points), min_max: {0, w - 1, 0, h - 1})
      else
        move_and_print(s + 1, p, w, h)
      end
    end)
  end

  def neighbors({x, y}) do
    for nx <- (x - 1)..(x + 1),
        ny <- (y - 1)..(y + 1) do
      {nx, ny}
    end
  end

  def parse_line(line) do
    [px, py, vx, vy] =
      line
      |> String.split(["p=", ",", " v="], trim: true)
      |> Enum.map(&String.to_integer/1)

    {{px, py}, {vx, vy}}
  end

  @doc ~S"""
  ## Example

    iex> move({{2, 4}, {2, -3}}, 1, 11, 7)
    {4, 1}

    iex> move({{2, 4}, {2, -3}}, 2, 11, 7)
    {6, 5}

    iex> move({{2, 4}, {2, -3}}, 3, 11, 7)
    {8, 2}

    iex> move({{2, 4}, {2, -3}}, 4, 11, 7)
    {10, 6}

    iex> move({{2, 4}, {2, -3}}, 5, 11, 7)
    {1, 3}
  """
  def move({{px, py}, {vx, vy}}, seconds, width, height) do
    x = do_move(px, vx, seconds, width)
    y = do_move(py, vy, seconds, height)

    {x, y}
  end

  def do_move(p, v, s, m) do
    case rem(p + v * s, m) do
      r when r >= 0 -> r
      r -> m + r
    end
  end

  def test_input(:part_1) do
    """
    p=0,4 v=3,-3
    p=6,3 v=-1,-3
    p=10,3 v=-1,2
    p=2,0 v=2,-1
    p=0,0 v=1,3
    p=3,0 v=-2,-2
    p=7,6 v=-1,-3
    p=3,0 v=-1,-2
    p=9,3 v=2,3
    p=7,3 v=-1,2
    p=2,4 v=2,-3
    p=9,5 v=-3,-3
    """
  end

  def test_input(:part_1_2) do
    """
    1.12.......
    ...........
    ...........
    ......11.11
    1.1........
    .........1.
    .......1...
    """
  end

  def test_input(:part_1_3) do
    """
    Initial state:
    ...........
    ...........
    ...........
    ...........
    ..1........
    ...........
    ...........

    After 1 second:
    ...........
    ....1......
    ...........
    ...........
    ...........
    ...........
    ...........

    After 2 seconds:
    ...........
    ...........
    ...........
    ...........
    ...........
    ......1....
    ...........

    After 3 seconds:
    ...........
    ...........
    ........1..
    ...........
    ...........
    ...........
    ...........

    After 4 seconds:
    ...........
    ...........
    ...........
    ...........
    ...........
    ...........
    ..........1

    After 5 seconds:
    ...........
    ...........
    ...........
    .1.........
    ...........
    ...........
    ...........
    """
  end

  def test_input(:part_1_4) do
    """
    ......2..1.
    ...........
    1..........
    .11........
    .....1.....
    ...12......
    .1....1....
    """
  end

  def test_input(:part_1_5) do
    """
    ..... 2..1.
    ..... .....
    1.... .....

    ..... .....
    ...12 .....
    .1... 1....
    """
  end
end
