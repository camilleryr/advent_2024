defmodule Day1 do
  @moduledoc "https://adventofcode.com/2024/day/1"
  import Advent2024

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    11
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> then(fn {left, right} ->
      left
      |> Enum.sort()
      |> Enum.zip(Enum.sort(right))
    end)
    |> Enum.map(fn {l, r} -> max(l, r) - min(l, r) end)
    |> Enum.sum()
  end

  def parse(stream) do
    Enum.reduce(stream, {[], []}, fn line, {left, right} ->
      [l_str, r_str] = String.split(line, " ", trim: true)
      {[String.to_integer(l_str) | left], [String.to_integer(r_str) | right]}
    end)
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    31
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> then(fn {left, right} ->
      r_freq = Enum.frequencies(right)

      Enum.map(left, fn n -> Map.get(r_freq, n, 0) * n end)
    end)
    |> Enum.sum()
  end

  def test_input(:part_1) do
    """
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
    """
  end
end
