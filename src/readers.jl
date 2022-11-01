"""
$(TYPEDSIGNATURES)

Reads the data from `file_location` into a dataframe. Supply the config
parameters with `options` to handle different plate reader types.
"""
function read_data_from_xlsx(file_location, options)
    xf = XLSX.readxlsx(file_location)

    sheet = xf[options.sheet_name]

    start_col = match(one_or_more(NON_DIGIT), sheet.dimension.start.name).match
    start_col_num = sheet.dimension.start.column_number
    start_row_num = sheet.dimension.start.row_number

    stop_col = match(one_or_more(NON_DIGIT), sheet.dimension.stop.name).match
    stop_row_num = sheet.dimension.stop.row_number
    stop_col_num = sheet.dimension.stop.column_number

    # Assume well is in column 1
    well_row_num = first(
        indexin(
            [options.well_name],
            sheet["$start_col$start_row_num:$start_col$stop_row_num"][:],
        ),
    )

    ts = [
        options.to_hours_func(sheet[well_row_num+options.time_row_offset, j]) for
        j = (start_col_num+options.time_col_offset):stop_col_num
    ]
    descriptor_headers = [
        sheet[well_row_num, j] for
        j = start_col_num:(start_col_num+options.descriptor_num_headers-1)
    ]
    descriptors = reshape(
        [
            sheet[i, j] for
            j = start_col_num:(start_col_num+options.descriptor_num_headers-1) for
            i = (well_row_num+options.descriptor_headers_row_offset):stop_row_num
        ],
        :,
        options.descriptor_num_headers,
    )
    if options.instrument == "clariostar"
        # add a channel to make downstream analysis easier
        push!(descriptor_headers, "Channel")
        descriptors = hcat(descriptors, fill(sheet[well_row_num, 3], size(descriptors, 1)))
    end
    measurements = reshape(
        [
            sheet[i, j] for
            j = (start_col_num+options.descriptor_num_headers):stop_col_num for
            i = (well_row_num+options.descriptor_headers_row_offset):stop_row_num
        ],
        :,
        length(ts),
    )

    nts = [] # named tuples
    for well_idx in axes(descriptors, 1)
        for (t_idx, t_val) in enumerate(ts)
            push!(
                nts,
                (;
                    [
                        Symbol(descriptor_headers[i]) => descriptors[well_idx, i] for
                        i in eachindex(descriptor_headers)
                    ]...,
                    :Time => t_val,
                    :Measurement => measurements[well_idx, t_idx],
                ),
            )
        end
    end

    DataFrame(nts)
end
