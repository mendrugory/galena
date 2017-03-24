defmodule Galena.Producer do
  @moduledoc """

  """

  @type topic :: String.t
  @type message :: any
  @type data :: any

  @callback produce(data) :: {topic, message}


  defmacro __using__(_) do
    quote do
      @behaviour Galena.Producer
      use GenStage
      require Logger

      def start_link(state, opts) do
        GenStage.start_link(__MODULE__, state, opts)
      end

      def ingest(producer, message) do
        GenStage.call(producer, {:message, message})
      end

      def init(_state) do
        {:producer, %{}, dispatcher: GenStage.BroadcastDispatcher}
      end

      def handle_demand(demand, state) do
        {:noreply, [], state}
      end

      def handle_call({:message, message}, _from, state) do
        {:reply, :ok, [produce(message)], state}
      end

      def handle_info(_msg, state) do
        {:noreply, [], state}
      end

    end
  end
  
end