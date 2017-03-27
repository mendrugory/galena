defmodule Galena.Producer do
  @moduledoc """
  **Galena.Producer** is a customized `GenStage` producer which uses
  `GenStage.BroadcastDispatcher` as dispatcher.


  ### Definition

  ```elixir
  defmodule MyProducer do
    use Galena.Producer

    def handle_produce({topic, message}) do
      {topic, message}
    end
  end
  ```


  ### Start Up

  ```elixir
  {:ok, producer} = MyProducer.start_link([], [name: :producer])
  ```


  ### Data Ingestion

  ```elixir
  MyProducer.ingest(:producer, data)
  ```
  """

  @type topic :: any
  @type message :: any
  @type data :: any

  @doc """
  It will be executed just before a message is sent to the consumers (or producer-consumers).

  The input of the function can be whatever type.
  The output of that function has to be a tuple where the first parameter will be the topic and the second one the message.
  """
  @callback handle_produce(data) :: {topic, message}

  @sleep_time       1

  defmacro __using__(_) do
    quote do
      @behaviour Galena.Producer
      use GenStage
      require Logger

      def start_link(state, opts) do
        GenStage.start_link(__MODULE__, state, opts)
      end

      def ingest(producer, data) do
        pid = self()
        case producer do
          ^pid -> Process.send_after(pid, {:message, data}, @sleep_time)
          _ -> GenStage.cast(producer, {:message, data})
        end
      end

      def init(_state) do
        {:producer, %{}, dispatcher: GenStage.BroadcastDispatcher}
      end

      def handle_demand(demand, state) do
        {:noreply, [], state}
      end

      def handle_cast({:message, data}, state) do
        {:noreply, [handle_produce(data)], state}
      end

      def handle_info({:message, data}, state) do
        {:noreply, [handle_produce(data)], state}
      end

      def handle_info(_msg, state) do
        {:noreply, [], state}
      end

    end
  end

  @doc """
  This function is the responsible of the data ingestion by the chosen producer. The data can be whatever.
  """
  def ingest(producer, data)

end