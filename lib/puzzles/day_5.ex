defmodule Day5 do
  @moduledoc "https://adventofcode.com/2024/day/5"
  import Advent2024

  @doc ~S"""
  ## Example

    iex> part_1(test_input(:part_1))
    143
  """
  def_solution [preserve_newlines: true], part_1(stream_input) do
    {rules, updates} = parse(stream_input)

    updates
    |> Enum.filter(fn page_updates ->
      page_updates |> Enum.reverse() |> ordered?(rules)
    end)
    |> Enum.map(fn list ->
      Enum.at(list, list |> length() |> div(2))
    end)
    |> Enum.sum()
  end

  def ordered?([], _rules), do: true

  def ordered?([head | rest], rules) do
    page_order_rules = Map.get(rules, head, MapSet.new())

    if not Enum.any?(rest, fn num -> MapSet.member?(page_order_rules, num) end) do
      ordered?(rest, rules)
    end
  end

  @doc ~S"""
  ## Example

    iex> part_2(test_input(:part_1))
    123
  """
  def_solution [preserve_newlines: true], part_2(stream_input) do
    {rules, updates} = parse(stream_input)

    updates
    |> Enum.reject(fn page_updates ->
      page_updates |> Enum.reverse() |> ordered?(rules)
    end)
    |> Enum.map(fn out_of_order ->
      out_of_order
      |> Enum.sort(fn a, b -> rules |> Map.get(a, MapSet.new()) |> MapSet.member?(b) end)
      |> Enum.at(out_of_order |> length() |> div(2))
    end)
    |> Enum.sum()
  end

  def parse(stream_input) do
    stream_input
    |> Enum.reduce({%{}, [], &parse_rules/2}, fn
      nil, {rules, updates, _updater} ->
        {rules, updates, &parse_updates/2}

      line, {rules, updates, updater} ->
        {next_rules, next_updates} = updater.(line, {rules, updates})
        {next_rules, next_updates, updater}
    end)
    |> then(fn {rules, updates, _updater} ->
      {rules, Enum.reverse(updates)}
    end)
  end

  def parse_rules(line, {rules, updates}) do
    next_rules =
      line
      |> String.split("|", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> then(fn [left, right] ->
        Map.update(rules, left, MapSet.new([right]), &MapSet.put(&1, right))
      end)

    {next_rules, updates}
  end

  def parse_updates(line, {rules, updates}) do
    parsed =
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {rules, [parsed | updates]}
  end

  def test_input(:part_1) do
    """
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
    """
  end

  def test_input(:part_1_2) do
    """
    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    """
  end
end
