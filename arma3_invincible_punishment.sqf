// Arma 3 Debug Console Script - Invincible with Body Part Punishment
// Execute in debug console (Local Exec)

// Cleanup old handlers
if !(isNil "PUNISH_EH_ID") then { player removeEventHandler ["HandleDamage", PUNISH_EH_ID]; };
if !(isNil "PUNISH_KILLED_EH") then { player removeEventHandler ["Killed", PUNISH_KILLED_EH]; };
if !(isNil "PUNISH_LOOP") then { terminate PUNISH_LOOP; };

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

// Get body region function
PUNISH_fnc_getRegion = {
    params ["_sel", "_hit"];
    private _s = toLower _sel;
    private _h = toLower _hit;
    private _region = "none";

    private _headCheck1 = _s find "head";
    private _headCheck2 = _h find "head";
    private _headCheck3 = _s find "face";
    private _headCheck4 = _h find "face";
    if (_headCheck1 > -1) then { _region = "head"; };
    if (_headCheck2 > -1) then { _region = "head"; };
    if (_headCheck3 > -1) then { _region = "head"; };
    if (_headCheck4 > -1) then { _region = "head"; };

    private _chestCheck1 = _s find "spine";
    private _chestCheck2 = _h find "spine";
    private _chestCheck3 = _s find "chest";
    private _chestCheck4 = _h find "chest";
    private _chestCheck5 = _s find "body";
    private _chestCheck6 = _h find "body";
    private _chestCheck7 = _s find "pelvis";
    private _chestCheck8 = _h find "pelvis";
    if (_chestCheck1 > -1) then { _region = "chest"; };
    if (_chestCheck2 > -1) then { _region = "chest"; };
    if (_chestCheck3 > -1) then { _region = "chest"; };
    if (_chestCheck4 > -1) then { _region = "chest"; };
    if (_chestCheck5 > -1) then { _region = "chest"; };
    if (_chestCheck6 > -1) then { _region = "chest"; };
    if (_chestCheck7 > -1) then { _region = "chest"; };
    if (_chestCheck8 > -1) then { _region = "chest"; };

    private _armCheck1 = _s find "arm";
    private _armCheck2 = _h find "arm";
    private _armCheck3 = _s find "hand";
    private _armCheck4 = _h find "hand";
    if (_armCheck1 > -1) then { _region = "arms"; };
    if (_armCheck2 > -1) then { _region = "arms"; };
    if (_armCheck3 > -1) then { _region = "arms"; };
    if (_armCheck4 > -1) then { _region = "arms"; };

    private _legCheck1 = _s find "leg";
    private _legCheck2 = _h find "leg";
    if (_legCheck1 > -1) then { _region = "legs"; };
    if (_legCheck2 > -1) then { _region = "legs"; };

    _region
};

// Main damage handler
PUNISH_EH_ID = player addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

    if (_damage <= 0) exitWith { 0 };

    private _region = [_selection, _hitPoint] call PUNISH_fnc_getRegion;

    if (_region == "none") then {
        if (_damage > 0.1) then { _region = "chest"; };
    };

    if (_region != "none") then {
        call PUNISH_fnc_removeSupport;
        if (_region == "head") then { call PUNISH_fnc_removeHead; };
        if (_region == "chest") then { call PUNISH_fnc_removeChest; };
        if (_region == "arms") then { call PUNISH_fnc_removeWeapon; };
        if (_region == "legs") then { call PUNISH_fnc_drainStamina; };
    };

    private _currentDmg = damage _unit;
    if ((_currentDmg + _damage) >= 1) exitWith { 0.05 };
    _damage * 0.3
}];

// Backup death prevention
PUNISH_KILLED_EH = player addEventHandler ["Killed", {
    params ["_unit"];
    _unit setDamage 0;
}];

// Safety loop to prevent death
PUNISH_LOOP = [] spawn {
    while {true} do {
        if ((damage player) > 0.85) then { player setDamage 0.5; };
        sleep 0.1;
    };
};

systemChat "=== PUNISHMENT SYSTEM ACTIVE ===";
systemChat "Head=gear | Chest=vest/pack | Arm=weapon | Leg=stamina";
hint "Punishment System Active!";
