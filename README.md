# Galena

Galena is a topic consumer-producer library built on top of GenStage for Elixir. 

I highly recommend to initiate your producers/consumers under a Supervisor.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `galena` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
       [{:galena, git: "https://github.com/mendrugory/galena.git"}]  # or [{:galena, "~> 0.1.0"}] when is available
    end
    ```
    
   
  3. Define and run your Producer(s). Your producer could be connected to external system like RabbitMQ, Kafka, DataBases, ...
   Code the function produce(data), where data can be whatever, and
   has to return a tuple where the first value has to be a topic (String) and the second one the message
   (whatever). To guarantee a good perfomance, try to optimize as much as possible this function.
     
  ```elixir
  defmodule MyApplication.MyProducer do
    use Galena.Producer

    def produce({topic, data}) do
      {topic, data}
    end
  end

  MyApplication.MyProducer.start_link([], [name: :producer])

  ```
  
  5. Define and run your Consumer. Code the function consume(topic, message).
  A consumer could be subscribed to different topics of the
  same producer or even to different producers. We have to indicate it using a Keyword list as first
  parameter which has to contain the information about the producers.
   
  ```elixir
  # Example
  args = [
    producers_info: [
      {["topic_1", "topic_2", "topic_3"], producer1},
      {["topic_A"], producer2},
      {["topic_a", "topic_b"], producer3},
    ]
  ]
  ```
  
  ```elixir
  defmodule MyApplication.MyConsumer do
    use Galena.Consumer
  
    def consume(topic, message) do
      IO.puts(topic <> ": " <> message)
    end
  end
 
  MyApplication.MyConsumer.start_link([producers_info: [{["topic1"], :producer}]], [name: :consumer1])
  MyApplication.MyConsumer.start_link([producers_info: [{["topic2"], :producer}]], [name: :consumer2])
  ```
  
  5. Begin to ingest data
  ```elixir
  iex> MyApplication.MyProducer.ingest :producer, {"topic1", "Hola"}
  iex> MyApplication.MyProducer.ingest :producer, {"topic2", "Adios"} 
  ```
  
  6. Run the tests.
  ```bash
  mix test
  ```
  
  