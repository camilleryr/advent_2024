defmodule Day18 do
  defmodule PQ do
    defstruct [:key_map, :p_tree]

    def new() do
      %__MODULE__{key_map: %{}, p_tree: :gb_trees.empty()}
    end

    def member?(pq, key) do
      Map.has_key?(pq.key_map, key)
    end

    def enqueue(pq, key, p) do
      pq |> delete(key) |> do_add(key, p)
    end

    def dequeue(%__MODULE__{key_map: km, p_tree: pt} = pq) do
      if :gb_trees.is_empty(pt) do
        {:empty, pq}
      else
        {priority, queue, pt2} = :gb_trees.take_smallest(pt)
        {{:value, value}, updated_queue} = :queue.out(queue)
        updated_key_map = Map.delete(km, value)

        if :queue.is_empty(updated_queue) do
          {value, %__MODULE__{key_map: updated_key_map, p_tree: pt2}}
        else
          updated_p_tree = :gb_trees.insert(priority, updated_queue, pt2)
          {value, %__MODULE__{key_map: updated_key_map, p_tree: updated_p_tree}}
        end
      end
    end

    defp do_add(%__MODULE__{key_map: km, p_tree: pt}, key, p) do
      next_key_map = Map.put(km, key, p)

      case :gb_trees.take_any(p, pt) do
        :error ->
          queue = :queue.in(key, :queue.new())
          %__MODULE__{key_map: next_key_map, p_tree: :gb_trees.insert(p, queue, pt)}

        {queue, pt2} ->
          new_queue = :queue.in(key, queue)
          %__MODULE__{key_map: next_key_map, p_tree: :gb_trees.insert(p, new_queue, pt2)}
      end
    end

    def delete(%__MODULE__{key_map: key_map, p_tree: p_tree} = pq, key) do
      case Map.get(key_map, key) do
        nil ->
          pq

        priority ->
          {queue, pt2} = :gb_trees.take(priority, p_tree)
          queue2 = :queue.delete(key, queue)
          new_p_tree = :gb_trees.insert(priority, queue2, pt2)

          %__MODULE__{key_map: Map.delete(key_map, key), p_tree: new_p_tree}
      end
    end
  end

  @moduledoc "https://adventofcode.com/2024/day/18"
  import Advent2024

  def_solution part_1(stream_input) do
    do_solve_part_1(stream_input, 1024, 70)
  end

  def_solution part_2(stream_input) do
    do_solve_part_2(stream_input, 70)
  end

  @doc ~S"""
  ## Example

    iex> :part_1 |> test_input() |> Advent2024.stream() |> do_solve_part_1(12, 6)
    22
  """
  def do_solve_part_1(stream_input, bites, size) do
    goal = {size, size}

    stream_input
    |> Stream.take(bites)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(build_map(size), fn p, m -> Map.put(m, p, "#") end)
    |> a_star({0, 0}, goal, &manhattan_distance(&1, goal))
    |> get_number_of_steps()
  end

  @doc ~S"""
  ## Example

    iex> :part_1 |> test_input() |> Advent2024.stream() |> do_solve_part_2(6)
    "6,1"
  """
  def do_solve_part_2(stream_input, size) do
    goal = {size, size}
    blank_map = build_map(size)

    stream_input
    |> Enum.map(&parse_line/1)
    |> binary_search(goal, blank_map)
    |> Tuple.to_list()
    |> Enum.join( ",")
  end

  def binary_search(inputs, goal, blank), do: binary_search(0..length(inputs)-1, inputs, goal, blank)

  def binary_search(%{first: x, last: x}, inputs, _gaol, _blank), do: Enum.at(inputs, x - 1)

  def binary_search(%{first: f, last: l}, inputs, goal, blank) do
    mid = f + div(l - f, 2)

    inputs
    |> Enum.take(mid)
    |> Enum.reduce(blank, fn p, m -> Map.put(m, p, "#") end)
    |> a_star({0, 0}, goal, &manhattan_distance(&1, goal))
    |> case do
      :error ->
        f = if f + 1 == mid, do: mid, else: f
        binary_search(f..mid, inputs, goal, blank)

      _path ->
        mid = if mid + 1 == l, do: l, else: mid
        binary_search(mid..l, inputs, goal, blank)
    end
  end

  def get_number_of_steps(path) do
    length(path) - 1
  end

  def a_star(map, start, goal, h_fun) do
    h_val = h_fun.(start)
    open_set = PQ.enqueue(PQ.new(), start, h_val)
    came_from = %{}
    g_score = %{start => 0}
    f_score = %{start => h_val}

    a_star(open_set, came_from, g_score, f_score, map, goal, h_fun)
  end

  def a_star(open_set, came_from, g_score, f_score, map, goal, h_fun) do
    case PQ.dequeue(open_set) do
      {:empty, _} ->
        :error

      {^goal, _} ->
        reconstruct_path(goal, came_from)

      {current, open_set} ->
        {open_set, came_from, g_score, f_score} =
          current
          |> neighbors(map)
          |> Enum.reduce({open_set, came_from, g_score, f_score}, fn neighbor, {os, cf, gs, fs} ->
            tgs = Map.get(g_score, current) + 1
            if tgs < Map.get(g_score, neighbor, :infinity) do
              fv = tgs + h_fun.(neighbor)
              cf = Map.put(cf, neighbor, current)
              gs = Map.put(gs, neighbor, tgs)
              fs = Map.put(fs, neighbor, fv)
              os = if PQ.member?(os, neighbor), do: os, else: PQ.enqueue(os, neighbor, fv)

              {os, cf, gs, fs}
            else
              {os, cf, gs, fs}
            end
          end)

          a_star(open_set, came_from, g_score, f_score, map, goal, h_fun)
    end
  end

  def neighbors({x, y}, map) do
    Enum.filter([
      {x + 1, y},
      {x, y + 1},
      {x - 1, y},
      {x, y - 1}
    ], &Map.get(map, &1) == ".")
  end

  def reconstruct_path(current, came_from, acc \\ [])

  def reconstruct_path(nil, _came_from, acc), do: acc
  def reconstruct_path(current, came_from, acc) do
    came_from |> Map.get(current) |> reconstruct_path(came_from, [current | acc])
  end

  def manhattan_distance({x1, y1}, {x2, y2}) do
    (x2 - x1) + (y2 - y1)
  end

  def parse_line(line) do
    line |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
  end

  def build_map(size) do
    for x <- 0..size, y <- 0..size, into: %{}, do: {{x, y}, "."}
  end

  def test_input(:part_1) do
    """
    5,4
    4,2
    4,5
    3,0
    2,1
    6,3
    2,4
    1,5
    0,6
    3,3
    2,6
    5,1
    1,2
    5,5
    2,5
    6,5
    1,4
    0,4
    6,4
    1,1
    6,1
    1,0
    0,5
    1,6
    2,0
    """
  end

  def test_input(:part_1_2) do
    """
    ...#...
    ..#..#.
    ....#..
    ...#..#
    ..#..#.
    .#..#..
    #.#....
    """
  end

  def test_input(:part_1_3) do
    """
    OO.#OOO
    .O#OO#O
    .OOO#OO
    ...#OO#
    ..#OO#.
    .#.O#..
    #.#OOOO
    """
  end
end
