defmodule GalenaTest do
  use ExUnit.Case
  doctest Galena

  test "one producer one consumer using name" do

    defmodule MyProducer do
      use Galena.Producer

      def produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def consume(topic, message) do
        assert(topic, "topic")
        assert(message, "Hola")
      end
    end


    MyProducer.start_link([], [name: :producer])
    MyConsumer.start_link([producers_info: [{["topic"], :producer}]], [name: :consumer])
    MyProducer.ingest(:producer, {"topic", "hola"})
  end

  test "one producer one consumer using variable" do

    defmodule MyProducer do
      use Galena.Producer

      def produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def consume(topic, message) do
        assert(topic, "topic")
        assert(message, "Hola")
      end
    end

    {:ok, producer} = MyProducer.start_link([], [])
    MyConsumer.start_link([producers_info: [{["topic"], producer}]], [])
    MyProducer.ingest(producer, {"topic", "hola"})
  end
end
