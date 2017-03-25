defmodule Galena.Common.ConsumerFunctions do
  @moduledoc false
  alias Galena.Common.TopicSelector
  require Logger

  def selector(topics) do
    fn {received_topic, _received_message} -> Enum.member?(topics, received_topic) end
  end

  def subscription(pid, producers_info) do
    Enum.each(
      producers_info,
      fn {topics, producer}->
        Logger.info("#{inspect self()} is subscribing to topics #{inspect topics} of Producer: #{inspect producer}")
        selector = TopicSelector.selector(topics)
        GenStage.async_subscribe(pid, to: producer, selector: selector)
      end
    )
  end
  
end