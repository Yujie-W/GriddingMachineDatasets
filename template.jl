using Dates


include("2-reprocess.jl");
include("3-artifact.jl" );


local_json_dict = JSON.parse(open("json/VCF_2X_1Y_V1.json"));
local_name_function = eval(Meta.parse(local_json_dict["INPUT_DATASET_SETTINGS"]["FILE_NAME_FUNCTION"]));
local_data_scaling_functions = [_dict["SCALING_FUNCTION"] == "" ? nothing : eval(Meta.parse(_dict["SCALING_FUNCTION"])) for _dict in local_json_dict["VARIABLE_SETTINGS"]];
local_std_scaling_functions = [_dict["SCALING_FUNCTION"] == "" ? nothing : eval(Meta.parse(_dict["SCALING_FUNCTION"])) for _dict in local_json_dict["VARIABLE_STD_SETTINGS"]];

reprocess_data!(local_json_dict; file_name_function = local_name_function, data_scaling_functions = local_data_scaling_functions, std_scaling_functions = local_std_scaling_functions);
deploy_griddingmachine_artifacts!(local_json_dict);
