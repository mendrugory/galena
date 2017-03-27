defmodule Galena do
  @moduledoc """
  **Galena** is a topic producer-consumer library built on top of `GenStage`.

  Galena has three main behaviours that could be used in order to create complex data pipelines with topics:

  * `Galena.Producer` is a customized GenStage producer which will serve the produced events as soon as possible.

  * `Galena.Consumer` is a customized GenStage consumer whith the capability of connecting to a list
     of topics of producers and/or producer-consumer(s).

  * `Galena.ProducerConsumer` is a customized GenStage producer-consumer which will receive messages from
     the list of topics of those producers and/or producer-consumer(s) which was subscribed and will send
     the produced events as soon as possible.

  """

end
