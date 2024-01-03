module HTTPBenchmarkTool

using HTTP, StatsBase, Plots, StatsPlots, DataFrames

include("visualizations.jl")

export benchmark, benchmark_pure, benchmark_threads, plot_marginalhist,
       plot_marginalhist_noise!, plot_histogram, plot_histogram_status, showcase,
       plot_histogram_multiple_urls, remove_noise_from_data!

struct MyResponseData
    time::Float16
    status::Int16
end

function benchmark(url::String; req_each=10000, client_ns=10:10:100, plot=true, kwargs...)
    df = DataFrame(NumberOfClients = Int16[], ElapsedTime = Float64[], Status = Int64[])
    for client_n in client_ns
        println("Benchmarking with $client_n clients")
        val = helper_divide_conquer(url, client_n, req_each; kwargs...)
        df = vcat(df, DataFrame(val))
    end
    plot || return df
    plot_histogram_status(df) |> display
    plot_marginalhist(df, xticks=client_ns) |> display
    plot_histogram(df) |> display
    return df
end

function benchmark_pure(url::String; req_each=10000, client_ns=10:10:100, plot=true, kwargs...)
    df = DataFrame(NumberOfClients = Int16[], ElapsedTime = Float64[], Status = Int64[])
    for client_n in client_ns
        println("Benchmarking with $client_n clients")
        val = helper_pure_async(url, client_n, req_each; kwargs...)
        df = vcat(df, DataFrame(val))
    end
    plot || return df
    plot_histogram_status(df) |> display
    plot_marginalhist(df, xticks=client_ns) |> display
    plot_histogram(df) |> display
    return df
end

function benchmark(urls::Vector{String}; pure=false, plot=true, kwargs...)
    dict = Dict()
    dict_times = Dict()
    for url in urls
        println("Benchmarking $url")
        ela = @elapsed val = pure ? benchmark_pure(url, title=url, plot=plot; kwargs...) :
                     benchmark(url, title=url, plot=plot; kwargs...)
        dict[url] = val
        dict_times[url] = ela
    end
    plot || return dict, dict_times
    plot_histogram_multiple_urls(dict) |> display
    return dict, dict_times
end


function helper_pure_async(url::String, client_n::Int64, req_n::Int64; kwargs...)
    data = asyncmap(x -> make_request(url), 1:req_n; ntasks=client_n)
    return Dict(
        "NumberOfClients" => [Int16(client_n) for _ in 1:req_n],
        "ElapsedTime" => [x.time for x in data],
        "Status" => [z.status for z in data]
    )
end

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

function make_request(url::String)
    ela = @elapsed res = HTTP.request("GET", url)
    return MyResponseData(Float16(round(ela, sigdigits=2)), res.status)
end 


function make_n_requests(url::String, n::Int64)
    ret = Array{MyResponseData}(undef, n)
    for i in 1:n
        ela = @elapsed res = HTTP.request("GET", url)
        ret[i] = MyResponseData(ela, res.status)
    end
    return ret
end 

function start_test_http_server(port::Int)
    router = HTTP.Router()
    HTTP.register!(router, "GET", "/*", req->HTTP.Response(200, "Test"))
    HTTP.serve(router, port)
end

function showcase(port, req_each, client_ns)
    Threads.@spawn start_test_http_server(port)
    benchmark("http://localhost:$port/test"; req_each=req_each, client_ns=client_ns)
end

end
