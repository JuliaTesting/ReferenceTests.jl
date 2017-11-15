# --------------------------------------------------------------------
# plain TXT

function test_reference(file::File{format"TXT"}, actual)
    test_reference_string(file, string(actual))
end

function test_reference(file::File{format"TXT"}, actual::AbstractArray{<:AbstractString})
    test_reference_string(file, actual)
end

# Image as txt using ImageInTerminal
function test_reference(file::File{format"TXT"}, actual::AbstractArray{<:Colorant}; size = (20,40))
    str = @withcolor ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), actual, size...)[1]
    test_reference_string(file, str)
end

# --------------------------------------------------------------------
# SHA as string

function test_reference(file::File{format"SHA256"}, actual)
    test_reference(file, string(actual))
end

function test_reference(file::File{format"SHA256"}, actual::Union{AbstractString,Vector{UInt8}})
    str = bytes2hex(sha256(actual))
    test_reference_string(file, str)
end

function test_reference(file::File{format"SHA256"}, actual::AbstractArray{<:Colorant})
    size_str = bytes2hex(sha256(reinterpret(UInt8,[map(Int64,size(actual))...])))
    img_str = bytes2hex(sha256(reinterpret(UInt8,vec(rawview(channelview(actual))))))
    test_reference_string(file, size_str * img_str)
end

# --------------------------------------------------------------------

function test_reference_string(file::File, actual::AbstractString)
    test_reference_string(file, split(actual, "\n"))
end

function test_reference_string(file::File, actual::AbstractArray{<:AbstractString})
    path = file.filename
    dir, filename = splitdir(path)
    try
        reference = split(readstring(path), "\n")
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
                error("Please run the tests again for any changes to take effect")
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to update reference images")
            end
        end
    catch ex
        if ex isa SystemError # File doesn't exist
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
                error("Please run the tests again for any changes to take effect")
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to create new reference images")
            end
        else
            throw(ex)
        end
    end
end
