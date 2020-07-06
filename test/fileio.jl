refdir = joinpath(refroot, "fileio")

@testset "query" begin
    check_types = [
        # text types
        ("textfile_with_no_extension", format"TXT"),
        ("textfile.txt", format"TXT"),
        ("textfile.unknown", format"TXT"),
        ("textfile.sha256", format"SHA256"),

        # image types
        ("imagefile.jpg", format"JPEG"),
        ("imagefile.jpeg", format"JPEG"),
        ("imagefile.png", format"PNG"),
        ("imagefile.tif", format"TIFF"),
        ("imagefile.tiff", format"TIFF"),

        # dataframe types
        ("dataframe_file.csv", format"CSV")
    ]
    for (file, fmt) in check_types
        @test ReferenceTests.query_extended(file) == File{fmt}(file)
        @test ReferenceTests.query_extended(abspath(file)) == File{fmt}(abspath(file))
    end
end

@testset "maybe_encode" begin
    @testset "string" begin
        str1 = "Hello world"
        str1_sha256 = "64ec88ca00b268e5ba1a35678a1b5316d212f4f366b2477232534a8aeca37f3c"
        str2 = "Hello\n world"
        str2_sha256 = "60b65ab310480818c4289227f2ec68f1714743db8571b4cb190e100c0085be3d" # bytes2hex(SHA.sha256(str2))
        str2_crlf = "Hello\n\r world"
        str3 = "Hello\nworld"
        str3_sha256 = "46e0ea795802f17d0b340983ca7d7068c94d7d9172ee4daea37a1ab1168649ec" # bytes2hex(SHA.sha256(str3))
        str3_arr1 = ["Hello", "world"]
        str3_arr2 = ["Hello" "world"]
        str4 = "Hello\n world1\nHello\n world2"
        str4_sha256 = "c7dc8b82c3a6fed4afa0c8790a0586b73df0e4f35524efe6810e5d78b6b6a611" # bytes2hex(SHA.sha256(str4))
        str4_arr = ["Hello\n\r world1", "Hello\n world2"]

        # string as plain text
        fmt = format"TXT"
        # convert should respect whitespaces
        @test str1 == ReferenceTests.maybe_encode(fmt, str1)
        @test str2 == ReferenceTests.maybe_encode(fmt, str2)
        # but ignore CRLF/LF differences
        @test str2 == ReferenceTests.maybe_encode(fmt, str2_crlf)
        # string arrays are treated as multi-line strings, even for UNKNOWN format
        @test str3 == ReferenceTests.maybe_encode(fmt, str3)
        @test str3 == ReferenceTests.maybe_encode(fmt, str3_arr1)
        @test str3 == ReferenceTests.maybe_encode(fmt, str3_arr2)
        # string arrays should ignore CRLF/LF differences, too
        @test str4 == ReferenceTests.maybe_encode(fmt, str4_arr)

        # string as SHA256 should also ignore CRLF/LF differences
        fmt = format"SHA256"
        @test str1_sha256 == ReferenceTests.maybe_encode(fmt, str1)
        @test str2_sha256 == ReferenceTests.maybe_encode(fmt, str2)
        # but ignore CRLF/LF differences
        @test str2_sha256 == ReferenceTests.maybe_encode(fmt, str2_crlf)
        # string arrays are treated as multi-line strings, even for UNKNOWN format
        @test str3_sha256 == ReferenceTests.maybe_encode(fmt, str3)
        @test str3_sha256 == ReferenceTests.maybe_encode(fmt, str3_arr1)
        @test str3_sha256 == ReferenceTests.maybe_encode(fmt, str3_arr2)
        # string arrays should ignore CRLF/LF differences, too
        @test str4_sha256 == ReferenceTests.maybe_encode(fmt, str4_arr)

        # unknown formats
        fmt = format"PNG"
        for str in (str1, str2, str2_crlf, str3, str3_arr1, str3_arr2)
            @test str === ReferenceTests.maybe_encode(fmt, str)
        end
    end

    @testset "numbers" begin
        for num in (0x01, 1, 1.0f0, 1.0)
            for fmt in (format"TXT", format"UNKNOWN")
                @test num === ReferenceTests.maybe_encode(fmt, num)
            end
            fmt = format"SHA256"
            @test ReferenceTests.maybe_encode(fmt, num) == ReferenceTests.maybe_encode(fmt, string(num))
        end


        for (fmt, a, ref) in [
            # if target is TXT, convert it to string
            (format"TXT", [1, 2], "[1, 2]"),
            (format"TXT", [1,2], "[1, 2]"),
            (format"TXT", [1;2], "[1, 2]"),
            (format"TXT", [1 2], "[1 2]"),
            (format"TXT", [1 2; 3 4], "[1 2; 3 4]"),
            # if target is Unknown, make no change
            (format"UNKNOWN", [1, 2], [1, 2]),
            (format"UNKNOWN", [1,2], [1, 2]),
            (format"UNKNOWN", [1;2], [1, 2]),
            (format"UNKNOWN", [1 2], [1 2]),
            (format"UNKNOWN", [1 2; 3 4], [1 2; 3 4]),
        ]
            @test ref == ReferenceTests.maybe_encode(fmt, a)
        end

        for a in [[1, 2], [1 2], [1 2; 3 4]]
            fmt = format"SHA256"
            @test ReferenceTests.maybe_encode(fmt, a) == ReferenceTests.maybe_encode(fmt, string(a))
        end
        
    end

    @testset "image" begin
        gray_1d = Gray{N0f8}.(0.0:0.1:0.9)
        rgb_1d = RGB.(gray_1d)
        gray_2d = Gray{N0f8}.(reshape(0.0:0.1:0.9, 2, 5))
        rgb_2d = RGB.(gray_2d)
        gray_3d = Gray{N0f8}.(reshape(0.0:0.02:0.95, 2, 4, 6))
        rgb_3d = RGB.(gray_3d)

        # any common image types
        for img in (gray_1d, gray_2d, gray_3d, rgb_1d, rgb_2d, rgb_3d)
            for fmt in (format"JPEG", format"PNG", format"TIFF", format"UNKNOWN")
                @test img === ReferenceTests.maybe_encode(fmt, img)
            end
        end

        # image as text file
        fmt = format"TXT"
        # TODO: support n-D image encoding
        # @test_reference joinpath(refdir, "gray_1d_as_txt.txt") ReferenceTests.maybe_encode(fmt, gray_1d)
        # @test_reference joinpath(refdir, "rgb_1d_as_txt.txt") ReferenceTests.maybe_encode(fmt, rgb_1d)
        @test_reference joinpath(refdir, "gray_2d_as_txt.txt") ReferenceTests.maybe_encode(fmt, gray_2d)
        @test_reference joinpath(refdir, "rgb_2d_as_txt.txt") ReferenceTests.maybe_encode(fmt, rgb_2d)
        # @test_reference joinpath(refdir, "gray_3d_as_txt.txt") ReferenceTests.maybe_encode(fmt, gray_3d)
        # @test_reference joinpath(refdir, "rgb_3d_as_txt.txt") ReferenceTests.maybe_encode(fmt, rgb_3d)

        # image as SHA256
        fmt = format"SHA256"
        for (file, img) in [
            ("gray_1d", gray_1d),
            ("gray_2d", gray_2d),
            ("gray_3d", gray_3d),
            ("rgb_1d", rgb_1d),
            ("rgb_2d", rgb_2d),
            ("rgb_3d", rgb_3d)
        ]
            reffile = joinpath(refdir, "$(file)_as_sha256.txt")
            @test_reference reffile ReferenceTests.maybe_encode(fmt, img)
        end
    end

    # dataframe
    @testset "dataframe" begin
        df = DataFrame(v1=[1,2,3], v2=["a","b","c"])

        @test string(df) == ReferenceTests.maybe_encode(format"TXT", df)
        for fmt in (format"CSV", format"UNKNOWN")
            @test df === ReferenceTests.maybe_encode(fmt, df)
        end

        fmt = format"SHA256"
        @test_reference joinpath(refdir, "dataframe_as_sha256.txt") ReferenceTests.maybe_encode(fmt, df)

    end
end

# TODO: savefile & loadfile
