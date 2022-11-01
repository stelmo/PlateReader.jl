"""
$(TYPEDSIGNATURES)

Assume equally spaced. Only return fits to segments longer than `min_length`,
break segments when the coefficient of determination drops below `min_r2`. 
"""
function sliding_window(xs, ys; min_length = 0.1, max_rmse = 0.2)
    break_points = [-1:0,]
    linear_fits = [(0.0,0.0,0.0),]
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
function top_down(xs, ys)

end

"""
$(TYPEDSIGNATURES)

"""
function bottom_up(xs, ys)

end
