defmodule GalenaTest do
  use ExUnit.Case
  doctest Galena

  test "one producer one consumer using name" do

    Process.register(self(), :test_received_message)

    defmodule MyProducer do
      use Galena.Producer

      def handle_produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        send(:test_received_message, {topic, message})
      end
    end


    MyProducer.start_link([], [name: :producer])
    MyConsumer.start_link([producers_info: [{["topic"], :producer}]], [name: :consumer])

    Process.sleep(20)
    MyProducer.ingest(:producer, {"topic", "Hola"})
    Process.sleep(100)

    receive do
      {topic, message} ->
        assert topic == "topic"
        assert message == "Hola"
      msg ->
        assert false
    end
  end

  test "one producer one consumer using variable" do

    Process.register(self(), :test_received_message)

    defmodule MyProducer do
      use Galena.Producer

      def handle_produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        send(:test_received_message, {topic, message})
      end
    end

    {:ok, producer} = MyProducer.start_link([], [])
    MyConsumer.start_link([producers_info: [{["topic"], producer}]], [])

    Process.sleep(20)
    MyProducer.ingest(producer, {"topic", "Hola"})
    Process.sleep(100)

    receive do
      {topic, message} ->
        assert topic == "topic"
        assert message == "Hola"
      msg ->
        assert false
    end
  end

  test "one producer one prod-cons one consumer" do

    Process.register(self(), :test_received_message)

    defmodule MyProducer do
      use Galena.Producer

      def handle_produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyProducerConsumer do
      use Galena.ProducerConsumer

      def handle_produce(topic, data) do
        {"topic2", data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        send(:test_received_message, {topic, message})
      end
    end


    MyProducer.start_link([], [name: :producer])
    MyProducerConsumer.start_link([producers_info: [{["topic1"], :producer}]], [name: :prod_cons])
    MyConsumer.start_link([producers_info: [{["topic2"], :prod_cons}]], [name: :consumer])

    Process.sleep(20)
    MyProducer.ingest(:producer, {"topic1", "Hola"})
    Process.sleep(100)

    receive do
      {topic, message} ->
        assert topic == "topic2"
        assert message == "Hola"
      msg ->
        assert false
    end
  end

  test "one producer 2 prod-cons one consumer" do

    Process.register(self(), :test_received_message)

    assert_function =
      fn ->
        receive do
          {topic, message} ->
            assert topic == "topic2"
            assert message == "Hola"
          msg ->
            assert false
        end
      end

    defmodule MyProducer do
      use Galena.Producer

      def handle_produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyProducerConsumer do
      use Galena.ProducerConsumer

      def handle_produce(topic, data) do
        {"topic2", data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        send(:test_received_message, {topic, message})
      end
    end


    MyProducer.start_link([], [name: :producer])
    MyProducerConsumer.start_link([producers_info: [{["topic1"], :producer}]], [name: :prod_cons1])
    MyProducerConsumer.start_link([producers_info: [{["topic1"], :producer}]], [name: :prod_cons2])
    MyConsumer.start_link([producers_info: [{["topic2"], :prod_cons1}, {["topic2"], :prod_cons2}]], [name: :consumer])

    Process.sleep(20)
    MyProducer.ingest(:producer, {"topic1", "Hola"})
    Process.sleep(100)

    assert_function.()
    assert_function.()

  end

  test "one producer two consumers" do

    Process.register(self(), :test_received_message)

    assert_function =
      fn ->
        receive do
          {topic, message} ->
            assert topic == "topic"
            assert message == "Hola"
          msg ->
            assert false
        end
      end

    defmodule MyProducer do
      use Galena.Producer

      def handle_produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        send(:test_received_message, {topic, message})
      end
    end

    MyProducer.start_link([], [name: :producer])
    MyConsumer.start_link([producers_info: [{["topic"], :producer}]], [name: :consumer1])
    MyConsumer.start_link([producers_info: [{["topic"], :producer}]], [name: :consumer2])

    Process.sleep(20)
    MyProducer.ingest(:producer, {"topic", "Hola"})
    Process.sleep(100)

    assert_function.()
    assert_function.()
  end


  test "one producer 22 consumers" do

    Process.register(self(), :test_received_message)

    assert_function =
      fn ->
        receive do
          {topic, message} ->
            assert topic == "topic"
            assert message == "Hola"
          msg ->
            assert false
        end
      end

    defmodule MyProducer do
      use Galena.Producer

      def handle_produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        send(:test_received_message, {topic, message})
      end
    end

    MyProducer.start_link([], [name: :producer])

    for i <- 1..22 do
      name = String.to_atom("consumer" <> Integer.to_string(i))
      MyConsumer.start_link([producers_info: [{["topic"], :producer}]], [name: name])
    end

    Process.sleep(20)
    for i <- 1..22, do: MyProducer.ingest(:producer, {"topic", "Hola"})
    Process.sleep(100)

    for i <- 1..22, do: assert_function.()

  end


  test "two producers (same topic) one consumer" do

    Process.register(self(), :test_received_message)

    assert_function =
      fn ->
        receive do
          {topic, message} ->
            assert topic == "topic"
            assert message == "Hola"
          msg ->
            assert false
        end
      end

    defmodule MyProducer do
      use Galena.Producer

      def handle_produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        send(:test_received_message, {topic, message})
      end
    end

    MyProducer.start_link([], [name: :producer1])
    MyProducer.start_link([], [name: :producer2])
    MyConsumer.start_link([producers_info: [{["topic"], :producer1}, {["topic"], :producer2}]], [])

    Process.sleep(20)
    MyProducer.ingest(:producer1, {"topic", "Hola"})
    MyProducer.ingest(:producer2, {"topic", "Hola"})
    Process.sleep(100)

    assert_function.()
    assert_function.()
  end


  test "two producers (different topic) one consumer" do

    Process.register(self(), :test_received_message)

    assert_function =
      fn ->
        receive do
          {"topic1", message} ->
            assert message == "Hola1"
          {"topic2", message} ->
            assert message == "Hola2"
          msg ->
            assert false
        end
      end

    defmodule MyProducer do
      use Galena.Producer

      def handle_produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        send(:test_received_message, {topic, message})
      end
    end

    MyProducer.start_link([], [name: :producer1])
    MyProducer.start_link([], [name: :producer2])
    MyConsumer.start_link([producers_info: [{["topic1"], :producer1}, {["topic2"], :producer2}]], [])

    Process.sleep(20)
    MyProducer.ingest(:producer1, {"topic1", "Hola1"})
    MyProducer.ingest(:producer2, {"topic2", "Hola2"})
    Process.sleep(100)

    assert_function.()
    assert_function.()
  end


  test "one producer (different topics) one consumer" do

    Process.register(self(), :test_received_message)

    assert_function =
      fn ->
        receive do
          {"topic1", message} ->
            assert message == "Hola1"
          {"topic2", message} ->
            assert message == "Hola2"
          msg ->
            assert false
        end
      end

    defmodule MyProducer do
      use Galena.Producer

      def handle_produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        send(:test_received_message, {topic, message})
      end
    end

    MyProducer.start_link([], [name: :producer])
    MyConsumer.start_link([producers_info: [{["topic1", "topic2"], :producer}]], [])

    Process.sleep(20)
    MyProducer.ingest(:producer, {"topic1", "Hola1"})
    MyProducer.ingest(:producer, {"topic2", "Hola2"})
    Process.sleep(100)

    assert_function.()
    assert_function.()
  end


  test "one producer (different topics) one consumer empty list of topics" do

    Process.register(self(), :test_received_message)

    assert_function =
      fn ->
        receive do
          {"topic1", message} ->
            assert message == "Hola1"
          {"topic2", message} ->
            assert message == "Hola2"
          msg ->
            assert false
        end
      end

    defmodule MyProducer do
      use Galena.Producer

      def handle_produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        send(:test_received_message, {topic, message})
      end
    end

    MyProducer.start_link([], [name: :producer])
    MyConsumer.start_link([producers_info: [{[], :producer}]], [])

    Process.sleep(20)
    MyProducer.ingest(:producer, {"topic1", "Hola1"})
    MyProducer.ingest(:producer, {"topic2", "Hola2"})
    Process.sleep(100)

    assert_function.()
    assert_function.()
  end


  test "one producer two prod-cons four consumer" do

    Process.register(self(), :test_received_message)

    assert_function =
      fn ->
        receive do
          {"1111", message} ->
            assert message == "Hola1"
          {"2222", message} ->
            assert message == "Hola2"
          msg ->
            assert false
        end
      end


    defmodule MyProducer do
      use Galena.Producer

      def handle_produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyProducerConsumer do
      use Galena.ProducerConsumer

      def handle_produce(topic, data) do
        {topic <> topic, data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        send(:test_received_message, {topic, message})
      end
    end


    MyProducer.start_link([], [name: :producer])
    MyProducerConsumer.start_link([producers_info: [{["11"], :producer}]], [name: :prod_cons1])
    MyProducerConsumer.start_link([producers_info: [{["22"], :producer}]], [name: :prod_cons2])
    MyConsumer.start_link([producers_info: [{["1111"], :prod_cons1}]], [name: :cons1])
    MyConsumer.start_link([producers_info: [{["1111"], :prod_cons1}]], [name: :cons2])
    MyConsumer.start_link([producers_info: [{["2222"], :prod_cons2}]], [name: :cons3])
    MyConsumer.start_link([producers_info: [{["2222"], :prod_cons2}]], [name: :cons4])

    Process.sleep(20)
    MyProducer.ingest(:producer, {"11", "Hola1"})
    MyProducer.ingest(:producer, {"22", "Hola2"})
    Process.sleep(100)

    for i <- 1..4, do: assert_function.()

  end

  test "Four producers two prod-cons one consumer" do

    Process.register(self(), :test_received_message)

    assert_function =
      fn ->
        receive do
          {"1111", message} ->
            assert message == "Hola1"
          {"2222", message} ->
            assert message == "Hola2"
          {"3333", message} ->
            assert message == "Hola3"
          {"4444", message} ->
            assert message == "Hola4"
          msg ->
            assert false
        end
      end


    defmodule MyProducer do
      use Galena.Producer

      def handle_produce({topic, data}) do
        {topic, data}
      end
    end

    defmodule MyProducerConsumer do
      use Galena.ProducerConsumer

      def handle_produce(topic, data) do
        {topic <> topic, data}
      end
    end

    defmodule MyConsumer do
      use Galena.Consumer

      def handle_consume(topic, message) do
        send(:test_received_message, {topic, message})
      end
    end


    MyProducer.start_link([], [name: :producer1])
    MyProducer.start_link([], [name: :producer2])
    MyProducer.start_link([], [name: :producer3])
    MyProducer.start_link([], [name: :producer4])

    MyProducerConsumer.start_link([producers_info: [{["11"], :producer1}, {["22"], :producer2}]], [name: :prod_cons1])
    MyProducerConsumer.start_link([producers_info: [{["33"], :producer3}, {["44"], :producer4}]], [name: :prod_cons2])

    MyConsumer.start_link([producers_info: [{[], :prod_cons1}, {[], :prod_cons2}]], [name: :cons])

    Process.sleep(20)
    MyProducer.ingest(:producer1, {"11", "Hola1"})
    MyProducer.ingest(:producer2, {"22", "Hola2"})
    MyProducer.ingest(:producer3, {"33", "Hola3"})
    MyProducer.ingest(:producer4, {"44", "Hola4"})
    Process.sleep(100)

    for i <- 1..4, do: assert_function.()

  end

end
