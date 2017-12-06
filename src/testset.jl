struct MissingFile
    path::String
    content::String
    inner::Fail
end

function MissingFile(path, actual_content)
    inner =  Fail(:test, # It is actually more of an Error than a Fail
                  :(@test_reference $path [missing]  == actual), # ideally true code would be where ctual is
                  Expr(:comparison, "", :(==), actual_content), # This is triggers the normal nonequal output (or diffs if using extended testset)
                  @__LINE__) #Should be the line of the test that failed
    MissingFile(path, actual_content, inner)
end

struct MismatchedFile
    path::String
    reference_content::String
    content::String
    inner::Fail
end

function MismatchedFile(path, reference_content, actual_content)
    inner =  Fail(:test,
                  :(@test_reference $path == actual), # ideally true code would be where actual is
                  Expr(:comparison, reference_content, :(==), actual_content), # This is triggers the normal nonequal output (or diffs if using extended testset)
                  @__LINE__) #Should be the line of the test that failed
    MismatchedFile(path, reference_content, actual_content, inner)
end

function process_result(res::MismatchedFile)
    record(get_testset(),  res.inner)
    createfile(res.path, res.content, "Replace reference, with actual result (path: $(res.path)? [y/n] ")
end

function process_result(res::MissingFile)
    record(get_testset(),  res.inner)
    createfile(res.path, res.content, "Create reference file with above content (path: $(res.path)? [y/n] ")
end

function createfile(path, content, message)
    dir = dirname(path)
    if isinteractive()
        print(message)
        answer = first(readline())
        if answer == 'y'
            mkpath(dir)
            write(path, content)
            warn("Please run the tests again for any changes to take effect")
        end
    end
end

