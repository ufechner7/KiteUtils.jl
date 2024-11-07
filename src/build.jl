# code to create the file sysstate.jl (and later a lot more)
using YAML, OrderedCollections

include("yaml_utils.jl")

HEADER = """
\"\"\"
    SysState{P}

Basic system state. One of these is saved per time step. P is the number
of tether particles.

\$(TYPEDFIELDS)
\"\"\"
Base.@kwdef mutable struct SysState{P}"""
FOOTER = "end"
inputfile = joinpath("data", "sysstate.yaml")
outputfile = joinpath("src", "sysstate.jl")

# read the file sysstate.yaml
sysstate = YAML.load_file(inputfile, dicttype=OrderedDict{String,Any})["sysstate"]
lines = readfile(inputfile)
open(outputfile,"w") do io
    println(io, HEADER)
    for key in keys(sysstate)
        comment = get_comment(lines, key)
        println(io, "    " * comment)
        println(io, "    " * key * "::" * sysstate[key])
    end
    println(io, FOOTER)
end