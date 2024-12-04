defmodule Day4 do
  @moduledoc "https://adventofcode.com/2024/day/4"
  import Advent2024

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1_2))
    18
  """
  def_solution part_1(stream_input) do
    {map, xs} = parse(stream_input, "X")

    xs
    |> Enum.map(&xmases(&1, map))
    |> Enum.sum()
  end

  @expected_pt1 ~w"X M A S"

  def xmases(loc, map) do
    loc
    |> expand()
    |> Enum.count(fn locs ->
      Enum.map(locs, &Map.get(map, &1)) == @expected_pt1
    end)
  end

  def expand({x, y}) do
    [
      # Right
      [{x, y}, {x + 1, y}, {x + 2, y}, {x + 3, y}],
      # Diag Down Right
      [{x, y}, {x + 1, y + 1}, {x + 2, y + 2}, {x + 3, y + 3}],
      # Down
      [{x, y}, {x, y + 1}, {x, y + 2}, {x, y + 3}],
      # Diag Down Left
      [{x, y}, {x - 1, y + 1}, {x - 2, y + 2}, {x - 3, y + 3}],
      # Left
      [{x, y}, {x - 1, y}, {x - 2, y}, {x - 3, y}],
      # Diag Up Left
      [{x, y}, {x - 1, y - 1}, {x - 2, y - 2}, {x - 3, y - 3}],
      # Up
      [{x, y}, {x, y - 1}, {x, y - 2}, {x, y - 3}],
      # Diag Up Right
      [{x, y}, {x + 1, y - 1}, {x + 2, y - 2}, {x + 3, y - 3}]
    ]
  end

  def parse(stream_input, to_find) do
    for {line, y_id} <- Enum.with_index(stream_input),
        {cell, x_id} <- line |> String.codepoints() |> Enum.with_index(),
        reduce: {%{}, []} do
      {map, xs} ->
        loc = {x_id, y_id}
        updated_xs = if cell == to_find, do: [loc | xs], else: xs
        {Map.put(map, loc, cell), updated_xs}
    end
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
  """
  def_solution part_2(stream_input) do
    {map, ms} = parse(stream_input, "M")

    ms
    |> Enum.flat_map(&x_mases(&1, map))
    |> Enum.uniq()
    |> Enum.count()
  end

  @expected_pt2 [~w"M A S", ~w"S A M"]

  def x_mases(loc, map) do
    loc
    |> expand_pt2()
    |> Enum.filter(fn {first, second} ->
      Enum.map(first, &Map.get(map, &1)) in @expected_pt2 and
        Enum.map(second, &Map.get(map, &1)) in @expected_pt2
    end)
    |> Enum.map(fn {first, second} -> MapSet.new(first ++ second) end)
  end

  def expand_pt2({x, y}) do
    [
      # Diag Down Right
      {[{x, y}, {x + 1, y + 1}, {x + 2, y + 2}], [{x + 2, y}, {x + 1, y + 1}, {x, y + 2}]},
      # Diag Down Left
      {[{x, y}, {x - 1, y + 1}, {x - 2, y + 2}], [{x - 2, y}, {x - 1, y + 1}, {x, y + 2}]},
      # Diag Up Left
      {[{x, y}, {x - 1, y - 1}, {x - 2, y - 2}], [{x - 2, y}, {x - 1, y - 1}, {x, y - 2}]},
      # Diag Up Right
      {[{x, y}, {x + 1, y - 1}, {x + 2, y - 2}], [{x + 2, y}, {x + 1, y - 1}, {x, y - 2}]}
    ]
  end

  def test_input(:part_1) do
    """
    ..X...
    .SAMX.
    .A..A.
    XMAS.S
    .X....
    """
  end

  def test_input(:part_1_2) do
    """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """
  end

  def test_input(:part_1_3) do
    """
    ....XXMAS.
    .SAMXMS...
    ...S..A...
    ..A.A.MS.X
    XMASAMX.MM
    X.....XA.A
    S.S.S.S.SS
    .A.A.A.A.A
    ..M.M.M.MM
    .X.X.XMASX
    """
  end
end
