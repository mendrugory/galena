defmodule Galena.ProducerConsumer do
  @moduledoc """

  """

  @type topic1 :: any
  @type message1 :: any
  @type topic2 :: any
  @type message2 :: any
  @type data :: any

  @callback produce({topic1, message1}) :: {topic2, message2}

  defmacro __using__(_) do
    quote  do
      @behaviour Galena.ProducerConsumer
      use GenStage
      alias Galena.Common.ConsumerFunctions
      require Logger


      @init_time        5


      def start_link(args, opts) do
        GenStage.start_link(__MODULE__, args[:producers_info], opts)
      end

      def init(producers_info) do
        Process.send_after(self(), {:init, producers_info}, @init_time)
        {:producer_consumer, :ok}
      end

      def handle_events(events, _from, state) do
        result = Enum.map(events, fn {topic, message} -> produce(topic, message) end)
        {:noreply, result, state}
      end

      def handle_info({:init, producers_info}, state) do
        Logger.info("Subscribing ...")
        ConsumerFunctions.subscription(self(), producers_info)
        {:noreply, [], state}
      end

    end
  end
  
end