# HTTPBenchmarkTool [![Build Status](https://github.com/ribardej/HTTPBenchmarkTool.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ribardej/HTTPBenchmarkTool.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Purpose
HTTP benchmark tool makes possible to simulate traffic on a server and provide statistics along with their visualization.

## Functionality
The main function of the package is the benchmark() function with two methods.
the parameters of the function are:
1. 
    1. url::String: The URL to benchmark.
    2. urls::Vector{String}: The URLs to benchmark.
2. pure::Bool: Whether to use the pure async method (default is false).
3. req_each::Int: Number of requests per client (default is 10000).
4. client_ns::StepRange{Int}: Range of client numbers (default is 10:10:100).
5. plot::Bool: Whether to plot the results (default is true).
6. kwargs: Additional plotting options (used only if plot is set to true).

There are some pre-made functions for visualizing the measured data in the visualizations.jl file. These can help you to create:
+ Marginal histograms
+ Histograms for visualization of multiple measurments

Because of the non-deterministic nature of servers, some values may be very distorted from the others, this will make the visualization not so visual-pleasing. To remove this kind of noise from the measured data you can use function remove_noise_from_data!() which will permanently remove the distorted values and improve the visualization methods.

## Examples
1. This code will benchmark a server on url "http://localhost:3000" and plot a marginal histogram of the average response time based on number of clients
```julia
using HTTPBenchmarkTool
# Note: there needs to be a running server on the specified url, otherwise the call will result into an error
data = benchmark("http://localhost:3000"; req_each=10000, client_ns=10:10:100)
plot_marginalhist(data, xticks=10:10:100, ylims=(0.0, 2.0)) 
```
The resulting diagram could look like this:
![label](/examples/bun.jpg "marginal histogram")

2. This code will benchmark multiple servers running on specified urls and histogram of all response times
```julia
using HTTPBenchmarkTool
# Note: for these benchmarks, the servers need to be running on port 3000, 3001, 3002 respectively.    
data, times = benchmark(["http://localhost:3000", 
                  "http://localhost:3001", 
                  "http://localhost:3002"]; req_each=10000, client_ns=10:10:100, plot=false)
remove_noise_from_data!(data)
plot_histogram_multiple_urls(data)
```
The resulting diagram could look like this:
![label2](/examples/histogram.png "histogram multiple urls")
