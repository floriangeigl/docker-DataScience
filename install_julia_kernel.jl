Pkg.add("IJulia")
using IJulia
IJulia.installkernel("Julia nodeps", "--depwarn=no")
