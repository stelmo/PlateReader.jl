module PlateReader

using XLSX, ReadableRegex, Dates, DataFrames, DocStringExtensions

include("config.jl")
include("readers.jl")
include("utils.jl")

export config, read_data_from_xlsx

end
