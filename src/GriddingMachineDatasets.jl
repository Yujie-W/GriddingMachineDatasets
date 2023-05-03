module GriddingMachineDatasets

using JSON
using Revise

using JuliaUtilities.NetcdfIO: append_nc!, read_nc, save_nc!
using JuliaUtilities.PkgUtility: pretty_display!


include("io/input.jl");

include("json/attribute.jl");
include("json/data.jl");
include("json/griddingmachine.jl");
include("json/map.jl");
include("json/save.jl");

include("reprocess/read.jl");
include("reprocess/reprocess.jl");


end # module
