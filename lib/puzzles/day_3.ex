defmodule Day3 do
  @moduledoc "https://adventofcode.com/2024/day/3"
  import Advent2024

  @multiplication_pattern "mul\\((\\d{1,3}),(\\d{1,3})\\)"

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    161
  """
  def_solution part_1(stream_input) do
    calculate(stream_input, Regex.compile!(@multiplication_pattern))
  end

  @dont_do_pattern "don't\\(\\).*do\\(\\)"

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_2))
    48
  """
  def_solution part_2(stream_input) do
    calculate(stream_input, Regex.compile!("#{@dont_do_pattern}|#{@multiplication_pattern}", "U"))
  end

  def calculate(stream_input, regex) do
    regex
    |> Regex.scan(Enum.join(stream_input))
    |> Enum.flat_map(fn
      ["mul" <> _rest, left, right] -> [String.to_integer(left) * String.to_integer(right)]
      _ -> []
    end)
    |> Enum.sum()
  end

  def test_input(:part_1) do
    """
    xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
    """
  end

  def test_input(:part_2) do
    """
    xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
    """
  end
end
