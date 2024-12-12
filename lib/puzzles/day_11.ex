defmodule Day11 do
  @moduledoc "https://adventofcode.com/2024/day/11"
  import Advent2024

  @doc ~S"""
  ## Example

    iex> part_1(test_input(:part_1))
    55312
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> blink(25)
    |> Enum.map(fn {_stone, frequency} -> frequency end)
    |> Enum.sum()
  end

  def blink(frequncies, 0), do: frequncies
  def blink(frequncies, n), do: frequncies |> blink() |> blink(n - 1)

  def blink(frequncies), do: Enum.reduce(frequncies, %{}, &change_stones/2)

  def change_stones({stone, frequency}, acc) do
    with nil <- update_if_zero(stone),
         nil <- update_if_even_number_of_digits(stone) do
      update_default(stone)
    end
    |> Enum.reduce(acc, fn stone, a ->
      Map.update(a, stone, frequency, &(&1 + frequency))
    end)
  end

  def update_if_zero(n) do
    if n == 0, do: [1]
  end

  def update_if_even_number_of_digits(stone) do
    digits = Integer.digits(stone)
    number_of_digits = length(digits)

    if rem(number_of_digits, 2) == 0 do
      {left, right} = Enum.split(digits, div(number_of_digits, 2))
      [Integer.undigits(left), Integer.undigits(right)]
    end
  end

  def update_default(stone), do: [stone * 2024]

  def parse(stream_input) do
    stream_input
    |> Enum.flat_map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.frequencies()
  end

  @doc ~S"""
  ## Example

    iex> part_2(test_input(:part_1))
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> blink(75)
    |> Enum.map(fn {_stone, frequency} -> frequency end)
    |> Enum.sum()
  end

  def test_input(:part_1) do
    """
    125 17
    """
  end
end
