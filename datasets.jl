#=
include("1-reprocess.jl");
include("2-artifact.jl" );


GRIDDING_MACHINE_HOME = "/home/wyujie/GriddingMachine";


function reprocess_ci_20x_1m_v3!()
    # define a unique artifact name
    _artifact_name = "CI_20X_1M_V3";

    # files to combine
    MONTHLY_LABEL = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"];
    MONTHLY_FILES = "$(GRIDDING_MACHINE_HOME)/original/CI_20X_1M_V3_" .* MONTHLY_LABEL .* ".tif";

    # prepare the data
    _mask(x) = (x >= 100);
    _var_attr = Dict{String,String}(
                "longname" => "Clumping index",
                "unit"     => "-",
                "about"    => "This dataset is generated using MODIS BRDF data in 2001-2017",
                "authors"  => "Wei S. et al.",
                "year"     => "2019",
                "title"    => "Global 500 m clumping index product derived from MODIS BRDF data (2001–2017)",
                "journal"  => "Remote Sensing of Environment",
                "doi"      => "10.1016/j.rse.2019.111296",
                "change1"  => "The original files used GeoTIFF, and we converted it to NetCDF",
                "change2"  => "The original lat was from north to south, and we reorgainized it from south to north",
                "change3"  => "There was no uncertainty included, and we added an empty matrix filled with NaN");
    prepare_data!(_artifact_name, MONTHLY_FILES, [1 for _i in 1:12], _var_attr; mask_function = _mask, flipping = true);

    # deploy the artifact
    deploy_griddingmachine_artifact!(_artifact_name);

    # warn the user to
    @info "The artifact has been successfully deployed, you need to synchronize the changes in Artifacts.toml to GriddingMachine.";

    return nothing
end


function reprocess_ci_2x_1m_v3!()
    # define a unique artifact name
    _artifact_name = "CI_2X_1M_V3";

    # files to combine
    MONTHLY_LABEL = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"];
    MONTHLY_FILES = "$(GRIDDING_MACHINE_HOME)/original/CI_20X_1M_V3_" .* MONTHLY_LABEL .* ".tif";

    # prepare the data
    _mask(x) = (x >= 100);
    _var_attr = Dict{String,String}(
                "longname" => "Clumping index",
                "unit"     => "-",
                "about"    => "This dataset is generated using MODIS BRDF data in 2001-2017",
                "authors"  => "Wei S. et al.",
                "year"     => "2019",
                "title"    => "Global 500 m clumping index product derived from MODIS BRDF data (2001–2017)",
                "journal"  => "Remote Sensing of Environment",
                "doi"      => "10.1016/j.rse.2019.111296",
                "change1"  => "The original files used GeoTIFF, and we converted it to NetCDF",
                "change2"  => "The original lat was from north to south, and we reorgainized it from south to north",
                "change3"  => "There was no uncertainty included, and we added an empty matrix filled with NaN",
                "change4"  => "The data is regridded to 0.5 degree resolution");
    prepare_data!(_artifact_name, MONTHLY_FILES, [1 for _i in 1:12], _var_attr; division = 2, mask_function = _mask, flipping = true);

    # deploy the artifact
    deploy_griddingmachine_artifact!(_artifact_name);

    # warn the user to
    @info "The artifact has been successfully deployed, you need to synchronize the changes in Artifacts.toml to GriddingMachine.";

    return nothing
end
=#
