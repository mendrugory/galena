defmodule Galena.Consumer do
  @moduledoc """
  **Galena.Consumer** is a customized `GenStage` producer which is able to receive _some_ messages
  from _some_ producers or producers-consumers. The consumer will have the possibility to be subscribed
  to the chosen topics from the chosen producers.


  ### Definition

  ```elixir
    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        IO.puts(topic <> ": " <> message)
      end
    end

    ```


  ### Start up
  Define the `args` of your Consumer. It has to be a Keyword list which has to contain a `producers_info` field which
  will have a list of tuples of two parameters, where the first one will be a list of topics and the second one
  the producer or producer-consumer:

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
  When the list of topics is empty, your consumer will receive all the information published by the producer.

  ```elixir
  {:ok, consumer} = MyConsumer.start_link(args, [name: :consumer])
  ```
  """

  @type topic :: any
  @type message :: any

  @doc """
  It will be executed when a message is received by the consumer.

  The first argument will be the subscribed topic and the second one the received message.
  """
  @callback handle_consume(topic, message) :: any

  defmacro __using__(_) do
    quote  do
      @behaviour Galena.Consumer
      use GenStage
      alias Galena.Common.ConsumerFunctions

      @init_time        1

      def start_link(args, opts) do
        GenStage.start_link(__MODULE__, args[:producers_info], opts)
      end

      def init(producers_info) do
        Process.send_after(self(), {:init, producers_info}, @init_time)
        {:consumer, :ok}
      end

      def handle_info({:init, producers_info}, state) do
        ConsumerFunctions.subscription(self(), producers_info)
        {:noreply, [], state}
      end

      def handle_events(events, _from, state) do
        Enum.each(events, fn {topic, message} -> handle_consume(topic, message) end)
        {:noreply, [], state}
      end

    end
  end
  
end