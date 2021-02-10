"""
    @test_reference_plot filename plot [by] [kw...]

Tests that the `plot` with reference `filename` using
equality test strategy `by`. The macro simply converts
the plot object to a PNG image and forwards it to the
[`@test_reference`](@ref) macro.
"""
macro test_reference_plot(reference, actual, kws...)
    ref = esc(reference)
    plt = esc(actual)
    opt = esc(kws)
    :(@test_reference $ref asimage($plt))
end

# helper function to convert a Plots.jl plot
# into an image for visual comparison
function asimage(plt)
    io = IOBuffer()
    show(io, "image/png", plt)
    seekstart(io)
    PNGFiles.load(io)
end
