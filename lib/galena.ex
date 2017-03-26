defmodule Galena do
  @moduledoc """
  **Galena** is a topic consumer-producer library built on top of `GenStage`.

  * `Galena.Producer` is a customized GenStage producer which will serve the produced events as soon as possible.

  * `Galena.Consumer` is a customized GenStage consumer whith the capability of connecting to a list
     of topics of producers and/or producer-consumer(s).

  * `Galena.ProducerConsumer` is a customized GenStage producer-consumer which will receive messages from
     the list of topics of those producers and/or producer-consumer(s) which was subscribed and will send
     the produced events as soon as possible.

  ```elixir
    defmodule MyProducer do
      use Galena.Producer

      def produce({topic, data}) do
        {topic, data}
      end
    end

    MyProducer.start_link([], [name: :producer])


    defmodule MyProducerConsumer do
      use Galena.ProducerConsumer

      def produce(topic, data) do
        result_topic = topic <> Integer.to_string(:rand.uniform(2))
        {result_topic, "modified by producer-consumer: " <> data}
      end
    end

    MyProducerConsumer.start_link([producers_info: [{["topic"], :producer}]], [name: :prod_cons])

    defmodule MyConsumer do
      use Galena.Consumer

      def consume(topic, message) do
        IO.puts(topic <> ": " <> message)
      end
    end

    MyConsumer.start_link([producers_info: [{["topic1"], :prod_cons}]], [name: :consumer1])
    MyConsumer.start_link([producers_info: [{["topic2"], :prod_cons}]], [name: :consumer2])

    for i <- 1..100, do: MyProducer.ingest(:producer, {"topic", "Hola" <> Integer.to_string(:rand.uniform(100))})
  ```
  """

end
