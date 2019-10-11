macro test_reference_broken(reference, actual, kws...)
    dir = Base.source_dir()
    expr = :(test_reference_broken(abspath(joinpath($dir, $(esc(reference)))), $(esc(actual))))
    for kw in kws
        (kw isa Expr && kw.head == :(=)) || error("invalid signature for @test_reference_broken")
        k, v = kw.args
        push!(expr.args, Expr(:kw, k, esc(v)))
    end
    expr
end

function test_reference_broken(
    filename::AbstractString, raw_actual;
    by = nothing, render = nothing, kw...)

    test_reference_broken(query_extended(filename), raw_actual, by, render; kw...)
end

function test_reference_broken(
    file::File{F},
    raw_actual::T,
    equiv=nothing,
    rendermode=nothing;
    kw...) where {F <: DataFormat, T}

    path = file.filename
    dir, filename = splitdir(path)

    # infer the default rendermode here
    # since `nothing` is always passed to this method from
    # test_reference_broken(filename::AbstractString, raw_actual; kw...)
    if rendermode === nothing
        rendermode = default_rendermode(F, raw_actual)
    end

    # mark as broken if file doesn't exist -- unlike test_reference
    if !isfile(path)
        @test_broken false
        return nothing
    end

    # file exists
    actual = _convert(F, raw_actual; kw...)
    reference = loadfile(T, file)

    if equiv === nothing
        # generally, `reference` and `actual` are of the same type after preprocessing
        equiv = default_equality(reference, actual)
    end

    if equiv(reference, actual)
        println("Got correct result for \"$filename\", please change to @test_reference if no longer broken.")
        render(rendermode, reference, actual)

        @test_broken true
    else
        @test_broken false
    end

    return nothing # TODO: @test_broken returns a Test.Broken or Test.Error
end
