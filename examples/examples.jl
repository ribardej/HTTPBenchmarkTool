using Revise
using HTTPBenchmarkTool, StatsPlots, DataFrames


# @time val = benchmark_dummy_v4("http://google.com", 25, 1000)
# @time val = benchmark_dummy_v3("http://google.com", 25, 1000)

bun_data = benchmark("http://localhost:3000"; req_each=100000, client_ns=10:10:100)
deno_data = benchmark("http://localhost:3001"; req_each=10000, client_ns=10:10:100)
node_data = benchmark("http://localhost:3002"; req_each=10000, client_ns=10:10:100)

