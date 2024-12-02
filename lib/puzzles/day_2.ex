defmodule Day2 do
  @moduledoc "https://adventofcode.com/2024/day/2"
  import Advent2024

  @doc ~S"""
  ## Example
    The levels are either all increasing or all decreasing.
    Any two adjacent levels differ by at least one and at most three.

    iex> part_1(test_input(:part_1))
    2
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> Enum.count(&safe?/1)
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    4
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> Enum.count(&safe?(&1, dampener_enabled: true))
  end

  def safe?([first, second | _rest] = report, opts \\ []) do
    dampener_enabled = Keyword.get(opts, :dampener_enabled, false)
    diff_fun = if(first > second, do: fn a, b -> a - b end, else: fn a, b -> b - a end)

    case check_pairs(report, diff_fun) do
      false when dampener_enabled == true ->
        report
        |> List.duplicate(length(report))
        |> Enum.with_index()
        |> Enum.map(fn {report, idx} -> List.delete_at(report, idx) end)
        |> Enum.find_value(&safe?/1)

      other ->
        other
    end
  end

  def check_pairs([first | [second | _] = rest], diff_fun) do
    diff_fun.(first, second) in 1..3 && check_pairs(rest, diff_fun)
  end

  def check_pairs(_end, _diff_fun), do: true

  def parse(stream) do
    Enum.map(stream, fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def test_input(:part_1) do
    """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
    """
  end
end
