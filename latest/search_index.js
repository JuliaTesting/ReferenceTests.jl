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
    "text": "Pages = [\"public.md\"]"
},

{
    "location": "#Index-1",
    "page": "Home",
    "title": "Index",
    "category": "section",
    "text": "Pages = [\"public.md\"]"
},

{
    "location": "#ReferenceTests.@withcolor",
    "page": "Home",
    "title": "ReferenceTests.@withcolor",
    "category": "Macro",
    "text": "@withcolor ex\n\nMake sure that ex is evaluated while Base.have_color is set to true. The original value of Base.have_color will be restored afterwards.\n\nThis macro is particularily useful for CI, where it is not unusual that  julia is executed without the --color=yes argument by default.\n\n@withcolor print_with_color(:green, \"foo\")\n\n\n\n"
},

{
    "location": "#ReferenceTests.@io2str",
    "page": "Home",
    "title": "ReferenceTests.@io2str",
    "category": "Macro",
    "text": "@io2str ex\n\nSearch and replace the placeholder ::IO with a newly allocated Base.IOBuffer which is afterwards converted to a string and returned.\n\nThis macro allows a user to conveniently test text-based printing functionality that require an IO argument. A particularly common example of such would be a custom Base.show method.\n\nExamples\n\njulia> using ReferenceTests\n\njulia> @io2str print(::IO, \"Hello World\")\n\"Hello World\"\n\njulia> @io2str show(IOContext(::IO, limit=true, displaysize=(10,10)), \"text/plain\", ones(10))\n\"10-element Array{Float64,1}:\\n 1.0\\n 1.0\\n 1.0\\n ⋮  \\n 1.0\\n 1.0\"\n\n\n\n"
},

{
    "location": "#ReferenceTests.@test_reference",
    "page": "Home",
    "title": "ReferenceTests.@test_reference",
    "category": "Macro",
    "text": "@test_reference filename ex [kw...]\n\nTests that the expression ex evaluates to the same result as stored in the given reference file, which is denoted by the string filename. Executing the code in an interactive julia session will trigger an interactive dialog if results don't match. This dialog allows the user to create and/or update the reference files.\n\nThe given string filename is assumed to be the relative path to the file that contains the macro invocation. This likely means that the path filename is relative to the test/ folder of your package.\n\nThe file-extension of filename, as well as the type of the result of evaluating ex, determine how the actual value is compared to the reference value. The default implementation will do a simple equality check with the result of FileIO.load. This means that it is the user's responsibility to have the required IO package installed.\n\nColorant arrays (i.e.) receive special treatment. If the extension of filename is txt then the package ImageInTerminal will be used to create a string based cure approximation of the image. This will have low storage requirements and also allows to view the reference file in a simple terminal using cat.\n\nAnother special file extension is sha256 which will cause the hash of the result of ex to be stored and compared as plain text. This is useful for a convenient low-storage way of making sure that the return value doesn't change for selected test cases.\n\nExamples\n\n# store as string using ImageInTerminal with encoding size (5,10)\n@test_reference \"camera.txt\" testimage(\"cameraman\") size=(5,10)\n\n# using folders in the relative path is allowed\n@test_reference \"references/camera.png\" testimage(\"cameraman\")\n\n# Images can also be stored as hash. Note however that this\n# can only check for equality (no tolerance possible)\n@test_reference \"references/camera.sha256\" testimage(\"cameraman\")\n\n\n\n"
},

{
    "location": "#Public-Interface-1",
    "page": "Home",
    "title": "Public Interface",
    "category": "section",
    "text": "@withcolor\n@io2str\n@test_reference"
},

]}
