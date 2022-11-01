"""
$(TYPEDSIGNATURES)

"""
function plot_growth_fit(df, wells, blank_wells, channel, title)

    media = single_channel_mean_and_std(df, wells, channel)
    blank = single_channel_mean_and_std(df, blank_wells, channel)
    data = substract_single_channels(media, blank)
    
    # plot growth curve
    xs = data[!, :Time]
    ys = data[!, :Measurement]
    
    fig = Figure();
    ax = Axis(fig[1, 1], ylabel = channel, title = title)
    lines!(ax, xs, [y.val for y in ys]; color = ColorSchemes.Blues_9[9], linewidth = 6)
    band!(
        ax,
        xs,
        [y.val - y.err for y in ys],
        [y.val + y.err for y in ys];
        color = ColorSchemes.Blues_9[4],
    )
    
    # get growth rates
    # only consider positive points
    idxs = findall(x -> x > 1e-3, data[!, :Measurement])
    xs = data[!, :Time][idxs]
    ys = [log(y.val) for y in data[!, :Measurement][idxs]]
    
    linear_fits, break_points = top_down(xs, ys; min_time_length = 0.5, max_rmse = 0.05)
    
    for ((b0, b1, _), bprng) in zip(linear_fits, break_points)
        ypreds = b0 .+ b1 .* xs[bprng]
        lines!(ax, xs[bprng], exp.(ypreds); color = ColorSchemes.Oranges_9[4], linewidth = 3)
    end
    hidexdecorations!(ax, ticks = false, ticklabels = false, label = false, grid = false)
    hideydecorations!(ax, ticks = false, ticklabels = false, label = false, grid = false)
        
    # plot fit stats
    ax1 = Axis(
        fig[2, 1],
        yticklabelcolor = ColorSchemes.PiYG[1],
        ylabel = "Growth rate [1/h]",
        ylabelcolor = ColorSchemes.PiYG[1],
    )
    ax2 = Axis(
        fig[2, 1],
        yticklabelcolor = ColorSchemes.PiYG[end],
        yaxisposition = :right,
        ylabel = "Fit R²",
        ylabelcolor = ColorSchemes.PiYG[end],
    )
    
    for ((_, b1, r2), bprng) in zip(linear_fits, break_points)
        lines!(ax1, xs[bprng], fill(b1, length(xs[bprng])); color = ColorSchemes.PiYG[1])
        lines!(ax2, xs[bprng], fill(r2, length(xs[bprng])); color = ColorSchemes.PiYG[end])
    end
    
    hidexdecorations!(ax1, ticks = false, ticklabels = false, label = false)
    hideydecorations!(ax1, ticks = false, ticklabels = false, label = false)
    hidexdecorations!(ax2, ticks = false, ticklabels = false, label = false)
    hideydecorations!(ax2, ticks = false, ticklabels = false, label = false)
    
    fig
end