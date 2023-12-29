using Revise
using HTTPBenchmarkTool

start_simple_http_server(3000)



bun_data = benchmark("http://localhost:3000"; req_each=1000, client_ns=10:10:100)
deno_data = benchmark("http://localhost:3001"; req_each=100000, client_ns=10:10:100)
node_data = benchmark("http://localhost:3002"; req_each=100000, client_ns=10:10:100)

