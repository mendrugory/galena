defmodule Galena.Common.TopicSelector do
  @moduledoc false

  def selector([]) do
    fn(_data) -> true end
  end

  def selector(topics) when is_list(topics) do
    fn({received_topic, _received_message}) -> Enum.member?(topics, received_topic) end
  end

  def selector(_topics) do
    fn(_data) -> false end
  end
  
end