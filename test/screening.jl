################################################################################

@testset verbose = true "Screening" begin

  ################################################################################

  # testing
  @testset "Sensitivity & Specificity" begin
    @test sensitivitySpecifiity([10 40; 5 45]) == (sensitivity = 0.6666666666666666, specificity = 0.5294117647058824)
    @test sensitivitySpecifiity([20 33; 10 37]) == (sensitivity = 0.6666666666666666, specificity = 0.5285714285714286)
  end

  ################################################################################

  # testing
  @testset "Predicitive Values" begin
    @test predictiveValue([10 40; 5 45]) == (positive = 0.2, negative = 0.9)
    @test predictiveValue([20 33; 10 37]) == (positive = 0.37735849056603776, negative = 0.7872340425531915)
  end

  ################################################################################

end

################################################################################
