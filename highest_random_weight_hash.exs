defmodule HighestRandomWeightHash do
  @moduledoc """
  Implementation of Highest Random Weight (HRW), also known as Rendevzous Hash (RH).
  Original paper: https://www.eecs.umich.edu/techreports/cse/96/CSE-TR-316-96.pdf
  """

  @type object() :: term()
  @type server() :: term()
  @type servers() :: [server()]

  @spec ordered_servers(object(), servers(), [Keyword.t()]) :: servers()
  def ordered_servers(object, servers, opts \\ []) do
    ordered_servers =
      servers
      |> build_server_hash_list(object, [])
      |> Enum.sort(:desc)
      |> Enum.map(fn {_hash, server} -> server end)

    if Keyword.get(opts, :log_verbose) do
      IO.puts("#{object} will rendezvous at #{List.first(ordered_servers)}")
    end

    ordered_servers
  end

  defp build_server_hash_list([], _object, hash_list), do: hash_list

  defp build_server_hash_list([server | servers], object, hash_list) do
    build_server_hash_list(servers, object, [{hash(object, server), server} | hash_list])
  end

  defp hash(object, server) do
    :erlang.phash2({object, server}, Bitwise.<<<(1, 32))
  end
end

servers = ["server1", "server2", "server3"]
HighestRandomWeightHash.ordered_servers("google.com", servers, log_verbose: true)
HighestRandomWeightHash.ordered_servers("yahoo.com", servers, log_verbose: true)
HighestRandomWeightHash.ordered_servers("hotmail.com", servers, log_verbose: true)

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
      |> HighestRandomWeightHash.ordered_servers(servers)
      |> List.first()

    Map.put(acc, selected, acc[selected] + 1)
  end)

IO.inspect(results)
