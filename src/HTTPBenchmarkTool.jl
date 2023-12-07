module HTTPBenchmarkTool

using HTTP, StatsBase, Plots

export benchmark_dummy_v3

struct MyResponseData
    time::Float64
    status::Int16
end


function benchmark_dummy_v3(url::String, client_n::Int64, req_n::Int64; kwargs...)
    data = asyncmap(x -> make_request(url), 1:req_n; ntasks=client_n)
    time_data = [x.time for x in data]
    requests_per_second = req_n / sum(time_data)
    mean_response_time = sum(time_data) / req_n
    hist = fit(Histogram, time_data, nbins=20)
    visualize_results(requests_per_second, mean_response_time, hist; kwargs...)
    println("Time elapsed: ", sum(time_data))
    return Dict(
        "RequestsPerSecond" => requests_per_second,
        "MeanResponseTime" => mean_response_time,
        "ResponseTimeHistogram" => hist
    )
end

function make_request(url::String)
    ela = @elapsed res = HTTP.request("GET", url)
    return MyResponseData(ela, res.status)
end 

function visualize_results(requests_per_second, mean_response_time, hist; kwargs...)
    plot(hist, xlabel="Response Time", ylabel="Frequency", title="Response Time Distribution")
    if haskey(kwargs, :saveplot) && kwargs[:saveplot]
        savefig("response_time_distribution.png")
    else
        display(Plots.current())
    end
end


end
