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


  defmodule MyApplication.MyProducerConsumer do
    use Galena.ProducerConsumer

    def produce(topic, data) do
      result_topic = topic <> Integer.to_string(:rand.uniform(2))
      {result_topic, "modified by producer-consumer: " <> data}
    end
  end

  MyApplication.MyProducerConsumer.start_link([producers_info: [{["topic"], :producer}]], [name: :prod_cons])

  defmodule MyApplication.MyConsumer do
    use Galena.Consumer

    def consume(topic, message) do
      IO.puts(topic <> ": " <> message)
    end
  end

  MyApplication.MyConsumer.start_link([producers_info: [{["topic1"], :prod_cons}]], [name: :consumer1])
  MyApplication.MyConsumer.start_link([producers_info: [{["topic2"], :prod_cons}]], [name: :consumer2])

  for i <- 1..100, do: MyApplication.MyProducer.ingest(:producer, {"topic", "Hola" <> Integer.to_string(:rand.uniform(100))})

  """

end
