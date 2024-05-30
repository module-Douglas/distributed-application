defmodule DistributedApp.Router do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(:ok, "<h1>There</h1>")
  end

  get "/get" do

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, %{
      time: DateTime.utc_now()
    }
      |> Map.merge(Cache.get())
      |> Jason.encode!()
    )
  end

  get "/put" do

    %{"key" => key, "value" => value} = URI.decode_query(conn.query_string)
    Cache.put(key, value)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, %{
      time: DateTime.utc_now()
    }
      |> Map.merge(Cache.get())
      |> Jason.encode!()
    )
  end

  match _ do

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(:not_found, "<h1>404: Route Not Found</h1>")
  end
end
