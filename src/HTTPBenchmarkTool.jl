module HTTPBenchmarkTool

using HTTP, StatsBase, Plots, StatsPlots, DataFrames

include("visualizations.jl")

export  benchmark, 
        plot_marginalhist,
        plot_marginalhist_noise!, 
        plot_histogram, 
        plot_histogram_status, 
        showcase,
        plot_histogram_multiple_urls, 
        remove_noise_from_data!, 
        base!

struct MyResponseData
    time::Float16
    status::Int16
end

"""
Benchmarks the specified URL with varying numbers of clients 
with pre-division ( divide and conquer method for distribution) 
of requests for each client.

Parameters:
    - url::String: The URL to benchmark.
    - pure::Bool: Whether to use the pure async method (default is false).
    - req_each::Int: Number of requests per client (default is 10000).
    - client_ns::StepRange{Int}: Range of client numbers.
    - plot::Bool: Whether to plot the results (default is true).
    - kwargs: Additional plotting options.

Returns:
    - df::DataFrame: Results of the benchmark.
"""
function benchmark(url::String; pure=false, req_each=10000, client_ns=10:10:100, plot=true, kwargs...)
    df = DataFrame(NumberOfClients = Int16[], ElapsedTime = Float64[], Status = Int64[])
    for client_n in client_ns
        println("Benchmarking with $client_n clients")
        val = pure ? helper_pure_async(url, client_n, req_each; kwargs...) : 
                     helper_divide_conquer(url, client_n, req_each; kwargs...)
        df = vcat(df, DataFrame(val))
    end
    plot || return df
    plot_histogram_status(df) |> display
    plot_marginalhist(df, xticks=client_ns) |> display
    plot_histogram(df) |> display
    return df
end

"""
Benchmarks the specified URLs with varying numbers of clients.
uses the division and conquare benchmark method by default.

Parameters:
    - urls::Vector{String}: The URLs to benchmark.
    - req_each::Int: Number of requests per client (default is 10000) for each URL.
    - client_ns::StepRange{Int}: Range of client numbers for each URL.
    - pure::Bool: Whether to use the pure async method (default is false).
    - plot::Bool: Whether to plot the results (default is true).
    - kwargs: Additional plotting options.

Returns:
    - dict::Dict: Results of the benchmarks.
    - dict_times::Dict: Elapsed time of each benchmark.
"""
function benchmark(urls::Vector{String}; req_each=10000, client_ns=10:10:100, pure=false, plot=true, kwargs...)
    dict = Dict()
    dict_times = Dict()
    for url in urls
        println("Benchmarking $url")
        ela = @elapsed val = benchmark(url, pure=pure, req_each=req_each, 
                                       client_ns=client_ns, title=url, plot=plot; kwargs...)
        dict[url] = val
        dict_times[url] = ela
    end
    plot || return dict, dict_times
    plot_histogram_multiple_urls(dict) |> display
    return dict, dict_times
end

"""
Helper function for asynchronous requests using multiple clients.

Parameters:
    - url::String: The URL to benchmark.
    - client_n::Int64: Number of clients.
    - req_n::Int64: Total number of requests.
    - kwargs: Additional options.

Returns:
    - Dict: Results of the benchmark.
"""
function helper_pure_async(url::String, client_n::Int64, req_n::Int64; kwargs...)
    data = asyncmap(x -> make_request(url), 1:req_n; ntasks=client_n)
    return Dict(
        "NumberOfClients" => [Int16(client_n) for _ in 1:req_n],
        "ElapsedTime" => [x.time for x in data],
        "Status" => [z.status for z in data]
    )
end

"""
Helper function for dividing and conquering requests among multiple clients.

Parameters:
    - url::String: The URL to benchmark.
    - client_n::Int64: Number of clients.
    - req_n::Int64: Total number of requests.
    - kwargs: Additional options.

Returns:
    - Dict: Results of the benchmark.
"""
function helper_divide_conquer(url::String, client_n::Int64, req_n::Int64; kwargs...)
    reqs_per_client = Int64(floor(req_n/client_n))
    inputs = ones(Int64, client_n) .* reqs_per_client
    inputs[1] = req_n - ((client_n - 1)*reqs_per_client)
    data = asyncmap(x -> make_n_requests(url, x), inputs; ntasks=client_n)
    flat_data = reduce(vcat, data)
    return Dict(
        "NumberOfClients" => [Int16(client_n) for _ in 1:req_n],
        "ElapsedTime" => [x.time for x in flat_data],
        "Status" => [z.status for z in flat_data]
    )
end

"""
Makes a single HTTP request and returns MyResponseData.

Parameters:
    - url::String: The URL to make the request.

Returns:
    - MyResponseData: Response data with time and status information.
"""
function make_request(url::String)
    ela = @elapsed res = HTTP.request("GET", url)
    return MyResponseData(Float16(round(ela, sigdigits=2)), res.status)
end 

"""
Makes multiple HTTP requests and returns an array of MyResponseData.

Parameters:
    - url::String: The URL to make the requests.
    - n::Int64: Number of requests.

Returns:
    - ret::Array{MyResponseData}: Array of response data with time and status information.
"""
function make_n_requests(url::String, n::Int64)
    ret = Array{MyResponseData}(undef, n)
    for i in 1:n
        ela = @elapsed res = HTTP.request("GET", url)
        ret[i] = MyResponseData(ela, res.status)
    end
    return ret
end 

"""
Starts a test HTTP server on the specified port.

Parameters:
    - port::Int: The port number.
"""
function start_test_http_server(port::Int)
    router = HTTP.Router()
    HTTP.register!(router, "GET", "/*", req->HTTP.Response(200, "Test"))
    HTTP.serve(router, port)
end

"""
Showcases the HTTPBenchmarkTool by starting a test server and performing a benchmark.
Made for demonstration usage in the examples/examples.jl file.

Parameters:
    - port: The port number for the test server.
    - req_each: Number of requests for each client.
    - client_ns: Range of client numbers.
"""
function showcase(port, req_each, client_ns)
    Threads.@spawn start_test_http_server(port)
    benchmark("http://localhost:$port/test"; req_each=req_each, client_ns=client_ns)
end

end
