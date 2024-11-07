# code to create the file sysstate.jl (and later a lot more)
using YAML, OrderedCollections

include("yaml_utils.jl")

HEADER = "Base.@kwdef mutable struct SysState{P}"
FOOTER = "end"
inputfile = joinpath("data", "sysstate.yaml")

# read the file sysstate.yaml
sysstate = YAML.load_file(inputfile, dicttype=OrderedDict{String,Any})["sysstate"]
lines = readfile(inputfile)
println(HEADER)
for key in keys(sysstate)
    comment = get_comment(lines, key)
    println("    " * comment)
    println("    " * key * "::" * sysstate[key])
end
println(FOOTER)