module HTTPBenchmarkTool

using HTTP

export greet, benchmark_dummy

greet() = println("HTTPStart")

function benchmark_dummy(url::String, client_n::Int64, req_n::Int64)
    return @time asyncmap(x->HTTP.request("GET", url), 1:req_n; ntasks=client_n)
end


end
