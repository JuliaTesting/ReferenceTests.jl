function test_reference_file(filename::String, actual)
    test_reference_file(extended_query(filename), actual)
end

function test_reference_file(file::File{format"TXT"}, actual::String)
    test_reference_file(file, [actual])
end

function test_reference_file(file::File{format"TXT"}, actual::AbstractArray{<:Colorant})
    println(file)
end
