defmodule ErlangDns do

  @remote_host :"server2.example.com"
  @remote_node :"test2@#{@remote_host}"

  def trigger_dns_problem do
    true = Node.connect(IO.inspect(@remote_node))
    pid = spawn_remote_process(@remote_node)

    send(pid, {:do_registration, self()})
    receive do
      :registered -> IO.puts "registration on the remote done!"
    end

    remote = {:the_remote_listener, @remote_node}
    send(remote, {:ping, self()})
    receive do
      :pong -> IO.puts "pong received!"
    end

    IO.inspect(:inet_gethost_native.gethostbyname(@remote_host), label: "gethost")
    IO.puts "---------- Please stop the other remote process within 10 seconds (with Ctrl-c) ----------"
    Process.sleep(10_000)
    Process.spawn(fn -> send_messages(remote) end, [:link])
    Process.spawn(fn -> resolve_domain() end, [:link])
  end

  def send_messages(pid) do
    for _ <- 1..200_000 do
      send(pid, {:ping, self()})
    end
    Process.sleep(10)
    send_messages(pid)
  end

  def resolve_domain() do
    IO.inspect(:timer.tc(fn ->  :inet_gethost_native.gethostbyname(@remote_host) end))
    Process.sleep(1_000)
    resolve_domain()
  end

  def spawn_remote_process(host) do
    Node.spawn(host, &listen/0)
  end

  def listen() do
    receive do
      {:do_registration, client} ->
        Process.register(self(), :the_remote_listener)
        send(client, :registered)

      {:ping, client} ->
        send(client, :pong)
    end
    listen()
  end

end
