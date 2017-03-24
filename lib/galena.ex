defmodule Galena do
  @moduledoc """
  Galena is a topic consumer-producer library built on top of GenStage for Elixir.


  defmodule MyApplication.MyProducer do
    use Galena.Producer

    def produce({topic, data}) do
      {topic, data}
    end
  end

  MyApplication.MyProducer.start_link([], [name: :producer])


  defmodule MyApplication.MyConsumer do
    use Galena.Consumer

    def consume(topic, message) do
      IO.puts(topic <> ": " <> message)
    end
  end

  MyApplication.MyConsumer.start_link([producers_info: [{["topic1"], :producer}]], [name: :consumer1])
  MyApplication.MyConsumer.start_link([producers_info: [{["topic2"], :producer}]], [name: :consumer2])

  MyApplication.MyProducer.ingest :producer, {"topic1", "Hola"}
  MyApplication.MyProducer.ingest :producer, {"topic2", "Adios"}

  """

end
