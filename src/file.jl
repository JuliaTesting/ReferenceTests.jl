function test_reference_file(filename::AbstractString, actual)
    test_reference_file(extended_query(filename), actual)
end

function test_reference_file(file::File{format"TXT"}, img::AbstractArray{<:Colorant})
    str = @withcolor ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), img, 20, 40)[1]
    test_reference_file(file, str)
end

function test_reference_file(file::File{format"TXT"}, actual::AbstractString)
    test_reference_file(file, [actual])
end

function test_reference_file(file::File{format"TXT"}, actual::AbstractArray{<:AbstractString})
    path = file.filename
    dir, filename = splitdir(path)
    try
        reference = replace.(readlines(path), ["\n"], [""])
        try
            @assert reference == actual # to throw error
            @test true # to increase test counter if reached
        catch # test failed
            println("Test for \"$filename\" failed.")
            println("- REFERENCE -------------------")
            println.(reference)
            println("-------------------------------")
            println("- ACTUAL ----------------------")
            println.(actual)
            println("-------------------------------")
            if isinteractive()
                print("Replace reference with actual result (path: $path)? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    write(path, join(actual, "\n"))
                end
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to update reference images")
            end
        end
    catch ex
        if isa(ex, SystemError) # File doesn't exist
            println("Reference file for \"$filename\" does not exist.")
            println("- NEW CONTENT -----------------")
            println.(actual)
            println("-------------------------------")
            if isinteractive()
                print("Create reference file with above content (path: $path)? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    mkpath(dir)
                    write(path, join(actual, "\n"))
                end
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to create new reference images")
            end
        else
            throw(ex)
        end
    end
end
