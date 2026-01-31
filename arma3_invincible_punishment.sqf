// Arma 3 Debug Console Script - Invincible with Body Part Punishment
// Compatible with ACE3 Medical
// Execute in debug console (Local Exec)

// Cleanup old handlers
if !(isNil "PUNISH_EH_ID") then { player removeEventHandler ["Hit", PUNISH_EH_ID]; };
if !(isNil "PUNISH_KILLED_EH") then { player removeEventHandler ["Killed", PUNISH_KILLED_EH]; };
if !(isNil "PUNISH_LOOP") then { terminate PUNISH_LOOP; };

// Make player truly invincible (AI will still shoot at you)
player allowDamage true;

// ACE3 medical immunity
if !(isNil "ace_medical_enabled") then {
    player setVariable ["ace_medical_allowDamage", false, true];
};

// Remove support item function
PUNISH_fnc_removeSupport = {
    private _assigned = assignedItems player;
    private _available = [];
    if ("ItemMap" in _assigned) then { _available pushBack "ItemMap"; };
    if ("ItemCompass" in _assigned) then { _available pushBack "ItemCompass"; };
    if ("ItemWatch" in _assigned) then { _available pushBack "ItemWatch"; };
    if ("ItemRadio" in _assigned) then { _available pushBack "ItemRadio"; };
    if ("ItemGPS" in _assigned) then { _available pushBack "ItemGPS"; };
    if (count _available > 0) then {
        private _item = selectRandom _available;
        player unassignItem _item;
        player removeItem _item;
        systemChat format ["[HIT] Lost support: %1", _item];
    };
};

// Remove head item function
PUNISH_fnc_removeHead = {
    private _available = [];
    if ((headgear player) != "") then { _available pushBack "headgear"; };
    if ((goggles player) != "") then { _available pushBack "goggles"; };
    if ((hmd player) != "") then { _available pushBack "nvg"; };
    if (count _available > 0) then {
        private _type = selectRandom _available;
        if (_type == "headgear") then {
            private _n = headgear player;
            removeHeadgear player;
            systemChat format ["[HEAD] Lost: %1", _n];
        };
        if (_type == "goggles") then {
            private _n = goggles player;
            removeGoggles player;
            systemChat format ["[HEAD] Lost: %1", _n];
        };
        if (_type == "nvg") then {
            private _n = hmd player;
            player unlinkItem _n;
            systemChat format ["[HEAD] Lost: %1", _n];
        };
    } else {
        systemChat "[HEAD] No head items left!";
    };
};

// Remove chest item function
PUNISH_fnc_removeChest = {
    private _available = [];
    if ((vest player) != "") then { _available pushBack "vest"; };
    if ((backpack player) != "") then { _available pushBack "backpack"; };
    if (count _available > 0) then {
        private _type = selectRandom _available;
        if (_type == "vest") then {
            private _n = vest player;
            removeVest player;
            systemChat format ["[CHEST] Lost: %1", _n];
        };
        if (_type == "backpack") then {
            private _n = backpack player;
            removeBackpack player;
            systemChat format ["[CHEST] Lost: %1", _n];
        };
    } else {
        systemChat "[CHEST] No vest/backpack left!";
    };
};

// Remove weapon function
PUNISH_fnc_removeWeapon = {
    private _available = [];
    if ((primaryWeapon player) != "") then { _available pushBack "primary"; };
    if ((secondaryWeapon player) != "") then { _available pushBack "secondary"; };
    if ((handgunWeapon player) != "") then { _available pushBack "handgun"; };
    if (count _available > 0) then {
        private _type = selectRandom _available;
        if (_type == "primary") then {
            private _n = primaryWeapon player;
            player removeWeapon _n;
            systemChat format ["[ARM] Lost: %1", _n];
        };
        if (_type == "secondary") then {
            private _n = secondaryWeapon player;
            player removeWeapon _n;
            systemChat format ["[ARM] Lost: %1", _n];
        };
        if (_type == "handgun") then {
            private _n = handgunWeapon player;
            player removeWeapon _n;
            systemChat format ["[ARM] Lost: %1", _n];
        };
    } else {
        systemChat "[ARM] No weapons left!";
    };
};

