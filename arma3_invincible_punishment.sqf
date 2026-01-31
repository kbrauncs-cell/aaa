// Arma 3 Debug Console Script - Invincible with Body Part Punishment
// ACE3 Compatible - Bulletproof Version
// Execute in debug console (Local Exec)

// Cleanup
if !(isNil "PUNISH_HIT_EH") then { player removeEventHandler ["HitPart", PUNISH_HIT_EH]; };
if !(isNil "PUNISH_DMG_EH") then { player removeEventHandler ["HandleDamage", PUNISH_DMG_EH]; };
if !(isNil "PUNISH_KILLED_EH") then { player removeEventHandler ["Killed", PUNISH_KILLED_EH]; };
if !(isNil "PUNISH_LOOP") then { terminate PUNISH_LOOP; };

// TRUE INVINCIBILITY - Multiple layers
player allowDamage false;

// ACE3 specific - disable all medical damage
player setVariable ["ace_medical_allowDamage", false, true];
player setVariable ["ACE_isUnconscious", false, true];
player setVariable ["ace_medical_inCardiacArrest", false, true];

// Remove support item
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
        systemChat format ["[HIT] Lost: %1", _item];
    };
};

// Remove head item
PUNISH_fnc_removeHead = {
    private _available = [];
    if ((headgear player) != "") then { _available pushBack "headgear"; };
    if ((goggles player) != "") then { _available pushBack "goggles"; };
    if ((hmd player) != "") then { _available pushBack "nvg"; };
    if (count _available > 0) then {
        private _type = selectRandom _available;
        if (_type == "headgear") then { private _n = headgear player; removeHeadgear player; systemChat format ["[HEAD] Lost: %1", _n]; };
        if (_type == "goggles") then { private _n = goggles player; removeGoggles player; systemChat format ["[HEAD] Lost: %1", _n]; };
        if (_type == "nvg") then { private _n = hmd player; player unlinkItem _n; systemChat format ["[HEAD] Lost: %1", _n]; };
    };
};

// Remove chest item
PUNISH_fnc_removeChest = {
    private _available = [];
    if ((vest player) != "") then { _available pushBack "vest"; };
    if ((backpack player) != "") then { _available pushBack "backpack"; };
    if (count _available > 0) then {
        private _type = selectRandom _available;
        if (_type == "vest") then { private _n = vest player; removeVest player; systemChat format ["[CHEST] Lost: %1", _n]; };
        if (_type == "backpack") then { private _n = backpack player; removeBackpack player; systemChat format ["[CHEST] Lost: %1", _n]; };
    };
};

// Remove weapon
PUNISH_fnc_removeWeapon = {
    private _available = [];
    if ((primaryWeapon player) != "") then { _available pushBack "primary"; };
    if ((secondaryWeapon player) != "") then { _available pushBack "secondary"; };
    if ((handgunWeapon player) != "") then { _available pushBack "handgun"; };
    if (count _available > 0) then {
        private _type = selectRandom _available;
        if (_type == "primary") then { private _n = primaryWeapon player; player removeWeapon _n; systemChat format ["[ARM] Lost: %1", _n]; };
        if (_type == "secondary") then { private _n = secondaryWeapon player; player removeWeapon _n; systemChat format ["[ARM] Lost: %1", _n]; };
        if (_type == "handgun") then { private _n = handgunWeapon player; player removeWeapon _n; systemChat format ["[ARM] Lost: %1", _n]; };
    };
};

// Drain stamina
PUNISH_fnc_drainStamina = {
    player setFatigue 1;
    if !(isNil "ace_advanced_fatigue_anReserve") then {
        player setVariable ["ace_advanced_fatigue_anReserve", 0];
        player setVariable ["ace_advanced_fatigue_aeReserve", 0];
    };
    systemChat "[LEG] Stamina drained!";
};

// Temporarily enable damage to detect hit, then disable again
PUNISH_fnc_processHit = {
    params ["_part"];
    private _region = "chest";
    private _p = toLower _part;

    if ((_p find "head") > -1) then { _region = "head"; };
    if ((_p find "face") > -1) then { _region = "head"; };
    if ((_p find "arm") > -1) then { _region = "arms"; };
    if ((_p find "hand") > -1) then { _region = "arms"; };
    if ((_p find "leg") > -1) then { _region = "legs"; };

    call PUNISH_fnc_removeSupport;
    if (_region == "head") then { call PUNISH_fnc_removeHead; };
    if (_region == "chest") then { call PUNISH_fnc_removeChest; };
    if (_region == "arms") then { call PUNISH_fnc_removeWeapon; };
    if (_region == "legs") then { call PUNISH_fnc_drainStamina; };
};

// Use HitPart for body part detection (works even with allowDamage false)
PUNISH_HIT_EH = player addEventHandler ["HitPart", {
    params ["_target", "_shooter", "_projectile", "_position", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_isDirect"];

    if (count _selection > 0) then {
        private _part = _selection select 0;
        [_part] call PUNISH_fnc_processHit;
    } else {
        ["body"] call PUNISH_fnc_processHit;
    };
}];

// Backup HandleDamage - return 0 always
PUNISH_DMG_EH = player addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage"];
    0
}];

// Respawn if somehow killed
PUNISH_KILLED_EH = player addEventHandler ["Killed", {
    params ["_unit"];
    _unit setDamage 0;
    _unit allowDamage false;
    _unit setVariable ["ace_medical_allowDamage", false, true];
}];

// Aggressive safety loop
PUNISH_LOOP = [] spawn {
    while {true} do {
        // Keep invincibility on
        player allowDamage false;
        player setDamage 0;

        // ACE3 reset all medical
        player setVariable ["ace_medical_allowDamage", false, true];
        player setVariable ["ACE_isUnconscious", false, true];
        player setVariable ["ace_medical_inCardiacArrest", false, true];
        player setVariable ["ace_medical_bloodVolume", 6, true];
        player setVariable ["ace_medical_pain", 0, true];
        player setVariable ["ace_medical_painSuppress", 0, true];
        player setVariable ["ace_medical_heartRate", 80, true];
        player setVariable ["ace_medical_bloodPressure", [120, 80], true];
        player setVariable ["ace_medical_woundBleeding", 0, true];

        // Clear wounds
        player setVariable ["ace_medical_openWounds", [], true];
        player setVariable ["ace_medical_bandagedWounds", [], true];
        player setVariable ["ace_medical_stitchedWounds", [], true];

        sleep 0.05;
    };
};

// Make sure AI targets player
player setCaptive false;

systemChat "=== GODMODE + PUNISHMENT ACTIVE ===";
systemChat "HitPart detection enabled";
hint "GODMODE Active!\nPunishment system running.";
