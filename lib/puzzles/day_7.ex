defmodule Day7 do
  @moduledoc "https://adventofcode.com/2024/day/7"
  import Advent2024

  @doc ~S"""
  ## Example

    iex> part_1(test_input(:part_1))
    3749
  """
  def_solution part_1(stream_input) do
    find_solution(stream_input, [&Kernel.+/2, &Kernel.*/2])
  end

  def find_solution(stream_input, operations) do
    Enum.reduce(stream_input, 0, fn line, acc ->
      {test_value, remaining} = parse_line(line)

      if correct?(test_value, remaining, operations) do
        acc + test_value
      else
        acc
      end
    end)
  end

  def correct?(test_value, [test_value], _), do: true
  def correct?(_test_value, [_acc], _), do: false
  def correct?(test_value, [acc | _], _) when acc > test_value, do: false

  def correct?(test_value, [acc, next | rest], operations) do
    Enum.any?(operations, fn op -> correct?(test_value, [op.(acc, next) | rest], operations) end)
  end

  def parse_line(line) do
    [test_value | remaining] =
      line
      |> String.split([":", " "], trim: true)
      |> Enum.map(&String.to_integer/1)

    {test_value, remaining}
  end

  @doc ~S"""
  ## Example

    iex> part_2(test_input(:part_1))
    11387
  """
  def_solution part_2(stream_input) do
    find_solution(stream_input, [&Kernel.+/2, &Kernel.*/2, &__MODULE__.concat/2])
  end

  def concat(n1, n2) do
    n1 * 10 ** length(Integer.digits(n2)) + n2
  end

  def test_input(:part_1) do
    """
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
    """
  end
end
