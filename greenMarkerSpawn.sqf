// Marker Spawn Script for Arma 3 Debug Console
// TAB = green marker (permanent)
// TAB + TAB within 1 second = blue marker (deletes after 10 seconds)

// Remove existing handler if re-running script
if (!isNil "TAB_MarkerHandler") then {
    (findDisplay 46) displayRemoveEventHandler ["KeyDown", TAB_MarkerHandler];
};

// Initialize variables
if (isNil "MARKER_COUNT") then {
    MARKER_COUNT = 0;
};
LAST_TAB_PRESS = -10;

// Add key event handler
TAB_MarkerHandler = (findDisplay 46) displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];

    // DIK code 15 = TAB key
    if (_key == 15) then {
        private _currentTime = diag_tickTime;
        private _timeSinceLastPress = _currentTime - LAST_TAB_PRESS;

        // Create unique marker name
        private _markerName = format ["marker_%1", MARKER_COUNT];
        MARKER_COUNT = MARKER_COUNT + 1;

        // Create marker at player position
        private _marker = createMarker [_markerName, getPosATL player];
        _marker setMarkerType "hd_dot";

        if (_timeSinceLastPress <= 1) then {
            // Double tap - blue marker that auto-deletes
            _marker setMarkerColor "ColorBlue";

            // Delete marker after 10 seconds
            [_markerName] spawn {
                params ["_name"];
                sleep 10;
                deleteMarker _name;
            };

            // Reset timer to prevent triple-tap being another blue
            LAST_TAB_PRESS = -10;
        } else {
            // Single tap - green permanent marker
            _marker setMarkerColor "ColorGreen";
            LAST_TAB_PRESS = _currentTime;
        };

        true
    } else {
        false
    };
}];
