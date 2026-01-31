// Marker Spawn Script for Arma 3 Debug Console
// TAB = green marker (permanent)
// TAB + TAB within 1 second = blue marker (deletes after 10 seconds)
// TAB near green marker (3m) = turns it blue, reverts to green after 10 seconds

// Remove existing handler if re-running script
if (!isNil "TAB_MarkerHandler") then {
    (findDisplay 46) displayRemoveEventHandler ["KeyDown", TAB_MarkerHandler];
};

// Initialize variables
if (isNil "MARKER_COUNT") then {
    MARKER_COUNT = 0;
};
if (isNil "GREEN_MARKERS") then {
    GREEN_MARKERS = [];
};
LAST_TAB_PRESS = -10;

// Add key event handler
TAB_MarkerHandler = (findDisplay 46) displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];

    // DIK code 15 = TAB key
    if (_key == 15) then {
        private _currentTime = diag_tickTime;
        private _timeSinceLastPress = _currentTime - LAST_TAB_PRESS;
        private _playerPos = getPosATL player;

        // Check for nearby green marker (within 3 meters)
        private _nearbyMarker = "";
        {
            private _markerPos = getMarkerPos _x;
            if (_playerPos distance2D _markerPos <= 3) exitWith {
                _nearbyMarker = _x;
            };
        } forEach GREEN_MARKERS;

        if (_nearbyMarker != "") then {
            // Found nearby green marker - turn it blue temporarily
            _nearbyMarker setMarkerColor "ColorBlue";

            // Remove from green list temporarily
            GREEN_MARKERS = GREEN_MARKERS - [_nearbyMarker];

            // Revert to green after 10 seconds
            [_nearbyMarker] spawn {
                params ["_name"];
                sleep 10;
                if (getMarkerType _name != "") then {
                    _name setMarkerColor "ColorGreen";
                    GREEN_MARKERS pushBack _name;
                };
            };

            // Reset timer
            LAST_TAB_PRESS = -10;
        } else {
            // No nearby marker - create new one
            private _markerName = format ["marker_%1", MARKER_COUNT];
            MARKER_COUNT = MARKER_COUNT + 1;

            private _marker = createMarker [_markerName, _playerPos];
            _marker setMarkerType "hd_dot";

            if (_timeSinceLastPress <= 1) then {
                // Double tap - blue marker that auto-deletes
                _marker setMarkerColor "ColorBlue";

                [_markerName] spawn {
                    params ["_name"];
                    sleep 10;
                    deleteMarker _name;
                };

                LAST_TAB_PRESS = -10;
            } else {
                // Single tap - green permanent marker
                _marker setMarkerColor "ColorGreen";
                GREEN_MARKERS pushBack _markerName;
                LAST_TAB_PRESS = _currentTime;
            };
        };

        true
    } else {
        false
    };
}];
