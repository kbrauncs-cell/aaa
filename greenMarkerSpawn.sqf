// Marker Spawn Script for Arma 3 Debug Console
// TAB = green marker (permanent)
// TAB + TAB within 1 second = blue marker (reverts to green at midnight)
// TAB near green marker (3m) = turns it blue, reverts to green at midnight
// All blue markers are processed at 00:00 game time (FPS friendly single loop)

// Remove existing handler if re-running script
if (!isNil "TAB_MarkerHandler") then {
    (findDisplay 46) displayRemoveEventHandler ["KeyDown", TAB_MarkerHandler];
};

// Stop existing midnight loop
if (!isNil "MIDNIGHT_LOOP_RUNNING") then {
    MIDNIGHT_LOOP_RUNNING = false;
};

// Initialize variables
if (isNil "MARKER_COUNT") then {
    MARKER_COUNT = 0;
};
if (isNil "GREEN_MARKERS") then {
    GREEN_MARKERS = [];
};
BLUE_MARKERS = [];
LAST_TAB_PRESS = -10;

// Single midnight check loop (FPS friendly)
MIDNIGHT_LOOP_RUNNING = true;
[] spawn {
    private _lastHour = daytime;

    while {MIDNIGHT_LOOP_RUNNING} do {
        private _currentHour = daytime;

        // Detect midnight crossing (hour went from 23.x to 0.x)
        if (_lastHour > 23 && _currentHour < 1) then {
            // Revert all blue markers to green
            {
                if (getMarkerType _x != "") then {
                    _x setMarkerColor "ColorGreen";
                    GREEN_MARKERS pushBack _x;
                };
            } forEach BLUE_MARKERS;
            BLUE_MARKERS = [];
        };

        _lastHour = _currentHour;
        sleep 1;
    };
};

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
            GREEN_MARKERS = GREEN_MARKERS - [_nearbyMarker];
            BLUE_MARKERS pushBack _nearbyMarker;
            LAST_TAB_PRESS = -10;
        } else {
            // No nearby marker - create new one
            private _markerName = format ["marker_%1", MARKER_COUNT];
            MARKER_COUNT = MARKER_COUNT + 1;

            private _marker = createMarker [_markerName, _playerPos];
            _marker setMarkerType "hd_dot";

            if (_timeSinceLastPress <= 1) then {
                // Double tap - blue marker, reverts to green at midnight
                _marker setMarkerColor "ColorBlue";
                BLUE_MARKERS pushBack _markerName;
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
