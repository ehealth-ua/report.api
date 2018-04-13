defmodule Report.Stats.Cache do
  @moduledoc """
  Agent used to cache heavy stats results
  """

  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_main_stats do
    Agent.get(__MODULE__, &{:ok, Map.get(&1, :main)})
  end

  def set_main_stats(stats) do
    Agent.update(__MODULE__, &Map.put(&1, :main, stats))
  end

  def get_regions_stats do
    Agent.get(__MODULE__, &{:ok, Map.get(&1, :regions)})
  end

  def set_regions_stats(stats) do
    Agent.update(__MODULE__, &Map.put(&1, :regions, stats))
  end
end
