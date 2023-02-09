#
# This file is meant to config the JSON file to aid further steps
#
using JSON

function json!()
    #
    #
    # GriddingMachine tag generator
    #
    #
    @info "These inputs are meant to generate the GriddingMachine TAG...";

    # ask for level 1 label
    print("    Please indicate the level 1 label for the dataset (e.g., GPP as in GPP_VPM_2X_1M_V1) > ");
    _label = uppercase(readline());
    @assert _label != "" "Label must not be empty!";

    # ask and parse extra labels
    print("    Please indicate the level 2 label for the dataset (e.g., VPM as in GPP_VPM_2X_1M_V1, leave empty is there is not any) > ");
    _label_extra = uppercase(readline());
    _label_extra = (_label_extra == "" ? nothing : _label_extra);

    # ask and parse spatial resolution
    print("    Please indicate the spatial resolution represented with an integer (N for 1/N °) > ");
    _spatial_resolution_nx = parse(Int, readline());
    @assert _spatial_resolution_nx > 0 "Spatial resolution must not be smaller than 1";

    # ask for temporal resolution
    print("    Please indicate the temporal resolution (e.g., 8D, 1M, and 1Y) > ");
    _temporal_resolution = uppercase(readline());
    @assert _temporal_resolution != "" "Temporal resolution cannot be empty";

    # ask and parse year range
    print("    Please indicate the range of years (e.g., 2001:2022, and 2001,2005, empty for non-specific) > ");
    _years_input = readline();
    _years = "";
    if _years_input == ""
        _years = nothing;
    elseif occursin(":", _years_input)
        _years_str = split(_years_input, ":");
        if length(_years_str) == 2
            _min = parse(Int, _years_str[1]);
            _max = parse(Int, _years_str[2]);
            _years = _min:_max;
        else length(_years_str) > 2
            _min = parse(Int, _years_str[1]);
            _stp = parse(Int, _years_str[2]);
            _max = parse(Int, _years_str[3]);
            _years = _min:_stp:_max;
        end;
    elseif occursin(",", _years_input)
        _years_str = split(_years_input, ",");
        _years = [parse(Int, _str) for _str in _years_str];
    else
        _years = [parse(Int, _years_input)];
    end;

    # ask for version info
    print("    Please indicate the version number of the dataset (1 for V1) > ");
    _version = parse(Int, readline());
    @assert _version > 0 "version number must not be smaller than 1";

    # display information about the tag
    _labeling = isnothing(_label_extra) ? _label : _label * "_" * _label_extra;
    if isnothing(_years)
        @info "The GriddingMachine tag will be $(_labeling)_$(_spatial_resolution_nx)X_$(_temporal_resolution)_V$(_version)";
    else
        @info "The GriddingMachine tag will be $(_labeling)_$(_spatial_resolution_nx)X_$(_temporal_resolution)_YEAR_V$(_version)";
    end;

    #
    #
    # Netcdf reference generator
    #
    #
    @info "These inputs are meant to generate the reference information witin the Netcdf dataset...";

    # ask for the long name, unit, and about of the variable
    print("    Please input the long name of the variable to save > ");
    _longname = readline();
    print("    Please input the unit of the variable to save > ");
    _unit = readline();
    print("    Please input some more details of the variable to save > ");
    _about = readline();
    print("    Please input the author information (e.g., Name S. et al.) > ");
    _authors = readline();
    print("    Please input the year of the publication > ");
    _year_pub = readline();
    print("    Please input the title of the publication > ");
    _title = readline();
    print("    Please input the journal of the publication > ");
    _journal = readline();
    print("    Please input the DOI of the publication > ");
    _doi = readline();

    #
    #
    # Log of changes to make
    #
    #
    @info "These inputs are meant to determine what changes are required to pre-process the dataset...";

    # ask the format of input dataset

    #=
                "change1"  => "The original files used GeoTIFF, and we converted it to NetCDF",
                "change2"  => "The original lat was from north to south, and we reorgainized it from south to north",
                "change3"  => "There was no uncertainty included, and we added an empty matrix filled with NaN");
    =#

    # display the dict to save
    _json_dict = Dict{String,Any}(
        "GriddingMachine" => Dict{String,Any}(
                    "LABEL"               => _label,
                    "EXTRA LABEL"         => _label_extra,
                    "SPATIAL RESOLUTION"  => _spatial_resolution_nx,
                    "TEMPORAL RESOLUTION" => _temporal_resolution,
                    "YEARS"               => _years,
                    "VERSION"             => _version,),
        "Netcdf Attributes" => Dict{String,String}(
                    "LONG NAME" => _longname,
                    "UNIT"      => _unit,
                    "ABOUT"     => _about,
                    "AUTHORS"   => _authors,
                    "YEAR"      => _year_pub,
                    "TITLE"     => _title,
                    "JOURNAL"   => _journal,
                    "DOI"       => _doi,
        )
    );
    @info "You inputs are" _json_dict;

    return nothing
end
