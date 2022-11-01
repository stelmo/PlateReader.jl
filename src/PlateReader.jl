module PlateReader

using XLSX,
    ReadableRegex,
    Dates,
    DataFrames,
    DocStringExtensions,
    Statistics,
    DataFramesMeta,
    Measurements

include("config.jl")
include("readers.jl")
include("utils.jl")
include("segmentation.jl")

export config,
    read_data_from_xlsx,
    get_mean_and_std,
    substract_single_channels,
    single_channel_mean_and_std,
    sliding_window

end
