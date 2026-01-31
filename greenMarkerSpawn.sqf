// Green Marker Spawn Script for Arma 3 Debug Console
// Press TAB to spawn a green dot marker at your position

// Remove existing handler if re-running script
if (!isNil "TAB_MarkerHandler") then {
    (findDisplay 46) displayRemoveEventHandler ["KeyDown", TAB_MarkerHandler];
};

// Counter for unique marker names
if (isNil "GREEN_MARKER_COUNT") then {
    GREEN_MARKER_COUNT = 0;
};

// Add key event handler
TAB_MarkerHandler = (findDisplay 46) displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];

    // DIK code 15 = TAB key
    if (_key == 15) then {
        // Create unique marker name
        private _markerName = format ["green_marker_%1", GREEN_MARKER_COUNT];
        GREEN_MARKER_COUNT = GREEN_MARKER_COUNT + 1;

        // Create marker at player position
        private _marker = createMarker [_markerName, getPosATL player];
        _marker setMarkerType "hd_dot";
        _marker setMarkerColor "ColorGreen";

        // Optional: hint to confirm marker placed
        hint format ["Marker placed at %1", getPosATL player];

        true // Return true to block default TAB behavior
    } else {
        false
    };
}];

hint "Green Marker Script Active - Press TAB to place markers";
