
l = ["True Positives" "False Positives"; "False Negatives" "True Negatives"]

# vectors are equal, sn = 1.0 & sp = 1.0
i = rand(1:10, 3)
x = zeros(Int64, 10)
x[i] .= 1
y = copy(x)
@info sensspec(x .+ 1, y)

# vector has one event, sn = 1.0 & sp = 0.7
i = rand(1:10, 3)
x = zeros(Int64, 10)
x[i] .= 1
y = zeros(Int64, 10)
y[i[1]] = 1
@info sensspec(x .+ 1, y)

# vector has three events, but everything is called, sn = 1.0 & sp = 0.3
i = rand(1:10, 3)
x = ones(Int64, 10)
y = zeros(Int64, 10)
y[i] .= 1
@info sensspec(x .+ 1, y)

# example
z = [20 33; 10 37]
@info ss(z)

