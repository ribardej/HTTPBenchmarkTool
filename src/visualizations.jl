# This function scales a specified column in the DataFrame by a power of 10 to improve visualization.
function base!(data::DataFrame, data_symbol::Symbol)
    data_mean = mean(data[:, data_symbol])
    exp = ceil(-log10(data_mean))
    data[:, data_symbol] .*= 10^exp
end

"""
Removes noise from the data by filtering out noise (unwanted values for visualizations).
Parameters:
    - data::DataFrame: The input DataFrame.
    - data_symbol::Symbol: The column symbol for which noise is removed.
    - std_factor::Int: Standard deviation factor for filtering (default is 2).
Returns:
    - data::DataFrame: The input DataFrame with noise removed.
"""
function remove_noise_from_data!(data::DataFrame, data_symbol::Symbol; std_factor=2)
    data_mean = mean(data[:, data_symbol])
    σ = std(data[:, data_symbol])
    subset!(data, data_symbol => ByRow(x -> abs(x - data_mean) < std_factor*σ))
end

function remove_noise_from_data!(data::Dict, data_symbol::Symbol; std_factor=2)
    for (url, df) in data
        data_mean = mean(df[:, data_symbol])
        σ = std(df[:, data_symbol])
        subset!(df, data_symbol => ByRow(x -> abs(x - data_mean) < std_factor*σ))
    end
end

function plot_marginalhist(data::DataFrame; kwargs...)
    @df data marginalhist(:NumberOfClients, :ElapsedTime, 
                          xlabel="number of parallel connections",
                          ylabel="response time";
                          kwargs...)                     
end

function plot_histogram_status(data::DataFrame; kwargs...)
    @df data histogram(:Status, 
                          xlabel="status code",
                          ylabel="number of requests",
                          xlims=(100, 500), 
                          xticks=100:100:500,
                          label=nothing;
                          kwargs...)                     
end

function plot_marginalhist_noise!(data::DataFrame; kwargs...)
    remove_noise_from_data!(data, :ElapsedTime)
    @df data marginalhist(:NumberOfClients, :ElapsedTime, 
                          xlabel="number of parallel connections",
                          ylabel="response time[ms]";
                          kwargs...)
end

function plot_histogram(data::DataFrame; kwargs...)
    @df data histogram(:ElapsedTime, 
                       xlabel="response time[ms]",
                       ylabel="number of requests";
                       kwargs...) |> display
end

function plot_histogram!(data::DataFrame; kwargs...)
    @df data histogram!(:ElapsedTime, 
                       xlabel="response time[ms]",
                       ylabel="number of requests";
                       kwargs...) |> display
end

function compute_alpha(size::Int64)
    val = round(1.0 / size, digits=2)
    val < 0.2 && return 0.2
    return val
end

function plot_histogram_multiple_urls(dict::Dict; kwargs...)
    α = compute_alpha(length(dict))
    colors = [:red, :blue, :green, :orange, :purple, :grey, :yellow]
    colors_length = length(colors)
    idx = 0
    for (url, data) in dict
        idx == 0 && plot_histogram(data, label=url, alpha=α, color=colors[(idx % colors_length) + 1]; kwargs...)
        idx == 0 || plot_histogram!(data, label=url, alpha=α, color=colors[(idx % colors_length) + 1]; kwargs...)
        idx += 1
    end 
    
end