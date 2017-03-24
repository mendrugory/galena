defmodule Galena.Common.TopicSelector do
  @moduledoc false

  def selector(topics) do
    fn {received_topic, _received_message} -> Enum.member?(topics, received_topic) end
  end
  
end