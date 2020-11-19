# ErlangDns under stress

Copy this project on the `server1` and on the `server2`:

```
rsync -vr erlang_dns/ server2.example.com:/tmp/erlang_dns/ ; rsync -vr erlang_dns/ server1.example.com:/tmp/erlang_dns/
```

Then on the `server2`, start it like this:

```
iex --name test2@server2.example.com --cookie MONSTER -S mix
```

And then start it on the `server1` like this:

```
iex  --name test2@server1.example.com --cookie MONSTER  -S mix run 
```

On the `server1` executes this function in `iex`:

```
ErlangDns.trigger_dns_problem()
```

When instructed to do so, stop the process on the `server2` with `Ctrl-C`. 
Once this is done we can see that some queries take too much time. The first element of the tuple
is the time needed for the name resolution in microseconds.

```
{4715203,                                   
 {:ok,
  {:hostent, 'server2.example.com', [], :inet, 4,
   [{172, 28, 32, 132}]}}}
{4626176,                                   
 {:ok,
  {:hostent, 'server2.example.com', [], :inet, 4,
   [{172, 28, 32, 132}]}}}
```

Restarting the node on the `server2` fixes the problem:

```
iex --name test2@server2.example.com --cookie MONSTER -S mix
```

The time values are normal again:

```
{413,                                       
 {:ok,
  {:hostent, 'server2.example.com', [], :inet, 4,
   [{172, 28, 32, 132}]}}}
{383,                                       
 {:ok,
  {:hostent, 'server2.example.com', [], :inet, 4,
   [{172, 28, 32, 132}]}}}
{4273,                                      
 {:ok,
  {:hostent, 'server2.example.com', [], :inet, 4,
   [{172, 28, 32, 132}]}}}
{865,                                       
 {:ok,
  {:hostent, 'server2.example.com', [], :inet, 4,
   [{172, 28, 32, 132}]}}}
```

The code is different than the production code: it has much more IO (more
messages are send on a given time frame) and less CPU usage (not decoding of
protobuf) but in the end exposes the same problem!
