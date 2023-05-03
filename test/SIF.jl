using JSON

using GriddingMachineDatasets: deploy_griddingmachine_artifacts!, griddingmachine_json!, reprocess_data!

for NX in ["1X", "2X", "4X", "5X", "12X"]
    for MT in ["1M", "8D"]
        tropomi_json = "$(@__DIR__)/../json/TROPOMI_740_$(NX)_$(MT)_V1.json";

        if !isfile(tropomi_json)
            griddingmachine_json!(tropomi_json);
        end;

        json_dict = JSON.parse(open(tropomi_json));
        name_function = eval(Meta.parse(json_dict["INPUT_MAP_SETS"]["FILE_NAME_FUNCTION"]));
        data_scaling_functions = [_dict["SCALING_FUNCTION"] == "" ? nothing :  eval(Meta.parse(_dict["SCALING_FUNCTION"])) for _dict in json_dict["INPUT_VAR_SETS"]];
        std_scaling_functions = [_dict["SCALING_FUNCTION"] == "" ? nothing : eval(Meta.parse(_dict["SCALING_FUNCTION"])) for _dict in json_dict["INPUT_STD_SETS"]];

        reprocess_data!(json_dict; file_name_function = name_function, data_scaling_functions = data_scaling_functions, std_scaling_functions = std_scaling_functions);

        deploy_griddingmachine_artifacts!(json_dict);
    end;
end;
