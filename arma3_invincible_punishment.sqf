// Arma 3 - Punishment System ONLY (no invincibility)
// Use your own invincibility method, this just removes items on hit
// Execute in debug console (Local Exec)

// Cleanup
if !(isNil "PUNISH_DMG_EH") then { player removeEventHandler ["HandleDamage", PUNISH_DMG_EH]; };

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
    private _h = headgear player;
    private _g = goggles player;
    private _n = hmd player;
    private _available = [];
    if (_h != "") then { _available pushBack ["headgear", _h]; };
    if (_g != "") then { _available pushBack ["goggles", _g]; };
    if (_n != "") then { _available pushBack ["nvg", _n]; };
    if (count _available > 0) then {
        private _pick = selectRandom _available;
        private _type = _pick select 0;
        private _name = _pick select 1;
        if (_type == "headgear") then { removeHeadgear player; };
        if (_type == "goggles") then { removeGoggles player; };
        if (_type == "nvg") then { player unlinkItem _name; };
        systemChat format ["[HEAD] Lost: %1", _name];
    };
};

// Remove chest item
PUNISH_fnc_removeChest = {
    private _v = vest player;
    private _b = backpack player;
    private _available = [];
    if (_v != "") then { _available pushBack ["vest", _v]; };
    if (_b != "") then { _available pushBack ["backpack", _b]; };
    if (count _available > 0) then {
        private _pick = selectRandom _available;
        private _type = _pick select 0;
        private _name = _pick select 1;
        if (_type == "vest") then { removeVest player; };
        if (_type == "backpack") then { removeBackpack player; };
        systemChat format ["[CHEST] Lost: %1", _name];
    };
};

// Remove weapon
PUNISH_fnc_removeWeapon = {
    private _p = primaryWeapon player;
    private _s = secondaryWeapon player;
    private _h = handgunWeapon player;
    private _available = [];
    if (_p != "") then { _available pushBack ["primary", _p]; };
    if (_s != "") then { _available pushBack ["secondary", _s]; };
    if (_h != "") then { _available pushBack ["handgun", _h]; };
    if (count _available > 0) then {
        private _pick = selectRandom _available;
        private _name = _pick select 1;
        player removeWeapon _name;
        systemChat format ["[ARM] Lost: %1", _name];
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

// Detect hits and apply punishment - DOES NOT CHANGE DAMAGE
PUNISH_DMG_EH = player addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

    // Only trigger on real damage attempts
    if (_damage < 0.01) exitWith {};

    // Get body region
    private _region = "chest";
    private _sel = "";
    if (_selection isEqualType "") then { _sel = toLower _selection; };

    if (_sel find "head" > -1) then { _region = "head"; };
    if (_sel find "face" > -1) then { _region = "head"; };
    if (_sel find "arm" > -1) then { _region = "arms"; };
    if (_sel find "hand" > -1) then { _region = "arms"; };
    if (_sel find "leg" > -1) then { _region = "legs"; };

    // Apply punishments
    call PUNISH_fnc_removeSupport;
    if (_region == "head") then { call PUNISH_fnc_removeHead; };
    if (_region == "chest") then { call PUNISH_fnc_removeChest; };
    if (_region == "arms") then { call PUNISH_fnc_removeWeapon; };
    if (_region == "legs") then { call PUNISH_fnc_drainStamina; };

    // Return nothing - let other handlers control damage
}];

systemChat "=== PUNISHMENT SYSTEM ACTIVE ===";
systemChat "Head=gear | Chest=vest/pack | Arm=weapon | Leg=stamina";
hint "Punishment Only!\nUse your own invincibility\nItems removed on hit";
