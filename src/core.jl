##########################################

# Final function
# all other functions should hit one of this eventually
# Which handles the actual testing and user prompting

function test_reference(
    file::File{F},
    raw_actual::T,
    equiv=nothing,
    rendermode=nothing;
    kw...) where {F <: DataFormat, T}

    path = file.filename
    dir, filename = splitdir(path)

    # infer the default rendermode here
    # since `nothing` is always passed to this method from
    # test_reference(filename::AbstractString, raw_actual; kw...)
    if rendermode === nothing
        rendermode = default_rendermode(F, raw_actual)
    end

    # preprocessing when reference file doesn't exists
    if !isfile(path)
        println("Reference file for \"$filename\" does not exist.")
        render(rendermode, raw_actual)

        if !isinteractive()
            error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to create new reference images")
        end

        if !input_bool("Create reference file with above content (path: $path)?")
            @test false
        else
            mkpath(dir)
            savefile(file, raw_actual)
            @info("Please run the tests again for any changes to take effect")
        end

        return nothing # skip current test case
    end

    # file exists
    actual = _convert(F, raw_actual; kw...)
    reference = loadfile(T, file)

    if equiv === nothing
        # generally, `reference` and `actual` are of the same type after preprocessing
        equiv = default_equality(reference, actual)
    end

    if equiv(reference, actual)
        @test true # to increase test counter if reached
    else
        # post-processing when test fails
        println("Test for \"$filename\" failed.")
        render(rendermode, reference, actual)

        if !isinteractive()
            error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to update reference images")
        end

        if !input_bool("Replace reference with actual result (path: $path)?")
            @test false
        else
            savefile(file, actual)
            @info("Please run the tests again for any changes to take effect")
        end
    end
end