// Drain stamina function
PUNISH_fnc_drainStamina = {
    player setFatigue 1;
    if !(isNil "ace_advanced_fatigue_anReserve") then {
        player setVariable ["ace_advanced_fatigue_anReserve", 0];
        player setVariable ["ace_advanced_fatigue_aeReserve", 0];
    };
    systemChat "[LEG] Stamina drained!";
};

// Get body region from hit selection
PUNISH_fnc_getRegion = {
    params ["_sel"];
    private _s = toLower _sel;
    private _region = "chest";

    if ((_s find "head") > -1) then { _region = "head"; };
    if ((_s find "face") > -1) then { _region = "head"; };
    if ((_s find "arm") > -1) then { _region = "arms"; };
    if ((_s find "hand") > -1) then { _region = "arms"; };
    if ((_s find "leg") > -1) then { _region = "legs"; };

    _region
};

// Use Hit event handler (fires when hit but doesn't block damage)
PUNISH_EH_ID = player addEventHandler ["Hit", {
    params ["_unit", "_source", "_damage", "_instigator"];

    // Get hit selection from the damage
    private _region = "chest";

    // Apply punishment
    call PUNISH_fnc_removeSupport;

    if (_region == "head") then { call PUNISH_fnc_removeHead; };
    if (_region == "chest") then { call PUNISH_fnc_removeChest; };
    if (_region == "arms") then { call PUNISH_fnc_removeWeapon; };
    if (_region == "legs") then { call PUNISH_fnc_drainStamina; };

    // Heal player immediately
    player setDamage 0;

    // ACE3: Reset medical state
    if !(isNil "ace_medical_enabled") then {
        [player] call ace_medical_treatment_fnc_fullHealLocal;
    };
}];

// Alternative: Use HandleDamage to detect body part but don't block damage weirdly
if !(isNil "PUNISH_DMG_EH") then { player removeEventHandler ["HandleDamage", PUNISH_DMG_EH]; };

PUNISH_DMG_EH = player addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

    if (_damage > 0.01) then {
        private _region = [_selection] call PUNISH_fnc_getRegion;

        // Store last hit region for punishment
        player setVariable ["PUNISH_lastRegion", _region];

        // Apply region-specific punishment
        call PUNISH_fnc_removeSupport;

        if (_region == "head") then { call PUNISH_fnc_removeHead; };
        if (_region == "chest") then { call PUNISH_fnc_removeChest; };
        if (_region == "arms") then { call PUNISH_fnc_removeWeapon; };
        if (_region == "legs") then { call PUNISH_fnc_drainStamina; };
    };

    // Return 0 to take no damage
    0
}];

// Backup: Prevent death and heal
PUNISH_KILLED_EH = player addEventHandler ["Killed", {
    params ["_unit"];
    _unit setDamage 0;
    if !(isNil "ace_medical_enabled") then {
        [_unit] call ace_medical_treatment_fnc_fullHealLocal;
    };
}];

// Safety loop - keep player alive and healed
PUNISH_LOOP = [] spawn {
    while {true} do {
        if ((damage player) > 0.5) then {
            player setDamage 0;
        };
        // ACE3: Keep alive
        if !(isNil "ace_medical_enabled") then {
            if (player getVariable ["ace_medical_inCardiacArrest", false]) then {
                player setVariable ["ace_medical_inCardiacArrest", false, true];
            };
            if ((player getVariable ["ace_medical_bloodVolume", 6]) < 5) then {
                player setVariable ["ace_medical_bloodVolume", 6, true];
            };
        };
        sleep 0.1;
    };
};

// Force AI to still target player
player setCaptive false;

systemChat "=== PUNISHMENT SYSTEM ACTIVE (ACE Compatible) ===";
systemChat "Head=gear | Chest=vest/pack | Arm=weapon | Leg=stamina";
hint "Punishment System Active!\nACE3 Compatible - You cannot die!";
