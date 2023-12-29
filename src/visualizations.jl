function base!(data::DataFrame, data_symbol::Symbol)
    data_mean = mean(data[:, data_symbol])
    exp = ceil(-log10(data_mean))
    data[:, data_symbol] .*= 10^exp
end

function remove_noise_from_data!(data::DataFrame, data_symbol::Symbol)
    base!(data, data_symbol)
    data_mean = mean(data[:, data_symbol])
    σ = std(data[:, data_symbol])
    subset!(data, data_symbol => ByRow(x -> abs(x - data_mean) < σ))
end

function plot_marginalhist(data::DataFrame, x_symbol::Symbol, data_symbol::Symbol, kwargs...)
    @df data marginalhist(:NumberOfClients, :ElapsedTime, 
                          xlabel="number of parallel connections",
                          ylabel="response time[ms]",
                          kwargs...)

end