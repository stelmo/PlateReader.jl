"""
$(TYPEDSIGNATURES)

Combine multiple wells and return the mean and std of them.
"""
function get_mean_and_std(df, wells)
    d = @subset df @byrow begin
        :Well in wells
    end
    gdf = groupby(d, [:Time, :Channel])
    df_out = combine(gdf, :Measurement => mean, :Measurement => std)
    @rtransform!(df_out, :Measurement = :Measurement_mean ± :Measurement_std)
    return @select(df_out, :Channel, :Time, :Measurement)
end

"""
$(TYPEDSIGNATURES)

Return a new dataframe with time points subtracted.
"""
function substract_single_channels(df1, df2)
    d = innerjoin(df1, df2; on=:Time, makeunique=true)
    df = @rtransform(d, :Measurement = :Measurement - :Measurement_1)
    return @select(df, :Time, :Measurement)
end

single_channel_mean_and_std(df, wells, channel) = @orderby(@select(@subset(get_mean_and_std(df, wells), :Channel .== channel), :Time, :Measurement), :Time) 

