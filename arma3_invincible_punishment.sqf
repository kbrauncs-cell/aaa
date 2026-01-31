// Arma 3 Debug Console Script - Level 5 Armor + Punishment System
// Player has extreme damage reduction but can still die
// Execute in debug console (Local Exec)

// Cleanup old handlers
if !(isNil "PUNISH_DMG_EH") then { player removeEventHandler ["HandleDamage", PUNISH_DMG_EH]; };

// Block all damage - punishment IS the consequence
PUNISH_ARMOR_MULT = 0;

// Disable ACE medical damage processing
player setVariable ["ace_medical_allowDamage", false, true];

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
    private _h = headgear player;
    private _g = goggles player;
    private _n = hmd player;
    if (_h != "") then { _available pushBack "headgear"; };
    if (_g != "") then { _available pushBack "goggles"; };
    if (_n != "") then { _available pushBack "nvg"; };
    if (count _available > 0) then {
        private _type = selectRandom _available;
        if (_type == "headgear") then { removeHeadgear player; systemChat format ["[HEAD] Lost: %1", _h]; };
        if (_type == "goggles") then { removeGoggles player; systemChat format ["[HEAD] Lost: %1", _g]; };
        if (_type == "nvg") then { player unlinkItem _n; systemChat format ["[HEAD] Lost: %1", _n]; };
    };
};

// Remove chest item
PUNISH_fnc_removeChest = {
    private _available = [];
    private _v = vest player;
    private _b = backpack player;
    if (_v != "") then { _available pushBack "vest"; };
    if (_b != "") then { _available pushBack "backpack"; };
    if (count _available > 0) then {
        private _type = selectRandom _available;
        if (_type == "vest") then { removeVest player; systemChat format ["[CHEST] Lost: %1", _v]; };
        if (_type == "backpack") then { removeBackpack player; systemChat format ["[CHEST] Lost: %1", _b]; };
    };
};

// Remove weapon
PUNISH_fnc_removeWeapon = {
    private _available = [];
    private _p = primaryWeapon player;
    private _s = secondaryWeapon player;
    private _h = handgunWeapon player;
    if (_p != "") then { _available pushBack "primary"; };
    if (_s != "") then { _available pushBack "secondary"; };
    if (_h != "") then { _available pushBack "handgun"; };
    if (count _available > 0) then {
        private _type = selectRandom _available;
        if (_type == "primary") then { player removeWeapon _p; systemChat format ["[ARM] Lost: %1", _p]; };
        if (_type == "secondary") then { player removeWeapon _s; systemChat format ["[ARM] Lost: %1", _s]; };
        if (_type == "handgun") then { player removeWeapon _h; systemChat format ["[ARM] Lost: %1", _h]; };
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

// Main handler - reduces damage + applies punishment
PUNISH_DMG_EH = player addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

    // Only process real damage
    if (_damage < 0.01) exitWith { 0 };

    // Determine body region
    private _region = "chest";
    private _sel = "";
    if (_selection isEqualType "") then { _sel = toLower _selection; };

    if (_sel find "head" > -1) then { _region = "head"; };
    if (_sel find "face" > -1) then { _region = "head"; };
    if (_sel find "arm" > -1) then { _region = "arms"; };
    if (_sel find "hand" > -1) then { _region = "arms"; };
    if (_sel find "leg" > -1) then { _region = "legs"; };

    // Apply punishment
    call PUNISH_fnc_removeSupport;
    if (_region == "head") then { call PUNISH_fnc_removeHead; };
    if (_region == "chest") then { call PUNISH_fnc_removeChest; };
    if (_region == "arms") then { call PUNISH_fnc_removeWeapon; };
    if (_region == "legs") then { call PUNISH_fnc_drainStamina; };

    // Return reduced damage (level 5 armor)
    _damage * PUNISH_ARMOR_MULT
}];

systemChat "=== ARMOR + PUNISHMENT ACTIVE ===";
systemChat "Full damage block - punishment is consequence";
hint "Armor Active!\nNo health damage\nLose items when hit";
