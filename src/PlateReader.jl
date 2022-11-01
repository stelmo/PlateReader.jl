module PlateReader

using XLSX, ReadableRegex, Dates, DataFrames, DocStringExtensions

include("readers.jl")
include("config.jl")

export read_data_from_xlsx, config

end
