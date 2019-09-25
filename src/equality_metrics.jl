function default_image_equality(reference, actual)
    try
        Images.@test_approx_eq_sigma_eps(reference, actual, ones(length(axes(actual))), 0.01)
        return true
    catch err
        if err isa ErrorException
            return false
        else
            rethrow()
        end
    end
end
