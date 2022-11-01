# convert string time to floats
get_time(x, time_delim) = begin
    m = match(one_or_more(DIGIT) * exactly(1, " $time_delim"), x)
    isnothing(m) ? 0.0 : parse(Float64, first(split(m.match)))
end
string_to_hours(x) = 1/60 * get_time(x, "min") + get_time(x, "h")

config = (
    biolector = (
        instrument = "biolector",
        sheet_name = "Raw Data",
        well_name = "Well",
        time_row_offset = 2,
        time_col_offset = 4,
        descriptor_num_headers = 4,
        descriptor_headers_row_offset = 3,
        to_hours_func = x -> x,
    ),
    clariostar = (
        instrument = "clariostar",
        sheet_name = "Table Range 1",
        well_name = "Well",
        time_row_offset = 1,
        time_col_offset = 2,
        descriptor_num_headers = 2,
        descriptor_headers_row_offset = 2,
        to_hours_func = x -> string_to_hours(x),
    ),
)
