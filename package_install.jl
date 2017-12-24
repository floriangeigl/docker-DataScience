metadata_packages = [
    "BinDeps",
    "Cairo",
    "Calculus",
    "Clustering",
    "DataArrays",
    "DataFrames",
    "DataFramesMeta",
    "Dates",
    "DecisionTree",
    "Distributions",
    "Distances",
    "Gadfly",
    "GLM",
    "HDF5",
    "HypothesisTests",
    "JSON",
    "KernelDensity",
    "Lora",
    "MLBase",
    "MultivariateStats",
    "NMF",
    "Optim",
    "PDMats",
    "RDatasets",
    "SQLite",
    "StatsBase",
    "TextAnalysis",
    "TimeSeries",
    "ZipFile", 
    "IJulia",
    "Plots",
    "PyPlot"]


Pkg.init()
Pkg.update()

for package in metadata_packages
    println("install $package")
    try Pkg.add(package) end
end

# need to build XGBoost version for it to work
Pkg.clone("https://github.com/antinucleon/XGBoost.jl.git")
try Pkg.build("XGBoost") end

Pkg.clone("https://github.com/benhamner/MachineLearning.jl")
# Pkg.clone("https://github.com/johnmyleswhite/NearestNeighbors.jl")
try Pkg.pin("MachineLearning") end

Pkg.resolve()

println("Installed all julia packages.")
