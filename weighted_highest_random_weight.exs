defmodule WeightedHighestRandomWeightHash do
  @moduledoc """
  Implementation of Highest Random Weight (HRW), also known as Rendevzous Hash (RH).
  Original paper: https://www.eecs.umich.edu/techreports/cse/96/CSE-TR-316-96.pdf
  """

  @type object() :: term()
  @type weight() :: non_neg_integer()
  @type server() :: term()
  @type servers() :: [server()]
  @type weighted_server() :: {server(), weight()}

  @spec ordered_servers(object(), weighted_server()) :: servers()
  def ordered_servers(object, servers) do
    ordered_servers =
      servers
      |> build_server_hash_list(object, [])
      |> Enum.sort(:desc)
      |> Enum.map(fn {_hash, server} -> server end)

    ordered_servers
  end

  defp build_server_hash_list([], _object, hash_list), do: hash_list

  defp build_server_hash_list([{server, weight} | servers], object, hash_list) do
    build_server_hash_list(servers, object, [{score(object, server, weight), server} | hash_list])
  end

  defp score(object, server, weight) do
    -weight / :math.log(hash(object, server) / Bitwise.<<<(1, 32))
  end

  defp hash(object, server) do
    :erlang.phash2({object, server}, Bitwise.<<<(1, 32))
  end
end

servers =
  if System.argv() == ["weighted"] do
    [{"server1", 1}, {"server2", 10}, {"server3", 1}]
  else
    [{"server1", 1}, {"server2", 2}, {"server3", 1}]
  end

server_count = %{
  "server1" => 0,
  "server2" => 0,
  "server3" => 0
}

results =
  Enum.reduce(0..1000, server_count, fn _x, acc ->
    object = :crypto.rand_uniform(0, Bitwise.<<<(1, 32))

    selected =
      object
      |> WeightedHighestRandomWeightHash.ordered_servers(servers)
      |> List.first()

    Map.put(acc, selected, acc[selected] + 1)
  end)

IO.inspect(results)
