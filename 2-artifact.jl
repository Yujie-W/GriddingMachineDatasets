using PkgUtility: deploy_artifact!


GRIDDING_MACHINE_HOME = "/home/wyujie/GriddingMachine";
ARTIFACT_TOML         = "$(GRIDDING_MACHINE_HOME)/Artifacts.toml";
DATASET_FOLDER        = "$(GRIDDING_MACHINE_HOME)/reprocessed";
ARTIFACT_FOLDER       = "$(GRIDDING_MACHINE_HOME)/artifacts"
FTP_URLS              = ["ftp://fluo.gps.caltech.edu/XYZT_GRIDDING_MACHINE/artifacts"];


function deploy_griddingmachine_artifact!(artifact_name::String)
    _artifact_files = ["GRIDDINGMACHINE", "$(artifact_name).nc"];
    deploy_artifact!(ARTIFACT_TOML, artifact_name, DATASET_FOLDER, _artifact_files, ARTIFACT_FOLDER, FTP_URLS);

    return nothing
end
