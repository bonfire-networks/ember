defmodule Bonfire.Web.LoadTestDashboard do
  @moduledoc """
  LiveDashboard page for monitoring system metrics during load testing.

  Shows real-time system status:
  - VM metrics (memory, processes, schedulers, run queue)
  - Database connection states and pool utilization
  - Instructions for running k6 load tests
  """
  use Phoenix.LiveDashboard.PageBuilder
  use Bonfire.Common.Repo
  import Untangle

  @impl true
  def menu_link(_, _) do
    {:ok, "Load Test"}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div style="padding: 1rem;">
      <h2 style="margin-bottom: 1rem; font-size: 1.5rem; font-weight: bold;">Load Testing Dashboard</h2>

      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1rem; margin-bottom: 2rem;">
        <!-- VM Metrics Card -->
        <div style="background: #f8f9fa; border-radius: 8px; padding: 1rem; border: 1px solid #dee2e6;">
          <h3 style="font-size: 1rem; font-weight: 600; margin-bottom: 0.75rem; color: #495057;">VM Metrics</h3>
          <.live_table
            id="vm-metrics"
            dom_id="vm-metrics-table"
            page={@page}
            title=""
            row_fetcher={&fetch_vm_metrics/2}
            rows_name="metrics"
          >
            <:col field={:metric} sortable={:asc} />
            <:col field={:value} text_align="right" />
          </.live_table>
        </div>

        <!-- DB Connections Card -->
        <div style="background: #f8f9fa; border-radius: 8px; padding: 1rem; border: 1px solid #dee2e6;">
          <h3 style="font-size: 1rem; font-weight: 600; margin-bottom: 0.75rem; color: #495057;">Database Connections</h3>
          <.live_table
            id="db-connections"
            dom_id="db-connections-table"
            page={@page}
            title=""
            row_fetcher={&fetch_db_connections/2}
            rows_name="connections"
          >
            <:col field={:state} sortable={:asc} />
            <:col field={:count} text_align="right" />
          </.live_table>
        </div>
      </div>

      <!-- Instructions -->
      <div style="background: #e7f5ff; border-radius: 8px; padding: 1rem; border: 1px solid #74c0fc; margin-bottom: 1rem;">
        <h3 style="font-size: 1rem; font-weight: 600; margin-bottom: 0.75rem; color: #1971c2;">Running Load Tests</h3>
        <div style="font-family: ui-monospace, monospace; font-size: 0.85rem; line-height: 1.6;">
          <p style="margin-bottom: 0.5rem;"><strong>1. Get session cookie:</strong> Open DevTools → Application → Cookies → Copy "_bonfire_key" value</p>
          <p style="margin-bottom: 0.5rem;"><strong>2. Run load test (50 VUs for 60s):</strong></p>
          <code style="background: #fff; padding: 0.5rem; display: block; border-radius: 4px; margin-bottom: 0.5rem;">
            k6 run -e COOKIE="your_cookie" -e VUS=50 benchmarks/load_test/k6_progressive.js
          </code>
          <p style="margin-bottom: 0.5rem;"><strong>3. Higher load (100 VUs for 2m):</strong></p>
          <code style="background: #fff; padding: 0.5rem; display: block; border-radius: 4px;">
            k6 run -e COOKIE="your_cookie" -e VUS=100 -e DURATION=2m benchmarks/load_test/k6_progressive.js
          </code>
        </div>
      </div>

      <!-- Telemetry Info -->
      <div style="background: #fff3cd; border-radius: 8px; padding: 1rem; border: 1px solid #ffc107;">
        <h3 style="font-size: 1rem; font-weight: 600; margin-bottom: 0.75rem; color: #856404;">Key Metrics to Watch</h3>
        <p style="font-size: 0.9rem; color: #856404;">
          Monitor these in the <strong>Metrics</strong> tab during load tests:
        </p>
        <ul style="font-size: 0.85rem; margin-top: 0.5rem; padding-left: 1.5rem; color: #856404;">
          <li><code>phoenix.endpoint.stop.duration</code> - Request latency (TTFB)</li>
          <li><code>phoenix.live_view.mount.stop.duration</code> - LiveView mount time</li>
          <li><code>bonfire.repo.query.queue_time</code> - DB pool saturation indicator</li>
        </ul>
      </div>
    </div>
    """
  end

  defp fetch_vm_metrics(_params, _node) do
    memory = :erlang.memory()

    metrics = [
      %{metric: "Memory Total", value: format_mb(memory[:total])},
      %{metric: "Memory Processes", value: format_mb(memory[:processes])},
      %{metric: "Memory Binary", value: format_mb(memory[:binary])},
      %{metric: "Memory ETS", value: format_mb(memory[:ets])},
      %{metric: "Process Count", value: "#{:erlang.system_info(:process_count)}"},
      %{metric: "Process Limit", value: "#{:erlang.system_info(:process_limit)}"},
      %{metric: "Run Queue", value: "#{:erlang.statistics(:run_queue)}"},
      %{metric: "Schedulers Online", value: "#{:erlang.system_info(:schedulers_online)}"}
    ]

    {metrics, Enum.count(metrics)}
  end

  defp fetch_db_connections(_params, _node) do
    try do
      result =
        repo().query!(
          "SELECT state, count(*) FROM pg_stat_activity WHERE datname LIKE 'bonfire%' GROUP BY state ORDER BY count DESC"
        )

      connections =
        result.rows
        |> Enum.map(fn [state, count] ->
          %{state: state || "null", count: "#{count}"}
        end)

      pool_size = repo().config()[:pool_size] || 10
      connections = connections ++ [%{state: "Pool Size (config)", count: "#{pool_size}"}]

      {connections, Enum.count(connections)}
    rescue
      e ->
        debug(e, "Failed to fetch DB connections")
        {[%{state: "Error", count: "Could not fetch"}], 1}
    end
  end

  defp format_mb(bytes) when is_integer(bytes) do
    mb = bytes / 1_000_000
    "#{Float.round(mb, 1)} MB"
  end

  defp format_mb(_), do: "N/A"
end
