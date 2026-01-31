// Arma 3 Debug Console Script - Invincible with Body Part Punishment System
// Player cannot die but taking damage has consequences based on hit location
// Execute this in the debug console (local exec)

// Remove any existing handler first
if (!isNil "PUNISH_EH_ID") then {
    player removeEventHandler ["HandleDamage", PUNISH_EH_ID];
};

// Track player's current damage for visual feedback (but never die)
player setVariable ["PUNISH_totalDamage", 0];

// Helper function to remove random item from array of equipped items
PUNISH_removeRandomFrom = {
    params ["_items"];
    private _equipped = _items select {_x != ""};
    if (count _equipped > 0) then {
        private _toRemove = selectRandom _equipped;
        _toRemove;
    } else {
        "";
    };
};

// Main damage handler
PUNISH_EH_ID = player addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

    // Only process if actual damage is being dealt
    if (_damage <= 0) exitWith { 0 };

    // Determine body region from selection/hitPoint
    private _region = "unknown";
    private _hitLower = toLower _hitPoint;
    private _selLower = toLower _selection;

    // Head detection
    if (_hitLower find "head" >= 0 || _selLower find "head" >= 0 || _hitLower find "face" >= 0) then {
        _region = "head";
    };

    // Chest/Body detection
    if (_hitLower find "body" >= 0 || _hitLower find "chest" >= 0 || _hitLower find "spine" >= 0 ||
        _selLower find "body" >= 0 || _selLower find "chest" >= 0 || _selLower find "spine" >= 0 ||
        _hitLower find "pelvis" >= 0) then {
        _region = "chest";
    };

    // Arms detection
    if (_hitLower find "arm" >= 0 || _hitLower find "hand" >= 0 ||
        _selLower find "arm" >= 0 || _selLower find "hand" >= 0) then {
        _region = "arms";
    };

    // Legs detection
    if (_hitLower find "leg" >= 0 || _selLower find "leg" >= 0) then {
        _region = "legs";
    };

    // If still unknown but damage dealt, default to chest
    if (_region == "unknown" && _damage > 0.1) then {
        _region = "chest";
    };

    // Process punishment based on region
    if (_region != "unknown") then {

        // === ANY HIT: Remove one support item (map, compass, watch, radio, GPS) ===
        private _assignedItems = assignedItems player;
        private _availableSupport = [];

        if ("ItemMap" in _assignedItems) then { _availableSupport pushBack "ItemMap"; };
        if ("ItemCompass" in _assignedItems) then { _availableSupport pushBack "ItemCompass"; };
        if ("ItemWatch" in _assignedItems) then { _availableSupport pushBack "ItemWatch"; };
        if ("ItemRadio" in _assignedItems) then { _availableSupport pushBack "ItemRadio"; };
        if ("ItemGPS" in _assignedItems) then { _availableSupport pushBack "ItemGPS"; };

        if (count _availableSupport > 0) then {
            private _toRemove = selectRandom _availableSupport;
            player unassignItem _toRemove;
            player removeItem _toRemove;
            systemChat format ["[PUNISHMENT] Lost support item: %1", _toRemove];
        };

        // === HEAD HIT: Remove head gear item ===
        if (_region == "head") then {
            private _headItems = [];
            if (headgear player != "") then { _headItems pushBack "headgear"; };
            if (goggles player != "") then { _headItems pushBack "goggles"; };
            // Check for NVG
            if ((hmd player) != "") then { _headItems pushBack "nvg"; };

            if (count _headItems > 0) then {
                private _removeType = selectRandom _headItems;
                switch (_removeType) do {
                    case "headgear": {
                        private _item = headgear player;
                        removeHeadgear player;
                        systemChat format ["[PUNISHMENT] Head hit! Lost headgear: %1", _item];
                    };
                    case "goggles": {
                        private _item = goggles player;
                        removeGoggles player;
                        systemChat format ["[PUNISHMENT] Head hit! Lost goggles: %1", _item];
                    };
                    case "nvg": {
                        private _item = hmd player;
                        player unlinkItem _item;
                        systemChat format ["[PUNISHMENT] Head hit! Lost NVG: %1", _item];
                    };
                };
            } else {
                systemChat "[PUNISHMENT] Head hit! No head items left to lose.";
            };
        };

        // === CHEST HIT: Remove vest or backpack ===
        if (_region == "chest") then {
            private _chestItems = [];
            if (vest player != "") then { _chestItems pushBack "vest"; };
            if (backpack player != "") then { _chestItems pushBack "backpack"; };

            if (count _chestItems > 0) then {
                private _removeType = selectRandom _chestItems;
                switch (_removeType) do {
                    case "vest": {
                        private _item = vest player;
                        removeVest player;
                        systemChat format ["[PUNISHMENT] Chest hit! Lost vest: %1", _item];
                    };
                    case "backpack": {
                        private _item = backpack player;
                        removeBackpack player;
                        systemChat format ["[PUNISHMENT] Chest hit! Lost backpack: %1", _item];
                    };
                };
            } else {
                systemChat "[PUNISHMENT] Chest hit! No vest/backpack left to lose.";
            };
        };

        // === ARMS HIT: Remove one weapon ===
        if (_region == "arms") then {
            private _weapons = [];
            if (primaryWeapon player != "") then { _weapons pushBack "primary"; };
            if (secondaryWeapon player != "") then { _weapons pushBack "secondary"; };
            if (handgunWeapon player != "") then { _weapons pushBack "handgun"; };

            if (count _weapons > 0) then {
                private _removeType = selectRandom _weapons;
                switch (_removeType) do {
                    case "primary": {
                        private _item = primaryWeapon player;
                        player removeWeapon _item;
                        systemChat format ["[PUNISHMENT] Arm hit! Lost primary weapon: %1", _item];
                    };
                    case "secondary": {
                        private _item = secondaryWeapon player;
                        player removeWeapon _item;
                        systemChat format ["[PUNISHMENT] Arm hit! Lost launcher: %1", _item];
                    };
                    case "handgun": {
                        private _item = handgunWeapon player;
                        player removeWeapon _item;
                        systemChat format ["[PUNISHMENT] Arm hit! Lost handgun: %1", _item];
                    };
                };
            } else {
                systemChat "[PUNISHMENT] Arm hit! No weapons left to lose.";
            };
        };

        // === LEGS HIT: Drain ACE stamina ===
        if (_region == "legs") then {
            // ACE3 stamina drain
            if (!isNil "ace_advanced_fatigue_anReserve") then {
                player setVariable ["ace_advanced_fatigue_anReserve", 0];
                player setVariable ["ace_advanced_fatigue_aeReserve", 0];
            };
            // Fallback for basic ACE or vanilla - force fatigue
            player setFatigue 1;

            systemChat "[PUNISHMENT] Leg hit! Stamina depleted!";
        };
    };

    // Allow damage for visual/sound feedback but prevent death
    // Return minimal damage to show hit effects but keep player alive
    private _currentDamage = damage _unit;

    // Cap damage at 0.9 to prevent death
    if (_currentDamage + _damage >= 1) then {
        0.05  // Return tiny damage to show hit feedback
    } else {
        _damage * 0.3  // Reduce incoming damage significantly
    };
}];

// Safety net: prevent death via another handler
if (!isNil "PUNISH_KILLED_EH") then {
    player removeEventHandler ["Killed", PUNISH_KILLED_EH];
};

PUNISH_KILLED_EH = player addEventHandler ["Killed", {
    params ["_unit"];
    _unit setDamage 0;
    _unit setVariable ["PUNISH_totalDamage", 0];
}];

// Continuous safety check to prevent death
if (!isNil "PUNISH_LOOP") then {
    terminate PUNISH_LOOP;
};

PUNISH_LOOP = [] spawn {
    while {alive player} do {
        if (damage player > 0.85) then {
            player setDamage 0.5;
        };
        sleep 0.1;
    };
};

// Confirmation message
systemChat "========================================";
systemChat "[SYSTEM] Invincibility + Punishment System ACTIVE";
systemChat "- Head hit: Lose headgear/goggles/NVG";
systemChat "- Chest hit: Lose vest or backpack";
systemChat "- Arm hit: Lose a weapon";
systemChat "- Leg hit: Stamina drained to 0";
systemChat "- Any hit: Lose a support item";
systemChat "========================================";
hint "Punishment System Active!\n\nYou cannot die, but damage has consequences!";
