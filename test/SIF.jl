using JSON

using GriddingMachineDatasets: griddingmachine_json!, reprocess_data!

tropomi_json = "$(@__DIR__)/json/TROPOMI_740_1X_1M_V1.json";

if !isfile(tropomi_json)
    griddingmachine_json!(tropomi_json);
end;

json_dict = JSON.parse(open(tropomi_json));
name_function = eval(Meta.parse(json_dict["INPUT_MAP_SETS"]["FILE_NAME_FUNCTION"]));
data_scaling_functions = [_dict["SCALING_FUNCTION"] == "" ? nothing :  eval(Meta.parse(_dict["SCALING_FUNCTION"])) for _dict in json_dict["INPUT_VAR_SETS"]];
std_scaling_functions = [_dict["SCALING_FUNCTION"] == "" ? nothing : eval(Meta.parse(_dict["SCALING_FUNCTION"])) for _dict in json_dict["INPUT_STD_SETS"]];

reprocess_data!(json_dict; file_name_function = name_function, data_scaling_functions = data_scaling_functions, std_scaling_functions = std_scaling_functions);
