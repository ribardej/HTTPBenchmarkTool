using Revise
using HTTPBenchmarkTool

#-------------------------SHOWCASE-------------------------#

data = showcase(3003, 1000, 10:10:100)

plot_marginalhist(data, xticks=10:10:100)  
plot_histogram(data)
plot_histogram_status(data)

remove_noise_from_data!(data, :ElapsedTime)
base!(data, :ElapsedTime)

plot_marginalhist_noise!(data, xticks=10:10:100)


#-------------------------BENCHMARKS-------------------------#

#For these benchmarks, the servers need to be running on port 3000, 3001, 3002 respectively.    
data, times = benchmark(["http://localhost:3000", 
                  "http://localhost:3001", 
                  "http://localhost:3002"]; req_each=10000, client_ns=10:10:100, plot=false)
remove_noise_from_data!(data, :ElapsedTime)
plot_histogram_multiple_urls(data)


#For these benchmarks, the servers need to be running on port 3000, 3001, 3002 respectively.
bun_data = benchmark("http://localhost:3000"; pure=true, req_each=10000, client_ns=10, plot=false)
deno_data = benchmark("http://localhost:3001"; req_each=100000, client_ns=10:10:100)
node_data = benchmark("http://localhost:3002"; req_each=100000, client_ns=10:10:100)
