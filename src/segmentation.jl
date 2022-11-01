"""
$(TYPEDSIGNATURES)

Assume equally spaced. Only return fits to segments longer than `min_length`,
break segments when the coefficient of determination drops below `min_r2`. 
"""
function sliding_window(xs, ys; min_length = 0.5, max_rmse = 0.2)
    break_points = [-1:0]
    linear_fits = [(0.0, 0.0, 0.0)]
    min_idx_length = findfirst(x -> x > min_length, xs)

    while true
        start_point = last(last(break_points)) + 1
        start_point + min_idx_length > length(xs) && break
        b0, b1, r2 = 0, 0, 0

        for i = (start_point+min_idx_length):length(xs)
            temp_b0, temp_b1, temp_r2, temp_rmse =
                _least_squares(xs[start_point:i], ys[start_point:i])
            if temp_rmse > max_rmse || i == length(xs)
                push!(break_points, start_point:(i-1))
                push!(linear_fits, (b0, b1, r2))
                break
            else
                b0, b1, r2 = temp_b0, temp_b1, temp_r2
            end
        end
    end
    idxs = findall(x -> length(x) > min_idx_length, break_points)
    linear_fits[idxs], break_points[idxs]
end

"""
$(TYPEDSIGNATURES)

"""
function top_down(xs, ys; min_time_length = 0.5, max_rmse = 0.05)
    rngs = []
    min_length = findfirst(x -> x > min_time_length, xs)
    rmse_f(x) = last(_least_squares(xs[x], ys[x]))

    _top_down!(rngs, 1, length(ys), min_length, rmse_f; max_rmse)

    [_least_squares(xs[rng], ys[rng]) for rng in rngs], rngs
end

function _find_optimum_break_point(start_idx, stop_idx, min_length, rmse_f)

    rngs = [
        (start_idx:bp, (bp+1):stop_idx) for
        bp = (min_length+start_idx-1):(stop_idx-min_length)
    ]

    best_rmse, best_split_idx =
        findmin(rmse_f(rng1) + rmse_f(rng2) for (rng1, rng2) in rngs)
    rng1, rng2 = rngs[best_split_idx]

    best_rmse, rng1, rng2
end

function _top_down!(rngs, start_idx, stop_idx, min_length, rmse_f; max_rmse = 0.05)

    best_rmse, rng1, rng2 =
        _find_optimum_break_point(start_idx, stop_idx, min_length, rmse_f)

    # minimum range length =  2 * min_length so that the ranges can be split in two
    if best_rmse < max_rmse ||
       (length(rng1) < min_length * 2 && length(rng2) < min_length * 2)
        push!(rngs, rng1)
        push!(rngs, rng2)
    elseif length(rng1) < min_length * 2
        push!(rngs, rng1)
        _top_down!(rngs, first(rng2), last(rng2), min_length, rmse_f; max_rmse)
    elseif length(rng2) < min_length * 2
        push!(rngs, rng2)
        _top_down!(rngs, first(rng1), last(rng1), min_length, rmse_f; max_rmse)
    else
        _top_down!(rngs, first(rng1), last(rng1), min_length, rmse_f; max_rmse)
        _top_down!(rngs, first(rng2), last(rng2), min_length, rmse_f; max_rmse)
    end

    nothing
end

"""
$(TYPEDSIGNATURES)

"""
function bottom_up(xs, ys)
    (0.16226828241651078, 1:153, 154:261)
    rng1 = 1:153
    xs = xs[rng2]
    ys = ys[rng2]
end
