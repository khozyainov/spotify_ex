defmodule Spotify.Player do
  import Spotify.Helpers
  use Spotify.Responder

  alias Spotify.{
    Client,
    Device,
    Playback,
    Track
  }

  def get_devices(conn) do
    url = devices_url()
    conn |> Client.get(url) |> handle_response
  end

  @doc """
    iex> Spotify.Player.devices_url
    "https://api.spotify.com/v1/me/player/devices"
  """
  def devices_url() do
    "https://api.spotify.com/v1/me/player/devices"
  end

  def get_current_playback(conn) do
    url = current_playback_url()
    conn |> Client.get(url) |> handle_response
  end

  @doc """
    iex> Spotify.Player.current_playback_url
    "https://api.spotify.com/v1/me/player"
  """
  def current_playback_url() do
    "https://api.spotify.com/v1/me/player"
  end

  @doc """
    **Optional params**: `device_id`
  """
  def pause(conn, params \\ []) do
    url = pause_url(params)
    conn |> Client.put(url) |> handle_response
  end

  @doc """
    iex> Spotify.Player.pause_url(device_id: "abc")
    "https://api.spotify.com/v1/me/player/pause?device_id=abc"
  """
  def pause_url(params \\ []) do
    "https://api.spotify.com/v1/me/player/pause" <> query_string(params)
  end

  @doc """
    **Optional params**: `device_id`, `context_uri`, `uris`, `offset`, `position_ms`
  """
  def play(conn, params \\ []) do
    {query_params, body_params} = Keyword.split(params, [:device_id])

    url = play_url(query_params)
    body = body_params |> Enum.into(%{}) |> Poison.encode!()

    conn |> Client.put(url, body) |> handle_response
  end

  @doc """
    iex> Spotify.Player.play_url(device_id: "abc")
    "https://api.spotify.com/v1/me/player/play?device_id=abc"
  """
  def play_url(params \\ []) do
    "https://api.spotify.com/v1/me/player/play" <> query_string(params)
  end

   @doc """
    **Optional params**: `device_id`
  """
  def skip_to_next(conn, params \\ []) do
    url = skip_to_next_url(params)
    conn |> Client.post(url) |> handle_response
  end

  @doc """
    iex> Spotify.Player.skip_to_next_url(device_id: "abc")
    "https://api.spotify.com/v1/me/player/next?device_id=abc"
  """
  def skip_to_next_url(params \\ []) do
    "https://api.spotify.com/v1/me/player/next" <> query_string(params)
  end

  @doc """
    **Optional params**: `device_id`
  """
  def skip_to_previous(conn, params \\ []) do
    url = skip_to_previous_url(params)
    conn |> Client.post(url) |> handle_response
  end

  @doc """
    iex> Spotify.Player.skip_to_previous_url(device_id: "abc")
    "https://api.spotify.com/v1/me/player/previous?device_id=abc"
  """
  def skip_to_previous_url(params \\ []) do
    "https://api.spotify.com/v1/me/player/previous" <> query_string(params)
  end

  @doc """
    **Optional params**: `device_id`
  """
  def seek(conn, position_ms, params \\ []) do
    url = params |> Keyword.put(:position_ms, position_ms) |> seek_url()
    conn |> Client.put(url) |> handle_response
  end

  @doc """
    iex> Spotify.Player.seek_url(device_id: "abc")
    "https://api.spotify.com/v1/me/player/seek?device_id=abc"
  """
  def seek_url(params \\ []) do
    "https://api.spotify.com/v1/me/player/seek" <> query_string(params)
  end

  @doc """
    **Optional params**: `device_id`
  """
  def set_repeat(conn, state, params \\ []) when state in [:track, :context, :off] do
    url = params |> Keyword.put(:state, state) |> repeat_url()
    conn |> Client.put(url) |> handle_response
  end

  @doc """
    iex> Spotify.Player.repeat_url(device_id: "abc")
    "https://api.spotify.com/v1/me/player/repeat?device_id=abc"
  """
  def repeat_url(params \\ []) do
    "https://api.spotify.com/v1/me/player/repeat" <> query_string(params)
  end

  @doc """
    **Optional params**: `device_id`
  """
  def set_shuffle(conn, state, params \\ []) when is_boolean(state) do
    url = params |> Keyword.put(:state, state) |> shuffle_url()
    conn |> Client.put(url) |> handle_response
  end

  @doc """
    iex> Spotify.Player.shuffle_url(device_id: "abc")
    "https://api.spotify.com/v1/me/player/shuffle?device_id=abc"
  """
  def shuffle_url(params \\ []) do
    "https://api.spotify.com/v1/me/player/shuffle" <> query_string(params)
  end

  @doc """
  **Optional Params**: `device_id`
  """
  def set_volume(conn, volume_percent, params \\ []) when volume_percent in 0..100 do
    url = params |> Keyword.put(:volume_percent, volume_percent) |> volume_url()
    conn |> Client.put(url) |> handle_response()
  end

  @doc """
    iex> Spotify.Player.volume_url(device_id: "abc")
    "https://api.spotify.com/v1/me/player/volume?device_id=abc"
  """
  def volume_url(params \\ []) do
    "https://api.spotify.com/v1/me/player/volume" <> query_string(params)
  end

  @doc false
  def build_response(body) do
    case body do
      %{"devices" => devices} -> build_devices(devices)
      %{"is_playing" => _} -> build_playback(body)
    end
  end

  @doc false
  def build_devices(devices) do
    Enum.map(devices, &to_struct(Device, &1))
  end

  def build_playback(playback) do
    playback = to_struct(Playback, playback)
    device = to_struct(Device, playback.device)
    track = to_struct(Track, playback.item)

    playback
    |> Map.put(:device, device)
    |> Map.put(:item, track)
  end
end
