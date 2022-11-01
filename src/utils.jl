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
    d = innerjoin(df1, df2; on = :Time, makeunique = true)
    df = @rtransform(d, :Measurement = :Measurement - :Measurement_1)
    return @select(df, :Time, :Measurement)
end

single_channel_mean_and_std(df, wells, channel) = @orderby(
    @select(
        @subset(get_mean_and_std(df, wells), :Channel .== channel),
        :Time,
        :Measurement
    ),
    :Time
)

"""
$(TYPEDSIGNATURES)

Return the least squares fit.
"""
function _least_squares(xs, ys)
    # y = b0 + b1 * x
    ybar = mean(ys)
    xbar = mean(xs)
    b1 =
        sum((xs[i] - xbar) * (ys[i] - ybar) for i in eachindex(xs)) /
        sum((xs[i] - xbar)^2 for i in eachindex(xs))
    b0 = ybar - b1 * xbar
    errs = [(ys[i] - (b0 + b1 * xs[i]))^2 for i in eachindex(xs)]
    rmse = sqrt(mean(errs))
    r2 = 1 - sum(errs) / sum((ys[i] - ybar)^2 for i in eachindex(xs))
    return (b0, b1, r2, rmse)
end
