using JuliaUtilities.PkgUtility: deploy_artifact!


GRIDDING_MACHINE_HOME = "/home/wyujie/GriddingMachine";
ARTIFACT_TOML         = "$(GRIDDING_MACHINE_HOME)/Artifacts.toml";
DATASET_FOLDER        = "$(GRIDDING_MACHINE_HOME)/reprocessed";
ARTIFACT_FOLDER       = "$(GRIDDING_MACHINE_HOME)/artifacts"
FTP_URLS              = ["ftp://fluo.gps.caltech.edu/XYZT_GRIDDING_MACHINE/artifacts"];


include("2-reprocess.jl");


function deploy_griddingmachine_artifacts!(dict::Dict)
    _dict_grid = dict["GRIDDINGMACHINE"];

    # determine if there is any information for years
    _years = _dict_grid["YEARS"];
    _i_years = (_years == "" ? [1] : eachindex(_years));
    for _i_year in _i_years
        _tag = (_years == "" ? griddingmachine_tag(dict, 0) : griddingmachine_tag(dict, _years[_i_year]));
        _artifact_files = ["GRIDDINGMACHINE", "$(_tag).nc"];
        deploy_artifact!(ARTIFACT_TOML, _tag, DATASET_FOLDER, _artifact_files, ARTIFACT_FOLDER, FTP_URLS);
    end;

    return nothing
end
