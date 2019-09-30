var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#ReferenceTests.jl-Documentation-1",
    "page": "Home",
    "title": "ReferenceTests.jl Documentation",
    "category": "section",
    "text": "ReferenceTests.jl is a Julia package that adds a couple of additional macros to your testing toolbox. In particular, it focuses on functionality for testing values against reference files, which in turn the package can help create and update if need be. ReferenceTests.jl is build on top of FileIO.jl and designed to be used alongside Base.Test."
},

{
    "location": "#Contents-1",
    "page": "Home",
    "title": "Contents",
    "category": "section",
    "text": "Pages = [\"index.md\"]"
},

{
    "location": "#Index-1",
    "page": "Home",
    "title": "Index",
    "category": "section",
    "text": "Pages = [\"index.md\"]"
},

{
    "location": "#ReferenceTests.@withcolor",
    "page": "Home",
    "title": "ReferenceTests.@withcolor",
    "category": "macro",
    "text": "@withcolor ex\n\nMake sure that ex is evaluated while Base.have_color is set to true. The original value of Base.have_color will be restored afterwards.\n\nThis macro is particularily useful for CI, where it is not unusual that  julia is executed without the --color=yes argument by default.\n\n@withcolor print_with_color(:green, \"foo\")\n\n\n\n\n\n"
},

{
    "location": "#ReferenceTests.@io2str",
    "page": "Home",
    "title": "ReferenceTests.@io2str",
    "category": "macro",
    "text": "@io2str ex\n\nSearch and replace the placeholder ::IO with a newly allocated Base.IOBuffer which is afterwards converted to a string and returned.\n\nThis macro allows a user to conveniently test text-based printing functionality that require an IO argument. A particularly common example of such would be a custom Base.show method.\n\nExamples\n\njulia> using ReferenceTests\n\njulia> @io2str print(::IO, \"Hello World\")\n\"Hello World\"\n\njulia> @io2str show(IOContext(::IO, :limit=>true, :displaysize=>(10,10)), \"text/plain\", ones(10))\n\"10-element Array{Float64,1}:\\n 1.0\\n 1.0\\n 1.0\\n ⋮  \\n 1.0\\n 1.0\"\n\n\n\n\n\n"
},

{
    "location": "#ReferenceTests.@test_reference",
    "page": "Home",
    "title": "ReferenceTests.@test_reference",
    "category": "macro",
    "text": "@test_reference filename expr [by] [kw...]\n\nTests that the expression expr with reference filename using equality test strategy by.\n\nThe pipeline of test_reference is:\n\npreprocess expr\nread and preprocess filename\ncompare the results using by\nif test fails in an interactive session (e.g, include(test/runtests.jl)), an interactive dialog will be trigered.\n\nArguments:\n\nfilename::String: relative path to the file that contains the macro invocation.\nexpr: the actual content used to compare.\nby: the equality test function. By default it is isequal if not explicitly stated.\n\nTypes\n\nThe file-extension of filename, as well as the type of the result of evaluating expr, determine how contents are processed and compared. The contents is treated as:\n\nImages when expr is an image type, i.e., AbstractArray{<:Colorant};\nSHA256 when filename endswith *.sha256;\nText as a fallback.\n\nImages\n\nImages are compared approximately using a different by to ignore most encoding and decoding errors. The default function is generated from psnr_equality.\n\nThe file can be either common image files (e.g., *.png), which are handled by FileIO, or text-coded *.txt files, which is handled by ImageInTerminal. Text-coded image has less storage requirements and also allows to view the reference file in a simple terminal using cat.\n\nSHA256\n\nThe hash of the expr and content of filename are compared.\n\ntip: Tip\nThis is useful for a convenient low-storage way of making sure that the return value doesn\'t change for selected test cases.\n\nFallback\n\nSimply test the equality of expr and the contents of filename without any preprocessing.\n\nExamples\n\n# store as string using ImageInTerminal with encoding size (5,10)\n@test_reference \"camera.txt\" testimage(\"cameraman\") size=(5,10)\n\n# using folders in the relative path is allowed\n@test_reference \"references/camera.png\" testimage(\"cameraman\")\n\n# Images can also be stored as hash. Note however that this\n# can only check for equality (no tolerance possible)\n@test_reference \"references/camera.sha256\" testimage(\"cameraman\")\n\n# test images with custom psnr threshold\n@test_reference \"references/camera.png\" testimage(\"cameraman\") by=psnr_equality(20)\n\n# test number with absolute tolerance 10\n@test_reference \"references/string3.txt\" 1338 by=(ref, x)->isapprox(ref, x; atol=10)\n\n\n\n\n\n"
},

{
    "location": "#Public-Interface-1",
    "page": "Home",
    "title": "Public Interface",
    "category": "section",
    "text": "@withcolor\n@io2str\n@test_reference"
},

]}
