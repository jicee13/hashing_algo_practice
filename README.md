## Highest Random Weight Hashing (Rendezvous Hashing)

### Method 1: Nonweighted
First we use a simple hasing algorithm with the built in `phash2/2`. We hash a tuple of the object and the server and use a max value of 1 bit shifted left 32 which will return the highest 32 bit number. We don't need to do `Bitwise.<<<(1, 32)) - 1` as `phash2/2` is non-inclusive so it does that for us. Running this with 1000 different objects, we get the following results:

```bash
elixir highest_random_weight_hash.exs
```

```elixir
%{"server1" => 353, "server2" => 329, "server3" => 319}
%{"server1" => 341, "server2" => 328, "server3" => 332}
%{"server1" => 347, "server2" => 324, "server3" => 330}
```

So all in all, pretty good. Things seem evenly split amongst the servers.

Ps. I left the log statements in there to show 3 examples how how it would map to different servers based on different URLs, or objects.

But let's say we have these 3 servers, and 1 of them is more powerful than the other 2, so we want to favor that one just a bit. Introducing weighted highest random weight...


### Method 2: Weighted
In this example, "server2" will be our powerful server, and we will give it priority over the other servers. We pull our weighted algorithm from https://datatracker.ietf.org/doc/html/draft-mohanty-bess-weighted-hrw.

_Score(Oi, Sj) = -wi/log(Hash(Oi, Sj)/Hmax); where Hmax is the maximum hash value._

First run we will set the server weights as follows:
`[{"server1", 1}, {"server2", 2}, {"server3", 1}]`

And with it we get the following results:

```bash
elixir highest_random_weight_hash.exs
```

```elixir
%{"server1" => 244, "server2" => 494, "server3" => 263}
%{"server1" => 268, "server2" => 500, "server3" => 233}
%{"server1" => 257, "server2" => 506, "server3" => 238}
```

Just for kicks, let's crank up our weight a bit more:
`[{"server1", 1}, {"server2", 10}, {"server3", 1}]`

```bash
elixir highest_random_weight_hash.exs weighted
```

And with it we get the following results:

```elixir
%{"server1" => 98, "server2" => 825, "server3" => 78}
%{"server1" => 72, "server2" => 844, "server3" => 85}
%{"server1" => 70, "server2" => 843, "server3" => 88}
```

