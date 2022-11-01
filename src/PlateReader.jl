module PlateReader

using XLSX,
    ReadableRegex,
    Dates,
    DataFrames,
    DocStringExtensions,
    Statistics,
    DataFramesMeta,
    Measurements,
    CairoMakie, 
    ColorSchemes

include("config.jl")
include("readers.jl")
include("utils.jl")
include("segmentation.jl")
include("plots.jl")

export config,
    read_data_from_xlsx,
    get_mean_and_std,
    substract_single_channels,
    single_channel_mean_and_std,
    sliding_window,
    top_down,
    plot_growth_fit

end
