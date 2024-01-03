using Revise
using HTTPBenchmarkTool

data = showcase(3003, 1000, 10:10:100)

plot_marginalhist(data, xticks=10:10:100)
plot_marginalhist_noise!(data, xticks=10:10:100)
plot_histogram(data)
plot_histogram_status(data)

data, times = benchmark(["http://localhost:3000", 
                  "http://localhost:3001", 
                  "http://localhost:3002"]; req_each=100000, client_ns=10:25:210, plot=false)


bun_data = benchmark("http://localhost:3000"; req_each=10000, client_ns=10:10:100)
deno_data = benchmark("http://localhost:3001"; req_each=100000, client_ns=10:10:100)
node_data = benchmark("http://localhost:3002"; req_each=100000, client_ns=10:10:100)
