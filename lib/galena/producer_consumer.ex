defmodule Galena.ProducerConsumer do
  @moduledoc """
  **Galena.ProducerConsumer** is a customized `GenStage` consumer-producer which is able to receive _some_ messages
  from _some_ producers or producers-consumers and send them to the consumers or
  producer-consumers that are subscribed. The producer-consumer will have the possibility to be subscribed
  to the chosen topics from the chosen producers.


  ### Definition

  ```elixir
  defmodule MyProducerConsumer do
    use Galena.ProducerConsumer

    def handle_produce(topic, data) do
      result_topic = topic <> Integer.to_string(:rand.uniform(2))
      {result_topic, "modified by producer-consumer: " <> data}
    end
  end
  ```


  ### Start up
  Define the `args` of your ProducerConsumer. It has to be a Keyword list which has to contain a `producers_info`
  field which will have a list of tuples of two parameters, where the first one will be a list
  of topics and the second one the producer or producer-consumer:

  ```elixir
    args = [
      producers_info: [
        {["topic_1", "topic_2", "topic_3"], :producer1},
        {["topic_A"], :producer2},
        {["topic_a", "topic_b"], :producer3},
        {[], :producer4}
      ]
    ]
  ```
  When the list of topics is empty, your producer-consumer will receive
  all the information published by the producer.

  ```elixir
  {:ok, producer_consumer} = MyProducerConsumer.start_link(args, [name: :prod_cons])
  ```
  """

  @type subscribed_topic :: any
  @type received_message :: any
  @type produced_topic :: any
  @type produced_message :: any

  @doc """
  It will be executed just before a message is sent to the consumers (or producer-consumers).

  The inputs of the function are a topic (subscribed topic) and a message (received message).
  The output of that function has to be a tuple where the first parameter will be the topic (produced topic)
  and the second one the message (produced message).
  """
  @callback handle_produce(subscribed_topic, received_message) :: {produced_topic, produced_message}

  defmacro __using__(_) do
    quote  do
      @behaviour Galena.ProducerConsumer
      use GenStage
      alias Galena.Common.ConsumerFunctions
      require Logger

      @init_time        1

      def start_link(args, opts) do
        GenStage.start_link(__MODULE__, args[:producers_info], opts)
      end

      def init(producers_info) do
        Process.send_after(self(), {:init, producers_info}, @init_time)
        {:producer_consumer, %{}, dispatcher: GenStage.BroadcastDispatcher}
      end

      def handle_events(events, _from, state) do
        result = Enum.map(events, fn {topic, message} -> handle_produce(topic, message) end)
        {:noreply, result, state}
      end

      def handle_info({:init, producers_info}, state) do
        ConsumerFunctions.subscription(self(), producers_info)
        {:noreply, [], state}
      end

    end
  end
  
end