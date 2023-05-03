module GriddingMachineDatasets

using JSON
using Revise

using JuliaUtilities.NetcdfIO: append_nc!, read_nc, save_nc!
using JuliaUtilities.PkgUtility: deploy_artifact!, pretty_display!


GRIDDING_MACHINE_HOME = "/home/wyujie/GriddingMachine";
ARTIFACT_TOML         = "$(@__DIR__)/../Artifacts.toml";
DATASET_FOLDER        = "$(GRIDDING_MACHINE_HOME)/reprocessed";
ARTIFACT_FOLDER       = "$(GRIDDING_MACHINE_HOME)/artifacts"
FTP_URLS              = ["ftp://fluo.gps.caltech.edu/XYZT_GRIDDING_MACHINE/artifacts"];


include("io/input.jl");

include("json/attribute.jl");
include("json/data.jl");
include("json/griddingmachine.jl");
include("json/map.jl");
include("json/save.jl");

include("reprocess/read.jl");
include("reprocess/reprocess.jl");

include("deploy/deploy.jl");


end # module
