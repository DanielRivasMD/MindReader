####################################################################################################

@testset verbose = true "Write" begin

  ####################################################################################################

  # testing
  @testset "Write Hidden Markov model" begin

    ####################################################################################################

    # empty dict
    toWriteDc = Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}("Test1" => ([1, 2, 3], [[1., 2., 3.]]))

    # write
    writeHMM("out/hmm_", toWriteDc)

    # testing
    @test isfile("out/hmm_Test1_states.csv") == true
    @test isfile("out/hmm_Test1_traceb.csv") == true

    ####################################################################################################

    # read
    readStates = readdlm("out/hmm_Test1_states.csv")
    readTraceb = readdlm("out/hmm_Test1_traceb.csv")

    # paired values
    testStates = Array{Any, 2}(undef, 4, 1)
    testStates[:, 1] .= ["Test1"; 1; 2; 3]

    testTraceb = Array{Any, 2}(undef, 4, 1)
    testTraceb[:, 1] .= ["S1"; 1.; 2.; 3.]

    # testing
    @test readStates == testStates
    @test readTraceb == testTraceb

    ####################################################################################################

  end

  ####################################################################################################

  # testing
  @testset "Write Performance" begin

    ####################################################################################################

    # empty dict
    toWriteDc = Dict{String, Array{Float64, 2}}("Test1" => [1. 10.], "Test2" => [2. 20.], "Test3" => [3. 30.])

    # transform
    performanceTb = writePerformance(toWriteDc)

    # testing
    @test performanceTb == [["Electrode", "Test2", "Test1", "Test3"] ["Sensitivity", 2., 1., 3.] ["Specificity", 20., 10., 30.]]

    ####################################################################################################

    # write
    writePerformance("out/performace.csv", toWriteDc)

    # testing
    @test isfile("out/performace.csv") == true

    ####################################################################################################

    # read
    readPerformance = readdlm("out/performace.csv", ',')

    # testing
    @test readPerformance == [["Electrode", "Test2", "Test1", "Test3"] ["Sensitivity", 2., 1., 3.] ["Specificity", 20., 10., 30.]]

    ####################################################################################################

    # read
    readStates = readdlm("out/hmm_Test1_states.csv")
    readTraceb = readdlm("out/hmm_Test1_traceb.csv")

    # paired values
    testStates = Array{Any, 2}(undef, 4, 1)
    testStates[:, 1] .= ["Test1"; 1; 2; 3]

    testTraceb = Array{Any, 2}(undef, 4, 1)
    testTraceb[:, 1] .= ["S1"; 1.; 2.; 3.]

    # testing
    @test readStates == testStates
    @test readTraceb == testTraceb

    ####################################################################################################

  end

  ####################################################################################################

end

####################################################################################################
