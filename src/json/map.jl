function map_info_dict()
    @info "These inputs are meant to determine what changes are required to pre-process the dataset...";
end


"""

    map_setup_dict()

Create the Dict that stores information about the map settings

"""
function map_setup_dict()
    @info "These inputs are meant to determine what changes are required to pre-process the dataset...";

    # ask the format of input dataset
    print("    What is the format of the input dataset? (NetCDF or GeoTIFF) > ");
    _format = uppercase(readline());
    @assert _format in ["G", "GEOTIFF", "N", "NETCDF", "TIFF"] "The dataset must be NetCDF or GeoTIFF!";

    # ask the projection of the map
    print("    What is the projection of the dataset? (Cylindrical or Sinusoidal) > ");
    _projection = uppercase(readline());
    @assert _projection in ["C", "CYLINDRICAL", "S", "SINUSOIDAL"] "The dataset projection must be within Cylindrical and Sinusoidal!";

    # ask for value of representation
    print("    What does the value represent? (Center or Edge) > ");
    _represent = uppercase(readline());
    @assert _represent in ["C", "CENTER", "E", "EDGE"] "You must choose one from Center or Edge!";

    # ask and parse map coverage
    print("    What is the coverage of the dataset? (Global or not; if not global, type in the conner values in the order or min lat, max lat, min lon, max lon) > ");
    _coverage = uppercase(readline());
    if occursin(",", _coverage)
        _conners = [parse(Float64, _str) for _str in split(_coverage, ",")];
        @assert -90 <= _conners[1] < _conners[2] <= 90 "Latitude must be within -90 to 90";
        @assert ((-180 <= _conners[3] < _conners[4] <= 180) || 0 <= _conners[3] < _conners[4] <= 360) "Longitude must be within -180 to 180 or 0 to 360";
    else
        @assert _coverage in ["G", "GLOBAL"] "You need to guarantee the coverage input is correct";
    end;
    _coverages = (_coverage in ["G", "GLOBAL"] ? "Global" : [parse(Float64, _str) for _str in split(_coverage, ",")]);

    # ask for re-oritentation of the map
    print("    Do you need to re-orient the map on the latitudinal direction? (Yes or No) > ");
    _reorient_lat = uppercase(readline());
    @assert _reorient_lat in ["N", "NO", "Y", "YES"];
    _flip_lat = _reorient_lat in ["Y", "YES"];
    print("    Do you need to re-orient the map on the longitudinal direction? (Yes or No) > ");
    _reorient_lon = uppercase(readline());
    @assert _reorient_lon in ["N", "NO", "Y", "YES"];
    _flip_lon = _reorient_lon in ["Y", "YES"];

    # return the Dict for raw dataset settings
    return Dict{String,Any}(
        "FORMAT"           => _format,
        "PROJECTION"       => _projection,
        "VALUE_AT"         => _represent,
        "COVERAGE"         => _coverages,
        "LAT_LON_FLIPPING" => [_flip_lat, _flip_lon],
    )
end
