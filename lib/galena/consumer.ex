defmodule Galena.Consumer do
  @moduledoc """

  """

  @type topic :: String.t
  @type message :: any

  @callback consume(topic, message) :: any

  defmacro __using__(_) do
    quote  do
      @behaviour Galena.Consumer
      use GenStage
      alias Galena.Common.TopicSelector
      require Logger


      @init_time        10


      def start_link(args, opts) do
        GenStage.start_link(__MODULE__, args[:producers_info], opts)
      end

      def init(producers_info) do
        Process.send_after(self(), {:init, producers_info}, @init_time)
        {:consumer, :ok}
      end

      def handle_info({:init, producers_info}, state) do
        Logger.info("Subscribing ...")
        Enum.each(
          producers_info,
          fn {topics, producer}->
            Logger.info("Subscribing to topics #{inspect topics} to Producer: #{inspect producer}")
            selector = TopicSelector.selector(topics)
            GenStage.async_subscribe(self(), to: producer, selector: selector)
          end
        )
        {:noreply, [], state}
      end

      def handle_events(events, _from, state) do
        Enum.each(events, fn {topic, message} -> consume(topic, message) end)
        {:noreply, [], state}
      end


    end
  end
  
end