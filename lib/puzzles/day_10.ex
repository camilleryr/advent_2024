defmodule Day10 do
  @moduledoc "https://adventofcode.com/2024/day/10"
  import Advent2024

  @doc ~S"""
  ## Example

    iex> part_1(test_input(:part_1_5))
    36
  """
  def_solution part_1(stream_input) do
    topo_map = parse(stream_input)

    topo_map
    |> Enum.flat_map(&find_potential_trailheads/1)
    |> find_trails(topo_map)
    |> Enum.group_by(fn [trailhead | _rest] -> trailhead end)
    |> Enum.map(fn {_trailhead, trails} ->
      trails |> Enum.map(&List.last/1) |> Enum.uniq() |> Enum.count()
    end)
    |> Enum.sum()
  end

  def find_potential_trailheads({loc, 0} = v), do: [{v, [loc]}]
  def find_potential_trailheads(_), do: []

  def find_trails(trails, map) do
    next = Enum.flat_map(trails, &find_next_step(&1, map))

    if next == trails do
      next
      |> Enum.filter(fn {{_point, final_height}, _hist} -> final_height == 9 end)
      |> Enum.map(fn {_loc, history} -> Enum.reverse(history) end)
    else
      find_trails(next, map)
    end
  end

  def find_next_step({{_, 9}, _} = finished, _map), do: [finished]

  def find_next_step({{current_location, current_heigh}, history}, map) do
    for step <- step(current_location),
        map[step] == current_heigh + 1 do
      {{step, current_heigh + 1}, [step | history]}
    end
  end

  def step({x, y}) do
    [{x + 1, y}, {x, y + 1}, {x - 1, y}, {x, y - 1}]
  end

  def parse(stream_input) do
    for {line, y} <- Enum.with_index(stream_input),
        {height, x} <-
          line |> String.codepoints() |> Enum.map(&String.to_integer/1) |> Enum.with_index(),
        into: %{} do
      {{x, y}, height}
    end
  end

  @doc ~S"""
  ## Example

    iex> part_2(test_input(:part_1_5))
    81
  """
  def_solution part_2(stream_input) do
    topo_map = parse(stream_input)

    topo_map
    |> Enum.flat_map(&find_potential_trailheads/1)
    |> find_trails(topo_map)
    |> Enum.frequencies_by(fn [trailhead | _rest] -> trailhead end)
    |> Enum.map(fn {_trailhead, number_of_trails} -> number_of_trails end)
    |> Enum.sum()
  end

  def test_input(:part_1) do
    """
    0123
    1234
    8765
    9876
    """
  end

  def test_input(:part_1_2) do
    """
    ...0...
    ...1...
    ...2...
    6543456
    7.....7
    8.....8
    9.....9
    """
  end

  def test_input(:part_1_3) do
    """
    ..90..9
    ...1.98
    ...2..7
    6543456
    765.987
    876....
    987....
    """
  end

  def test_input(:part_1_4) do
    """
    10..9..
    2...8..
    3...7..
    4567654
    ...8..3
    ...9..2
    .....01
    """
  end

  def test_input(:part_1_5) do
    """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
    """
  end
end
