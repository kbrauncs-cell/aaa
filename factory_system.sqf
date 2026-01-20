// Timed Crate Spawner GUI - v4 ENHANCED - Morale + Pier Factory + Dynamic Requests
player addAction ["Open Crate Spawner", {
    createDialog "RscDisplayEmpty";
    _display = findDisplay -1;

    _bg = _display ctrlCreate ["RscText", 1000];
    _bg ctrlSetPosition [0.0, 0.0, 1.0, 1.0];
    _bg ctrlSetBackgroundColor [0, 0, 0, 0.8];
    _bg ctrlCommit 0;

    _title = _display ctrlCreate ["RscText", 1001];
    _title ctrlSetPosition [0.0, 0.0, 1.0, 0.06];
    _title ctrlSetText "Timed Crate Spawner - Click Map to Place/Select Factory";
    _title ctrlSetBackgroundColor [0.2, 0.2, 0.2, 1];
    _title ctrlSetFontHeight 0.045;
    _title ctrlCommit 0;

    _map = _display ctrlCreate ["RscMapControl", 1014];
    _map ctrlSetPosition [0.0, 0.07, 0.65, 0.86];
    _map ctrlCommit 0;

    if (isNil "CRATE_FACTORY_POSITIONS") then {CRATE_FACTORY_POSITIONS = []};
    if (isNil "CRATE_FACTORY_COUNTS") then {CRATE_FACTORY_COUNTS = []};
    if (isNil "CRATE_FACTORY_TIMERS") then {CRATE_FACTORY_TIMERS = []};
    if (isNil "CRATE_SPAWN_SCRIPTS") then {CRATE_SPAWN_SCRIPTS = []};
    if (isNil "CRATE_FACTORY_TYPES") then {CRATE_FACTORY_TYPES = []};
    if (isNil "CRATE_PENDING_LOCATION") then {CRATE_PENDING_LOCATION = []};
    if (isNil "CRATE_FACTORY_INTERVALS") then {CRATE_FACTORY_INTERVALS = []};
    if (isNil "CRATE_FACTORY_CRATETYPES") then {CRATE_FACTORY_CRATETYPES = []};
    if (isNil "CRATE_FACTORY_MAXCRATES") then {CRATE_FACTORY_MAXCRATES = []};
    if (isNil "CRATE_FACTORY_SUPPLIES") then {CRATE_FACTORY_SUPPLIES = []};
    if (isNil "CRATE_FACTORY_SPAWNEDCRATES") then {CRATE_FACTORY_SPAWNEDCRATES = []};
    if (isNil "CRATE_FACTORY_FOOD") then {CRATE_FACTORY_FOOD = []};
    if (isNil "CRATE_FACTORY_WATER") then {CRATE_FACTORY_WATER = []};
    if (isNil "CRATE_FACTORY_ELECTRICITY") then {CRATE_FACTORY_ELECTRICITY = []};
    if (isNil "CRATE_FACTORY_METAL") then {CRATE_FACTORY_METAL = []};
    if (isNil "CRATE_FACTORY_WOOD") then {CRATE_FACTORY_WOOD = []};
    if (isNil "CRATE_FACTORY_COAL") then {CRATE_FACTORY_COAL = []};
    if (isNil "CRATE_FACTORY_MAINTENANCE_TIMERS") then {CRATE_FACTORY_MAINTENANCE_TIMERS = []};
    if (isNil "CRATE_FACTORY_NEEDS_MAINTENANCE") then {CRATE_FACTORY_NEEDS_MAINTENANCE = []};
    if (isNil "CRATE_SELECTED_FACTORY") then {CRATE_SELECTED_FACTORY = -1};
    if (isNil "CRATE_FACTORY_FIRES") then {CRATE_FACTORY_FIRES = []};
    if (isNil "CRATE_FACTORY_MORALE") then {CRATE_FACTORY_MORALE = []};
    if (isNil "CRATE_FACTORY_REQUEST_PENDING") then {CRATE_FACTORY_REQUEST_PENDING = []};
    if (isNil "CRATE_FACTORY_REQUEST_TYPE") then {CRATE_FACTORY_REQUEST_TYPE = []};
    if (isNil "CRATE_FACTORY_REQUEST_AMOUNT") then {CRATE_FACTORY_REQUEST_AMOUNT = []};
    if (isNil "CRATE_FACTORY_REQUEST_TIMER") then {CRATE_FACTORY_REQUEST_TIMER = []};

    _map ctrlAddEventHandler ["MouseButtonDown", {
        params ["_control", "_button", "_xPos", "_yPos"];
        if (_button == 0) then {
            _worldPos = _control ctrlMapScreenToWorld [_xPos, _yPos];
            _clickedFactory = -1;
            {
                _dist = _worldPos distance2D _x;
                if (_dist < 50) then {_clickedFactory = _forEachIndex};
            } forEach CRATE_FACTORY_POSITIONS;
            if (_clickedFactory >= 0) then {
                CRATE_SELECTED_FACTORY = _clickedFactory;
                CRATE_PENDING_LOCATION = [];
            } else {
                CRATE_PENDING_LOCATION = _worldPos;
                CRATE_SELECTED_FACTORY = -1;
            };
        };
    }];

    _map ctrlAddEventHandler ["Draw", {
        params ["_control"];
        if (count CRATE_PENDING_LOCATION > 0) then {
            _control drawIcon ["\a3\ui_f\data\map\markers\military\circle_CA.paa",[1, 1, 0, 0.7],CRATE_PENDING_LOCATION,40,40,0,"SPAWN",1,0.05,"PuristaMedium","center"];
        };
        {
            _factoryType = if (_forEachIndex < count CRATE_FACTORY_TYPES) then {CRATE_FACTORY_TYPES select _forEachIndex} else {"Mineral"};
            _color = [0, 1, 0, 1];
            if (_factoryType == "Town") then {_color = [0, 0.5, 1, 1]};
            if (_factoryType == "Powerplant") then {_color = [1, 0.5, 0, 1]};
            if (_factoryType == "Vehicle") then {_color = [0.5, 0, 1, 1]};
            if (_factoryType == "Pier") then {_color = [0, 0.8, 0.8, 1]};
            if (_forEachIndex == CRATE_SELECTED_FACTORY) then {
                _control drawEllipse [_x, 70, 70, 0, [1, 1, 0, 1], "#(rgb,1,1,1)color(0,0,0,0)"];
            };
            _control drawIcon ["\a3\ui_f\data\map\markers\nato\b_installation.paa",_color,_x,35,35,0,format ["F%1", _forEachIndex + 1],1,0.05,"PuristaMedium","right"];
        } forEach CRATE_FACTORY_POSITIONS;
    }];

    _settingsBg = _display ctrlCreate ["RscText", 1015];
    _settingsBg ctrlSetPosition [0.66, 0.07, 0.34, 0.86];
    _settingsBg ctrlSetBackgroundColor [0.15, 0.15, 0.15, 1];
    _settingsBg ctrlCommit 0;

    _infoBox = _display ctrlCreate ["RscStructuredText", 1050];
    _infoBox ctrlSetPosition [0.68, 0.09, 0.30, 0.14];
    _infoBox ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
    _infoBox ctrlCommit 0;

    _labelFactoryType = _display ctrlCreate ["RscText", 1023];
    _labelFactoryType ctrlSetPosition [0.68, 0.24, 0.30, 0.025];
    _labelFactoryType ctrlSetText "New Factory Type:";
    _labelFactoryType ctrlSetFontHeight 0.032;
    _labelFactoryType ctrlCommit 0;

    _comboFactoryType = _display ctrlCreate ["RscCombo", 1024];
    _comboFactoryType ctrlSetPosition [0.68, 0.265, 0.30, 0.035];
    _comboFactoryType lbAdd "Mineral Factory";
    _comboFactoryType lbSetData [0, "Mineral"];
    _comboFactoryType lbAdd "Town Factory";
    _comboFactoryType lbSetData [1, "Town"];
    _comboFactoryType lbAdd "Powerplant Factory";
    _comboFactoryType lbSetData [2, "Powerplant"];
    _comboFactoryType lbAdd "Vehicle Factory";
    _comboFactoryType lbSetData [3, "Vehicle"];
    _comboFactoryType lbAdd "Pier Factory";
    _comboFactoryType lbSetData [4, "Pier"];
    _comboFactoryType lbSetCurSel 0;
    _comboFactoryType ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
    _comboFactoryType ctrlSetFontHeight 0.03;
    _comboFactoryType ctrlCommit 0;

    _labelCost = _display ctrlCreate ["RscStructuredText", 1051];
    _labelCost ctrlSetPosition [0.68, 0.30, 0.30, 0.13];
    _labelCost ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
    _labelCost ctrlCommit 0;

    _comboFactoryType ctrlAddEventHandler ["LBSelChanged", {
        params ["_ctrl"];
        _display = ctrlParent _ctrl;
        _labelCost = _display displayCtrl 1051;
        if (count CRATE_PENDING_LOCATION == 0) exitWith {
            _labelCost ctrlSetStructuredText parseText "<t size='1.0'>Click map first</t>";
        };
        _factoryType = _ctrl lbData (lbCurSel _ctrl);

        if (_factoryType == "Town") then {
            _townCount = {_x == "Town"} count CRATE_FACTORY_TYPES;
            if (_townCount == 0) then {
                _labelCost ctrlSetStructuredText parseText "<t size='1.0' color='#0f0'>FREE!</t>";
            } else {
                _houseCount = count (nearestObjects [CRATE_PENDING_LOCATION, ["House"], 400]);
                _foodCost = 2 * _townCount;
                _waterCost = 3 * _townCount;
                _metalCost = 0;
                _houseCostMultiplier = 1 + ((_houseCount / 10) * 0.1);
                _foodCost = ceil (_foodCost * _houseCostMultiplier);
                _waterCost = ceil (_waterCost * _houseCostMultiplier);
                if (_houseCount >= 100) then {_metalCost = 2 + floor(_houseCount / 50)};
                if (_metalCost > 0) then {
                    _costText = format ["<t size='0.9'>Cost:<br/>%1x Food<br/>%2x Water<br/>%3x Metal<br/><t size='0.8' color='#888'>Houses:%4</t></t>", _foodCost, _waterCost, _metalCost, _houseCount];
                } else {
                    _costText = format ["<t size='0.9'>Cost:<br/>%1x Food<br/>%2x Water<br/><t size='0.8' color='#888'>Houses:%3</t></t>", _foodCost, _waterCost, _houseCount];
                };
                _labelCost ctrlSetStructuredText parseText _costText;
            };
        } else {
            if (_factoryType == "Mineral") then {
                _mineralCount = {_x == "Mineral"} count CRATE_FACTORY_TYPES;
                _foodCost = 5 + (5 * _mineralCount);
                _waterCost = 5 + (5 * _mineralCount);
                _woodCost = 5 + (5 * _mineralCount);
                _costText = format ["<t size='0.9'>Cost:<br/>%1x Food<br/>%2x Water<br/>%3x Wood</t>", _foodCost, _waterCost, _woodCost];
                _labelCost ctrlSetStructuredText parseText _costText;
            } else {
                if (_factoryType == "Powerplant") then {
                    _powerCount = {_x == "Powerplant"} count CRATE_FACTORY_TYPES;
                    _coalCost = 4 + (4 * _powerCount);
                    _metalCost = 3 + (3 * _powerCount);
                    _costText = format ["<t size='0.9'>Cost:<br/>%1x Coal<br/>%2x Metal</t>", _coalCost, _metalCost];
                    _labelCost ctrlSetStructuredText parseText _costText;
                } else {
                    if (_factoryType == "Vehicle") then {
                        _vehicleCount = {_x == "Vehicle"} count CRATE_FACTORY_TYPES;
                        _energyCost = 5 + (5 * _vehicleCount);
                        _metalCost = 5 + (5 * _vehicleCount);
                        _costText = format ["<t size='0.9'>Cost:<br/>%1x Energy<br/>%2x Metal</t>", _energyCost, _metalCost];
                        _labelCost ctrlSetStructuredText parseText _costText;
                    } else {
                        if (_factoryType == "Pier") then {
                            _pierCount = {_x == "Pier"} count CRATE_FACTORY_TYPES;
                            _foodCost = 3 + (3 * _pierCount);
                            _waterCost = 5 + (5 * _pierCount);
                            _woodCost = 7 + (7 * _pierCount);
                            _costText = format ["<t size='0.9'>Cost:<br/>%1x Food<br/>%2x Water<br/>%3x Wood</t>", _foodCost, _waterCost, _woodCost];
                            _labelCost ctrlSetStructuredText parseText _costText;
                        } else {
                            _labelCost ctrlSetStructuredText parseText "<t size='1.0' color='#0f0'>FREE</t>";
                        };
                    };
                };
            };
        };
    }];

    _btnSpawnFactory = _display ctrlCreate ["RscButton", 1025];
    _btnSpawnFactory ctrlSetPosition [0.68, 0.43, 0.30, 0.04];
    _btnSpawnFactory ctrlSetText "SPAWN FACTORY";
    _btnSpawnFactory ctrlSetBackgroundColor [0, 0.4, 0.7, 1];
    _btnSpawnFactory ctrlSetFontHeight 0.032;
    _btnSpawnFactory ctrlCommit 0;

    _btnSpawnFactory ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        _display = ctrlParent _ctrl;
        if (count CRATE_PENDING_LOCATION == 0) exitWith {
            systemChat "Click on map to place a factory first!";
        };
        _comboFactoryType = _display displayCtrl 1024;
        _factoryType = _comboFactoryType lbData (lbCurSel _comboFactoryType);

        if (_factoryType == "Town") then {
            _townCount = {_x == "Town"} count CRATE_FACTORY_TYPES;
            if (_townCount > 0) then {
                _houseCount = count (nearestObjects [CRATE_PENDING_LOCATION, ["House"], 400]);
                _foodCost = 2 * _townCount;
                _waterCost = 3 * _townCount;
                _metalCost = 0;
                _houseCostMultiplier = 1 + ((_houseCount / 10) * 0.1);
                _foodCost = ceil (_foodCost * _houseCostMultiplier);
                _waterCost = ceil (_waterCost * _houseCostMultiplier);
                if (_houseCount >= 100) then {_metalCost = 2 + floor(_houseCount / 50)};
                _nearFoodCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_FoodSacks_01_large_white_idap_F"], 100];
                _nearWaterCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PaperBox_01_open_water_F"], 100];
                _nearMetalCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_CargoBox_V1_F"], 100];
                if (count _nearFoodCrates < _foodCost) exitWith {systemChat format ["Need %1x Food! (Found:%2)", _foodCost, count _nearFoodCrates]};
                if (count _nearWaterCrates < _waterCost) exitWith {systemChat format ["Need %1x Water! (Found:%2)", _waterCost, count _nearWaterCrates]};
                if (_metalCost > 0 && count _nearMetalCrates < _metalCost) exitWith {systemChat format ["Need %1x Metal! (Found:%2)", _metalCost, count _nearMetalCrates]};
                for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFoodCrates select _i)};
                for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWaterCrates select _i)};
                if (_metalCost > 0) then {
                    for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetalCrates select _i)};
                };
            };
        };

        if (_factoryType == "Mineral") then {
            _mineralCount = {_x == "Mineral"} count CRATE_FACTORY_TYPES;
            _foodCost = 5 + (5 * _mineralCount);
            _waterCost = 5 + (5 * _mineralCount);
            _woodCost = 5 + (5 * _mineralCount);
            _nearFoodCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_FoodSacks_01_large_white_idap_F"], 100];
            _nearWaterCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PaperBox_01_open_water_F"], 100];
            _nearWoodCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodPile_03_F"], 100];
            if (count _nearFoodCrates < _foodCost) exitWith {systemChat format ["Need %1x Food! (Found:%2)", _foodCost, count _nearFoodCrates]};
            if (count _nearWaterCrates < _waterCost) exitWith {systemChat format ["Need %1x Water! (Found:%2)", _waterCost, count _nearWaterCrates]};
            if (count _nearWoodCrates < _woodCost) exitWith {systemChat format ["Need %1x Wood! (Found:%2)", _woodCost, count _nearWoodCrates]};
            for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFoodCrates select _i)};
            for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWaterCrates select _i)};
            for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWoodCrates select _i)};
        };

        if (_factoryType == "Powerplant") then {
            _powerCount = {_x == "Powerplant"} count CRATE_FACTORY_TYPES;
            _coalCost = 4 + (4 * _powerCount);
            _metalCost = 3 + (3 * _powerCount);
            _nearCoalCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PaperBox_closed_F"], 100];
            _nearMetalCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_CargoBox_V1_F"], 100];
            if (count _nearCoalCrates < _coalCost) exitWith {systemChat format ["Need %1x Coal! (Found:%2)", _coalCost, count _nearCoalCrates]};
            if (count _nearMetalCrates < _metalCost) exitWith {systemChat format ["Need %1x Metal! (Found:%2)", _metalCost, count _nearMetalCrates]};
            for "_i" from 0 to (_coalCost - 1) do {deleteVehicle (_nearCoalCrates select _i)};
            for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetalCrates select _i)};
        };

        if (_factoryType == "Vehicle") then {
            _vehicleCount = {_x == "Vehicle"} count CRATE_FACTORY_TYPES;
            _energyCost = 5 + (5 * _vehicleCount);
            _metalCost = 5 + (5 * _vehicleCount);
            _nearEnergyCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PortableServer_01_sand_F"], 100];
            _nearMetalCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_CargoBox_V1_F"], 100];
            if (count _nearEnergyCrates < _energyCost) exitWith {systemChat format ["Need %1x Energy! (Found:%2)", _energyCost, count _nearEnergyCrates]};
            if (count _nearMetalCrates < _metalCost) exitWith {systemChat format ["Need %1x Metal! (Found:%2)", _metalCost, count _nearMetalCrates]};
            for "_i" from 0 to (_energyCost - 1) do {deleteVehicle (_nearEnergyCrates select _i)};
            for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetalCrates select _i)};
        };

        if (_factoryType == "Pier") then {
            _pierCount = {_x == "Pier"} count CRATE_FACTORY_TYPES;
            _foodCost = 3 + (3 * _pierCount);
            _waterCost = 5 + (5 * _pierCount);
            _woodCost = 7 + (7 * _pierCount);
            _nearFoodCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_FoodSacks_01_large_white_idap_F"], 100];
            _nearWaterCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PaperBox_01_open_water_F"], 100];
            _nearWoodCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodPile_03_F"], 100];
            if (count _nearFoodCrates < _foodCost) exitWith {systemChat format ["Need %1x Food! (Found:%2)", _foodCost, count _nearFoodCrates]};
            if (count _nearWaterCrates < _waterCost) exitWith {systemChat format ["Need %1x Water! (Found:%2)", _waterCost, count _nearWaterCrates]};
            if (count _nearWoodCrates < _woodCost) exitWith {systemChat format ["Need %1x Wood! (Found:%2)", _woodCost, count _nearWoodCrates]};
            for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFoodCrates select _i)};
            for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWaterCrates select _i)};
            for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWoodCrates select _i)};
        };

        _spawnInterval = 60;
        if (_factoryType == "Town") then {
            _houseCount = count (nearestObjects [CRATE_PENDING_LOCATION, ["House"], 400]);
            _houseDensity = (_houseCount / 500) min 1;
            _spawnInterval = 60 - (45 * _houseDensity);
            _spawnInterval = (_spawnInterval max 15) min 60;
        };

        CRATE_FACTORY_POSITIONS pushBack CRATE_PENDING_LOCATION;
        CRATE_FACTORY_COUNTS pushBack 0;
        CRATE_FACTORY_TIMERS pushBack 0;
        CRATE_SPAWN_SCRIPTS pushBack scriptNull;
        CRATE_FACTORY_TYPES pushBack _factoryType;
        CRATE_FACTORY_INTERVALS pushBack _spawnInterval;
        CRATE_FACTORY_CRATETYPES pushBack "";
        CRATE_FACTORY_MAXCRATES pushBack 10;
        CRATE_FACTORY_SUPPLIES pushBack 100;
        CRATE_FACTORY_SPAWNEDCRATES pushBack [];
        CRATE_FACTORY_FOOD pushBack 100;
        CRATE_FACTORY_WATER pushBack 100;
        CRATE_FACTORY_ELECTRICITY pushBack 0;
        if (_factoryType == "Town") then {
            CRATE_FACTORY_METAL pushBack 0;
        } else {
            CRATE_FACTORY_METAL pushBack 100;
        };
        CRATE_FACTORY_WOOD pushBack 100;
        CRATE_FACTORY_COAL pushBack 100;
        CRATE_FACTORY_MAINTENANCE_TIMERS pushBack (2700 + random 4500);
        CRATE_FACTORY_NEEDS_MAINTENANCE pushBack false;
        CRATE_FACTORY_FIRES pushBack [];
        CRATE_FACTORY_MORALE pushBack 100;
        CRATE_FACTORY_REQUEST_PENDING pushBack false;
        CRATE_FACTORY_REQUEST_TYPE pushBack "";
        CRATE_FACTORY_REQUEST_AMOUNT pushBack 0;
        CRATE_FACTORY_REQUEST_TIMER pushBack (300 + random 600);

        CRATE_SELECTED_FACTORY = (count CRATE_FACTORY_POSITIONS) - 1;
        CRATE_PENDING_LOCATION = [];

        systemChat format ["Factory %1 spawned!", CRATE_SELECTED_FACTORY + 1];
    }];

    _resourceY = 0.48;
    _barSpacing = 0.038;

    _labelSupply = _display ctrlCreate ["RscText", 1031];
    _labelSupply ctrlSetPosition [0.68, _resourceY, 0.30, 0.025];
    _labelSupply ctrlSetText "Resources:";
    _labelSupply ctrlSetFontHeight 0.03;
    _labelSupply ctrlCommit 0;

    _supplyBarBg = _display ctrlCreate ["RscText", 1029];
    _supplyBarBg ctrlSetPosition [0.68, _resourceY + 0.025, 0.30, 0.022];
    _supplyBarBg ctrlSetBackgroundColor [0.2, 0.2, 0.2, 1];
    _supplyBarBg ctrlCommit 0;

    _supplyBar = _display ctrlCreate ["RscText", 1030];
    _supplyBar ctrlSetPosition [0.68, _resourceY + 0.025, 0, 0.022];
    _supplyBar ctrlSetBackgroundColor [0, 0.8, 0, 1];
    _supplyBar ctrlCommit 0;

    _resourceY = _resourceY + _barSpacing;
    _labelWater = _display ctrlCreate ["RscText", 1035];
    _labelWater ctrlSetPosition [0.68, _resourceY + 0.025, 0.30, 0.025];
    _labelWater ctrlSetText "Water: 100%";
    _labelWater ctrlSetFontHeight 0.03;
    _labelWater ctrlShow false;
    _labelWater ctrlCommit 0;

    _waterBarBg = _display ctrlCreate ["RscText", 1033];
    _waterBarBg ctrlSetPosition [0.68, _resourceY + 0.05, 0.30, 0.022];
    _waterBarBg ctrlSetBackgroundColor [0.2, 0.2, 0.2, 1];
    _waterBarBg ctrlShow false;
    _waterBarBg ctrlCommit 0;

    _waterBar = _display ctrlCreate ["RscText", 1034];
    _waterBar ctrlSetPosition [0.68, _resourceY + 0.05, 0, 0.022];
    _waterBar ctrlSetBackgroundColor [0, 0.5, 1, 1];
    _waterBar ctrlShow false;
    _waterBar ctrlCommit 0;

    _resourceY = _resourceY + _barSpacing;
    _labelWood = _display ctrlCreate ["RscText", 1044];
    _labelWood ctrlSetPosition [0.68, _resourceY + 0.05, 0.30, 0.025];
    _labelWood ctrlSetText "Wood: 100%";
    _labelWood ctrlSetFontHeight 0.03;
    _labelWood ctrlShow false;
    _labelWood ctrlCommit 0;

    _woodBarBg = _display ctrlCreate ["RscText", 1046];
    _woodBarBg ctrlSetPosition [0.68, _resourceY + 0.075, 0.30, 0.022];
    _woodBarBg ctrlSetBackgroundColor [0.2, 0.2, 0.2, 1];
    _woodBarBg ctrlShow false;
    _woodBarBg ctrlCommit 0;

    _woodBar = _display ctrlCreate ["RscText", 1045];
    _woodBar ctrlSetPosition [0.68, _resourceY + 0.075, 0, 0.022];
    _woodBar ctrlSetBackgroundColor [0.6, 0.4, 0.2, 1];
    _woodBar ctrlShow false;
    _woodBar ctrlCommit 0;

    _resourceY = _resourceY + _barSpacing;
    _labelMetal = _display ctrlCreate ["RscText", 1041];
    _labelMetal ctrlSetPosition [0.68, _resourceY + 0.075, 0.30, 0.025];
    _labelMetal ctrlSetText "Metal: 100%";
    _labelMetal ctrlSetFontHeight 0.03;
    _labelMetal ctrlShow false;
    _labelMetal ctrlCommit 0;

    _metalBarBg = _display ctrlCreate ["RscText", 1043];
    _metalBarBg ctrlSetPosition [0.68, _resourceY + 0.10, 0.30, 0.022];
    _metalBarBg ctrlSetBackgroundColor [0.2, 0.2, 0.2, 1];
    _metalBarBg ctrlShow false;
    _metalBarBg ctrlCommit 0;

    _metalBar = _display ctrlCreate ["RscText", 1042];
    _metalBar ctrlSetPosition [0.68, _resourceY + 0.10, 0, 0.022];
    _metalBar ctrlSetBackgroundColor [0.6, 0.6, 0.7, 1];
    _metalBar ctrlShow false;
    _metalBar ctrlCommit 0;

    _resourceY = _resourceY + _barSpacing;
    _labelElectricity = _display ctrlCreate ["RscText", 1038];
    _labelElectricity ctrlSetPosition [0.68, _resourceY + 0.10, 0.30, 0.025];
    _labelElectricity ctrlSetText "Electricity: 0%";
    _labelElectricity ctrlSetFontHeight 0.03;
    _labelElectricity ctrlShow false;
    _labelElectricity ctrlCommit 0;

    _electricityBarBg = _display ctrlCreate ["RscText", 1039];
    _electricityBarBg ctrlSetPosition [0.68, _resourceY + 0.125, 0.30, 0.022];
    _electricityBarBg ctrlSetBackgroundColor [0.2, 0.2, 0.2, 1];
    _electricityBarBg ctrlShow false;
    _electricityBarBg ctrlCommit 0;

    _electricityBar = _display ctrlCreate ["RscText", 1040];
    _electricityBar ctrlSetPosition [0.68, _resourceY + 0.125, 0, 0.022];
    _electricityBar ctrlSetBackgroundColor [1, 1, 0, 1];
    _electricityBar ctrlShow false;
    _electricityBar ctrlCommit 0;

    _btnResupply = _display ctrlCreate ["RscButton", 1036];
    _btnResupply ctrlSetPosition [0.68, 0.70, 0.30, 0.035];
    _btnResupply ctrlSetText "FULFILL REQUEST / RESUPPLY";
    _btnResupply ctrlSetBackgroundColor [0.2, 0.6, 0.4, 1];
    _btnResupply ctrlSetFontHeight 0.028;
    _btnResupply ctrlCommit 0;

    _btnResupply ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        if (CRATE_SELECTED_FACTORY < 0) exitWith {systemChat "Select a factory!"};
        _selectedIndex = CRATE_SELECTED_FACTORY;
        _factoryType = CRATE_FACTORY_TYPES select _selectedIndex;
        _factoryPos = CRATE_FACTORY_POSITIONS select _selectedIndex;
        _replenished = false;

        _hasPendingRequest = CRATE_FACTORY_REQUEST_PENDING select _selectedIndex;
        if (_hasPendingRequest) then {
            _requestType = CRATE_FACTORY_REQUEST_TYPE select _selectedIndex;
            _requestAmount = CRATE_FACTORY_REQUEST_AMOUNT select _selectedIndex;
            _requestClassname = "Land_FoodSacks_01_large_white_idap_F";
            if (_requestType == "Water") then {_requestClassname = "Land_PaperBox_01_open_water_F"};
            if (_requestType == "Wood") then {_requestClassname = "Land_WoodPile_03_F"};
            if (_requestType == "Coal") then {_requestClassname = "Land_PaperBox_closed_F"};
            if (_requestType == "Metal") then {_requestClassname = "Land_CargoBox_V1_F"};
            if (_requestType == "Energy") then {_requestClassname = "Land_PortableServer_01_sand_F"};

            _nearCrates = nearestObjects [_factoryPos, [_requestClassname], 25];
            if (count _nearCrates >= _requestAmount) then {
                for "_i" from 0 to (_requestAmount - 1) do {deleteVehicle (_nearCrates select _i)};
                CRATE_FACTORY_REQUEST_PENDING set [_selectedIndex, false];
                CRATE_FACTORY_REQUEST_TYPE set [_selectedIndex, ""];
                CRATE_FACTORY_REQUEST_AMOUNT set [_selectedIndex, 0];
                CRATE_FACTORY_REQUEST_TIMER set [_selectedIndex, (300 + random 600)];
                CRATE_FACTORY_MORALE set [_selectedIndex, 100];

                _fires = CRATE_FACTORY_FIRES select _selectedIndex;
                {deleteVehicle _x} forEach _fires;
                CRATE_FACTORY_FIRES set [_selectedIndex, []];

                systemChat format ["Request fulfilled! Used %1x %2. Morale restored!", _requestAmount, _requestType];
                _replenished = true;
            } else {
                systemChat format ["Need %1x %2 within 25m for request! (Found: %3)", _requestAmount, _requestType, count _nearCrates];
            };
        } else {
            if (_factoryType == "Town") then {
                _currentMetal = CRATE_FACTORY_METAL select _selectedIndex;
                if (_currentMetal < 100) then {
                    _nearMetalCrates = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 25];
                    if (count _nearMetalCrates > 0) then {
                        deleteVehicle (_nearMetalCrates select 0);
                        _newMetal = (_currentMetal + 25) min 100;
                        CRATE_FACTORY_METAL set [_selectedIndex, _newMetal];
                        systemChat format ["Metal +25%% (%1%%)", round _newMetal];
                        _replenished = true;
                    };
                };
            };
            if (_factoryType == "Powerplant") then {
                _currentCoal = CRATE_FACTORY_COAL select _selectedIndex;
                _currentWater = CRATE_FACTORY_WATER select _selectedIndex;
                _currentMetal = CRATE_FACTORY_METAL select _selectedIndex;
                if (_currentCoal < 100) then {
                    _nearCoalCrates = nearestObjects [_factoryPos, ["Land_PaperBox_closed_F"], 25];
                    if (count _nearCoalCrates > 0) then {
                        deleteVehicle (_nearCoalCrates select 0);
                        _newCoal = (_currentCoal + 25) min 100;
                        CRATE_FACTORY_COAL set [_selectedIndex, _newCoal];
                        systemChat format ["Coal +25%% (%1%%)", round _newCoal];
                        _replenished = true;
                    };
                };
                if (_currentWater < 100) then {
                    _nearWaterCrates = nearestObjects [_factoryPos, ["Land_PaperBox_01_open_water_F"], 25];
                    if (count _nearWaterCrates > 0) then {
                        deleteVehicle (_nearWaterCrates select 0);
                        _newWater = (_currentWater + 25) min 100;
                        CRATE_FACTORY_WATER set [_selectedIndex, _newWater];
                        systemChat format ["Water +25%% (%1%%)", round _newWater];
                        _replenished = true;
                    };
                };
                if (_currentMetal < 100) then {
                    _nearMetalCrates = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 25];
                    if (count _nearMetalCrates > 0) then {
                        deleteVehicle (_nearMetalCrates select 0);
                        _newMetal = (_currentMetal + 25) min 100;
                        CRATE_FACTORY_METAL set [_selectedIndex, _newMetal];
                        systemChat format ["Metal +25%% (%1%%)", round _newMetal];
                        _replenished = true;
                    };
                };
            };
            if (_factoryType == "Vehicle") then {
                _currentElectricity = CRATE_FACTORY_ELECTRICITY select _selectedIndex;
                _currentMetal = CRATE_FACTORY_METAL select _selectedIndex;
                if (_currentElectricity < 100) then {
                    _nearEnergyCrates = nearestObjects [_factoryPos, ["Land_PortableServer_01_sand_F"], 25];
                    if (count _nearEnergyCrates > 0) then {
                        deleteVehicle (_nearEnergyCrates select 0);
                        _newElectricity = (_currentElectricity + 25) min 100;
                        CRATE_FACTORY_ELECTRICITY set [_selectedIndex, _newElectricity];
                        systemChat format ["Electricity +25%% (%1%%)", round _newElectricity];
                        _replenished = true;
                    };
                };
                if (_currentMetal < 100) then {
                    _nearMetalCrates = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 25];
                    if (count _nearMetalCrates > 0) then {
                        deleteVehicle (_nearMetalCrates select 0);
                        _newMetal = (_currentMetal + 25) min 100;
                        CRATE_FACTORY_METAL set [_selectedIndex, _newMetal];
                        systemChat format ["Metal +25%% (%1%%)", round _newMetal];
                        _replenished = true;
                    };
                };
            };
            if (_factoryType == "Mineral" || _factoryType == "Pier") then {
                _currentFood = CRATE_FACTORY_FOOD select _selectedIndex;
                _currentWater = CRATE_FACTORY_WATER select _selectedIndex;
                _currentWood = CRATE_FACTORY_WOOD select _selectedIndex;
                _currentElectricity = CRATE_FACTORY_ELECTRICITY select _selectedIndex;
                _currentMetal = CRATE_FACTORY_METAL select _selectedIndex;
                if (_currentFood < 100) then {
                    _nearFoodCrates = nearestObjects [_factoryPos, ["Land_FoodSacks_01_large_white_idap_F"], 25];
                    if (count _nearFoodCrates > 0) then {
                        deleteVehicle (_nearFoodCrates select 0);
                        _newFood = (_currentFood + 25) min 100;
                        CRATE_FACTORY_FOOD set [_selectedIndex, _newFood];
                        systemChat format ["Food +25%% (%1%%)", round _newFood];
                        _replenished = true;
                    };
                };
                if (_currentWater < 100) then {
                    _nearWaterCrates = nearestObjects [_factoryPos, ["Land_PaperBox_01_open_water_F"], 25];
                    if (count _nearWaterCrates > 0) then {
                        deleteVehicle (_nearWaterCrates select 0);
                        _newWater = (_currentWater + 25) min 100;
                        CRATE_FACTORY_WATER set [_selectedIndex, _newWater];
                        systemChat format ["Water +25%% (%1%%)", round _newWater];
                        _replenished = true;
                    };
                };
                if (_currentWood < 100) then {
                    _nearWoodCrates = nearestObjects [_factoryPos, ["Land_WoodPile_03_F"], 25];
                    if (count _nearWoodCrates > 0) then {
                        deleteVehicle (_nearWoodCrates select 0);
                        _newWood = (_currentWood + 25) min 100;
                        CRATE_FACTORY_WOOD set [_selectedIndex, _newWood];
                        systemChat format ["Wood +25%% (%1%%)", round _newWood];
                        _replenished = true;
                    };
                };
                if (_currentElectricity < 100) then {
                    _nearEnergyCrates = nearestObjects [_factoryPos, ["Land_PortableServer_01_sand_F"], 25];
                    if (count _nearEnergyCrates > 0) then {
                        deleteVehicle (_nearEnergyCrates select 0);
                        _newElectricity = (_currentElectricity + 25) min 100;
                        CRATE_FACTORY_ELECTRICITY set [_selectedIndex, _newElectricity];
                        systemChat format ["Electricity +25%% (%1%%)", round _newElectricity];
                        _replenished = true;
                    };
                };
                if (_currentMetal < 100) then {
                    _nearMetalCrates = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 25];
                    if (count _nearMetalCrates > 0) then {
                        deleteVehicle (_nearMetalCrates select 0);
                        _newMetal = (_currentMetal + 25) min 100;
                        CRATE_FACTORY_METAL set [_selectedIndex, _newMetal];
                        systemChat format ["Metal +25%% (%1%%)", round _newMetal];
                        _replenished = true;
                    };
                };
            };
            if (!_replenished) then {systemChat "No crates or all full!"};
        };
    }];

    _btnStartFactory = _display ctrlCreate ["RscButton", 1026];
    _btnStartFactory ctrlSetPosition [0.68, 0.74, 0.145, 0.035];
    _btnStartFactory ctrlSetText "START";
    _btnStartFactory ctrlSetBackgroundColor [0, 0.5, 0, 1];
    _btnStartFactory ctrlSetFontHeight 0.032;
    _btnStartFactory ctrlCommit 0;

    _btnStartFactory ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        _display = ctrlParent _ctrl;
        if (CRATE_SELECTED_FACTORY < 0) exitWith {systemChat "Select factory!"};
        _selectedIndex = CRATE_SELECTED_FACTORY;
        _needsMaint = CRATE_FACTORY_NEEDS_MAINTENANCE select _selectedIndex;
        if (_needsMaint) exitWith {systemChat "Needs maintenance!"};
        _script = CRATE_SPAWN_SCRIPTS select _selectedIndex;
        if (!isNull _script) exitWith {systemChat "Already running!"};
        _interval = parseNumber (ctrlText (_display displayCtrl 1003));
        _comboType = _display displayCtrl 1009;
        _crateType = _comboType lbData (lbCurSel _comboType);
        if (_crateType == "") exitWith {systemChat "No output!"};
        if (_interval <= 0) exitWith {systemChat "Invalid interval!"};
        CRATE_FACTORY_INTERVALS set [_selectedIndex, _interval];
        CRATE_FACTORY_CRATETYPES set [_selectedIndex, _crateType];
        _factoryPos = CRATE_FACTORY_POSITIONS select _selectedIndex;
        _factoryType = CRATE_FACTORY_TYPES select _selectedIndex;
        _intervalSeconds = _interval * 60;
        _newScript = [_intervalSeconds, _crateType, _factoryPos, _selectedIndex, _factoryType] spawn {
            params ["_intervalSeconds", "_crateType", "_factoryPos", "_factoryIndex", "_factoryType"];
            while {true} do {
                _maintTimer = CRATE_FACTORY_MAINTENANCE_TIMERS select _factoryIndex;
                _maintTimer = _maintTimer - 0.5;
                CRATE_FACTORY_MAINTENANCE_TIMERS set [_factoryIndex, _maintTimer];
                if (_maintTimer <= 0) then {
                    CRATE_FACTORY_NEEDS_MAINTENANCE set [_factoryIndex, true];
                    systemChat format ["Factory %1 needs maintenance!", _factoryIndex + 1];
                    terminate (CRATE_SPAWN_SCRIPTS select _factoryIndex);
                    CRATE_SPAWN_SCRIPTS set [_factoryIndex, scriptNull];
                    CRATE_FACTORY_TIMERS set [_factoryIndex, 0];
                };
                _needsMaint = CRATE_FACTORY_NEEDS_MAINTENANCE select _factoryIndex;
                if (_needsMaint) exitWith {};

                _requestTimer = CRATE_FACTORY_REQUEST_TIMER select _factoryIndex;
                _hasPendingRequest = CRATE_FACTORY_REQUEST_PENDING select _factoryIndex;
                if (!_hasPendingRequest && _requestTimer > 0) then {
                    _requestTimer = _requestTimer - 0.5;
                    CRATE_FACTORY_REQUEST_TIMER set [_factoryIndex, _requestTimer];
                    if (_requestTimer <= 0) then {
                        _totalFactories = count CRATE_FACTORY_TYPES;
                        _outputType = CRATE_FACTORY_CRATETYPES select _factoryIndex;
                        _isRareOutput = false;
                        if (_outputType in ["Land_Boxloader_Fort_iso_Brown", "Land_PaperBox_open_full_F", "Land_CratesWooden_F", "CargoNet_01_barrels_F"]) then {
                            _isRareOutput = true;
                        };
                        _requestChance = if (_isRareOutput) then {0.3} else {0.7};
                        if (random 1 < _requestChance) then {
                            _possibleTypes = ["Food", "Water", "Wood", "Coal", "Metal", "Energy"];
                            _requestType = selectRandom _possibleTypes;
                            _baseAmount = 1 + floor(random 3);
                            _factoryMultiplier = 1 + floor(_totalFactories / 3);
                            _requestAmount = _baseAmount * _factoryMultiplier;
                            CRATE_FACTORY_REQUEST_PENDING set [_factoryIndex, true];
                            CRATE_FACTORY_REQUEST_TYPE set [_factoryIndex, _requestType];
                            CRATE_FACTORY_REQUEST_AMOUNT set [_factoryIndex, _requestAmount];
                            systemChat format ["Factory %1 requests %2x %3!", _factoryIndex + 1, _requestAmount, _requestType];
                        };
                        CRATE_FACTORY_REQUEST_TIMER set [_factoryIndex, (300 + random 600)];
                    };
                };

                if (_hasPendingRequest) then {
                    _currentMorale = CRATE_FACTORY_MORALE select _factoryIndex;
                    _newMorale = (_currentMorale - 0.5) max 0;
                    CRATE_FACTORY_MORALE set [_factoryIndex, _newMorale];
                    if (_newMorale <= 30) then {
                        _fires = CRATE_FACTORY_FIRES select _factoryIndex;
                        if (count _fires == 0) then {
                            _fireCount = 1 + floor(random 3);
                            for "_i" from 1 to _fireCount do {
                                _randomOffset = [random 20 - 10, random 20 - 10, 0];
                                _firePos = _factoryPos vectorAdd _randomOffset;
                                _fire = "#particlesource" createVehicleLocal _firePos;
                                _fire setParticleClass "ObjectDestructionFire1Smallx";
                                _fire setPosATL [_firePos select 0, _firePos select 1, 0.5];
                                _fires pushBack _fire;
                            };
                            CRATE_FACTORY_FIRES set [_factoryIndex, _fires];
                            systemChat format ["Factory %1 morale critical! Fire started!", _factoryIndex + 1];
                        };
                    };
                };

                if (_factoryType == "Town") then {
                    _metal = CRATE_FACTORY_METAL select _factoryIndex;
                    _speedBoost = 1 + (_metal / 100);
                    _adjustedInterval = _intervalSeconds / _speedBoost;
                    _spawnedCrates = CRATE_FACTORY_SPAWNEDCRATES select _factoryIndex;
                    _spawnedCrates = _spawnedCrates select {!isNull _x};
                    CRATE_FACTORY_SPAWNEDCRATES set [_factoryIndex, _spawnedCrates];
                    _maxCrates = CRATE_FACTORY_MAXCRATES select _factoryIndex;
                    _actualCrateCount = count _spawnedCrates;
                    if (_actualCrateCount >= _maxCrates) then {
                        sleep 5;
                    } else {
                        CRATE_FACTORY_TIMERS set [_factoryIndex, _adjustedInterval];
                        for "_tick" from _adjustedInterval to 1 step -1 do {
                            CRATE_FACTORY_TIMERS set [_factoryIndex, _tick];
                            sleep 1;
                        };
                        try {
                            _spawnPos = _factoryPos;
                            for "_attempt" from 0 to 100 do {
                                _randomDistance = random 12;
                                _randomAngle = random 360;
                                _offsetX = _randomDistance * cos _randomAngle;
                                _offsetY = _randomDistance * sin _randomAngle;
                                _testPos = [(_factoryPos select 0) + _offsetX, (_factoryPos select 1) + _offsetY, 0];
                                _nearObjects = nearestObjects [_testPos, [], 1];
                                if (count _nearObjects == 0) then {
                                    _spawnPos = _testPos;
                                    _attempt = 100;
                                };
                            };
                            _crate = _crateType createVehicle _spawnPos;
                            _crate setPos _spawnPos;
                            _spawnedCrates = CRATE_FACTORY_SPAWNEDCRATES select _factoryIndex;
                            _spawnedCrates pushBack _crate;
                            CRATE_FACTORY_SPAWNEDCRATES set [_factoryIndex, _spawnedCrates];
                            _currentCount = CRATE_FACTORY_COUNTS select _factoryIndex;
                            CRATE_FACTORY_COUNTS set [_factoryIndex, _currentCount + 1];
                        } catch {};
                    };
                };
                if (_factoryType == "Powerplant") then {
                    _coal = CRATE_FACTORY_COAL select _factoryIndex;
                    _water = CRATE_FACTORY_WATER select _factoryIndex;
                    _metal = CRATE_FACTORY_METAL select _factoryIndex;
                    _speedBoost = 1 + (_metal / 100);
                    if (_coal <= 0 || _water <= 0) then {
                        sleep 5;
                    } else {
                        _spawnedCrates = CRATE_FACTORY_SPAWNEDCRATES select _factoryIndex;
                        _spawnedCrates = _spawnedCrates select {!isNull _x};
                        CRATE_FACTORY_SPAWNEDCRATES set [_factoryIndex, _spawnedCrates];
                        _maxCrates = CRATE_FACTORY_MAXCRATES select _factoryIndex;
                        _actualCrateCount = count _spawnedCrates;
                        if (_actualCrateCount >= _maxCrates) then {
                            sleep 5;
                        } else {
                            _adjustedInterval = _intervalSeconds / _speedBoost;
                            CRATE_FACTORY_TIMERS set [_factoryIndex, _adjustedInterval];
                            for "_tick" from _adjustedInterval to 1 step -1 do {
                                CRATE_FACTORY_TIMERS set [_factoryIndex, _tick];
                                sleep 1;
                            };
                            try {
                                _spawnPos = _factoryPos;
                                for "_attempt" from 0 to 100 do {
                                    _randomDistance = random 12;
                                    _randomAngle = random 360;
                                    _offsetX = _randomDistance * cos _randomAngle;
                                    _offsetY = _randomDistance * sin _randomAngle;
                                    _testPos = [(_factoryPos select 0) + _offsetX, (_factoryPos select 1) + _offsetY, 0];
                                    _nearObjects = nearestObjects [_testPos, [], 1];
                                    if (count _nearObjects == 0) then {
                                        _spawnPos = _testPos;
                                        _attempt = 100;
                                    };
                                };
                                _crate = _crateType createVehicle _spawnPos;
                                _crate setPos _spawnPos;
                                _spawnedCrates = CRATE_FACTORY_SPAWNEDCRATES select _factoryIndex;
                                _spawnedCrates pushBack _crate;
                                CRATE_FACTORY_SPAWNEDCRATES set [_factoryIndex, _spawnedCrates];
                                _currentCount = CRATE_FACTORY_COUNTS select _factoryIndex;
                                CRATE_FACTORY_COUNTS set [_factoryIndex, _currentCount + 1];
                                _coalConsumption = 5 + random 15;
                                _waterConsumption = 5 + random 15;
                                _metalConsumption = 3 + random 10;
                                _currentCoal = CRATE_FACTORY_COAL select _factoryIndex;
                                _newCoal = (_currentCoal - _coalConsumption) max 0;
                                CRATE_FACTORY_COAL set [_factoryIndex, _newCoal];
                                _currentWater = CRATE_FACTORY_WATER select _factoryIndex;
                                _newWater = (_currentWater - _waterConsumption) max 0;
                                CRATE_FACTORY_WATER set [_factoryIndex, _newWater];
                                _currentMetal = CRATE_FACTORY_METAL select _factoryIndex;
                                _newMetal = (_currentMetal - _metalConsumption) max 0;
                                CRATE_FACTORY_METAL set [_factoryIndex, _newMetal];
                            } catch {};
                        };
                    };
                };
                if (_factoryType == "Vehicle") then {
                    _electricity = CRATE_FACTORY_ELECTRICITY select _factoryIndex;
                    _metal = CRATE_FACTORY_METAL select _factoryIndex;
                    if (_electricity <= 0 || _metal <= 0) then {
                        sleep 5;
                    } else {
                        _spawnedCrates = CRATE_FACTORY_SPAWNEDCRATES select _factoryIndex;
                        _spawnedCrates = _spawnedCrates select {!isNull _x};
                        CRATE_FACTORY_SPAWNEDCRATES set [_factoryIndex, _spawnedCrates];
                        _maxCrates = CRATE_FACTORY_MAXCRATES select _factoryIndex;
                        _actualCrateCount = count _spawnedCrates;
                        if (_actualCrateCount >= _maxCrates) then {
                            sleep 5;
                        } else {
                            CRATE_FACTORY_TIMERS set [_factoryIndex, _intervalSeconds];
                            for "_tick" from _intervalSeconds to 1 step -1 do {
                                CRATE_FACTORY_TIMERS set [_factoryIndex, _tick];
                                sleep 1;
                            };
                            _electricityConsumption = 5 + random 15;
                            _metalConsumption = 5 + random 15;
                            _currentElectricity = CRATE_FACTORY_ELECTRICITY select _factoryIndex;
                            _newElectricity = (_currentElectricity - _electricityConsumption) max 0;
                            CRATE_FACTORY_ELECTRICITY set [_factoryIndex, _newElectricity];
                            _currentMetal = CRATE_FACTORY_METAL select _factoryIndex;
                            _newMetal = (_currentMetal - _metalConsumption) max 0;
                            CRATE_FACTORY_METAL set [_factoryIndex, _newMetal];
                            _currentCount = CRATE_FACTORY_COUNTS select _factoryIndex;
                            CRATE_FACTORY_COUNTS set [_factoryIndex, _currentCount + 1];
                        };
                    };
                };
                if (_factoryType == "Mineral" || _factoryType == "Pier") then {
                    _food = CRATE_FACTORY_FOOD select _factoryIndex;
                    _water = CRATE_FACTORY_WATER select _factoryIndex;
                    _wood = CRATE_FACTORY_WOOD select _factoryIndex;
                    _electricity = CRATE_FACTORY_ELECTRICITY select _factoryIndex;
                    _metal = CRATE_FACTORY_METAL select _factoryIndex;
                    if (_food <= 0 || _water <= 0 || _wood <= 0) then {
                        sleep 5;
                    } else {
                        _spawnedCrates = CRATE_FACTORY_SPAWNEDCRATES select _factoryIndex;
                        _spawnedCrates = _spawnedCrates select {!isNull _x};
                        CRATE_FACTORY_SPAWNEDCRATES set [_factoryIndex, _spawnedCrates];
                        _maxCrates = CRATE_FACTORY_MAXCRATES select _factoryIndex;
                        _actualCrateCount = count _spawnedCrates;
                        if (_actualCrateCount >= _maxCrates) then {
                            sleep 5;
                        } else {
                            _combinedBoost = 1 + ((_electricity + _metal) / 200);
                            _adjustedInterval = _intervalSeconds / _combinedBoost;
                            CRATE_FACTORY_TIMERS set [_factoryIndex, _adjustedInterval];
                            for "_tick" from _adjustedInterval to 1 step -1 do {
                                CRATE_FACTORY_TIMERS set [_factoryIndex, _tick];
                                sleep 1;
                            };
                            try {
                                _spawnPos = _factoryPos;
                                for "_attempt" from 0 to 100 do {
                                    _randomDistance = random 12;
                                    _randomAngle = random 360;
                                    _offsetX = _randomDistance * cos _randomAngle;
                                    _offsetY = _randomDistance * sin _randomAngle;
                                    _testPos = [(_factoryPos select 0) + _offsetX, (_factoryPos select 1) + _offsetY, 0];
                                    _nearObjects = nearestObjects [_testPos, [], 1];
                                    if (count _nearObjects == 0) then {
                                        _spawnPos = _testPos;
                                        _attempt = 100;
                                    };
                                };
                                _crate = _crateType createVehicle _spawnPos;
                                _crate setPos _spawnPos;
                                _spawnedCrates = CRATE_FACTORY_SPAWNEDCRATES select _factoryIndex;
                                _spawnedCrates pushBack _crate;
                                CRATE_FACTORY_SPAWNEDCRATES set [_factoryIndex, _spawnedCrates];
                                _currentCount = CRATE_FACTORY_COUNTS select _factoryIndex;
                                CRATE_FACTORY_COUNTS set [_factoryIndex, _currentCount + 1];
                                _foodConsumption = 5 + random 15;
                                _waterConsumption = 5 + random 15;
                                _woodConsumption = 5 + random 15;
                                _currentFood = CRATE_FACTORY_FOOD select _factoryIndex;
                                _newFood = (_currentFood - _foodConsumption) max 0;
                                CRATE_FACTORY_FOOD set [_factoryIndex, _newFood];
                                _currentWater = CRATE_FACTORY_WATER select _factoryIndex;
                                _newWater = (_currentWater - _waterConsumption) max 0;
                                CRATE_FACTORY_WATER set [_factoryIndex, _newWater];
                                _currentWood = CRATE_FACTORY_WOOD select _factoryIndex;
                                _newWood = (_currentWood - _woodConsumption) max 0;
                                CRATE_FACTORY_WOOD set [_factoryIndex, _newWood];
                            } catch {};
                        };
                    };
                };
                sleep 0.5;
            };
        };
        CRATE_SPAWN_SCRIPTS set [_selectedIndex, _newScript];
        systemChat "Factory started!";
    }];

    _btnStopFactory = _display ctrlCreate ["RscButton", 1027];
    _btnStopFactory ctrlSetPosition [0.835, 0.74, 0.145, 0.035];
    _btnStopFactory ctrlSetText "STOP";
    _btnStopFactory ctrlSetBackgroundColor [0.5, 0, 0, 1];
    _btnStopFactory ctrlSetFontHeight 0.032;
    _btnStopFactory ctrlCommit 0;

    _btnStopFactory ctrlAddEventHandler ["ButtonClick", {
        if (CRATE_SELECTED_FACTORY < 0) exitWith {systemChat "Select factory!"};
        _selectedIndex = CRATE_SELECTED_FACTORY;
        _script = CRATE_SPAWN_SCRIPTS select _selectedIndex;
        if (!isNull _script) then {
            terminate _script;
            CRATE_SPAWN_SCRIPTS set [_selectedIndex, scriptNull];
            CRATE_FACTORY_TIMERS set [_selectedIndex, 0];
            systemChat "Factory stopped!";
        };
    }];

    _btnDelete = _display ctrlCreate ["RscButton", 1019];
    _btnDelete ctrlSetPosition [0.68, 0.78, 0.30, 0.035];
    _btnDelete ctrlSetText "DELETE SELECTED";
    _btnDelete ctrlSetBackgroundColor [0.5, 0.2, 0, 1];
    _btnDelete ctrlSetFontHeight 0.032;
    _btnDelete ctrlCommit 0;

    _btnDelete ctrlAddEventHandler ["ButtonClick", {
        if (CRATE_SELECTED_FACTORY < 0) exitWith {systemChat "Select factory!"};
        _selectedIndex = CRATE_SELECTED_FACTORY;
        _script = CRATE_SPAWN_SCRIPTS select _selectedIndex;
        if (!isNull _script) then {terminate _script};
        _fires = CRATE_FACTORY_FIRES select _selectedIndex;
        {deleteVehicle _x} forEach _fires;
        CRATE_SPAWN_SCRIPTS deleteAt _selectedIndex;
        CRATE_FACTORY_POSITIONS deleteAt _selectedIndex;
        CRATE_FACTORY_COUNTS deleteAt _selectedIndex;
        CRATE_FACTORY_TIMERS deleteAt _selectedIndex;
        CRATE_FACTORY_TYPES deleteAt _selectedIndex;
        CRATE_FACTORY_INTERVALS deleteAt _selectedIndex;
        CRATE_FACTORY_CRATETYPES deleteAt _selectedIndex;
        CRATE_FACTORY_MAXCRATES deleteAt _selectedIndex;
        CRATE_FACTORY_SUPPLIES deleteAt _selectedIndex;
        CRATE_FACTORY_SPAWNEDCRATES deleteAt _selectedIndex;
        CRATE_FACTORY_FOOD deleteAt _selectedIndex;
        CRATE_FACTORY_WATER deleteAt _selectedIndex;
        CRATE_FACTORY_ELECTRICITY deleteAt _selectedIndex;
        CRATE_FACTORY_METAL deleteAt _selectedIndex;
        CRATE_FACTORY_WOOD deleteAt _selectedIndex;
        CRATE_FACTORY_COAL deleteAt _selectedIndex;
        CRATE_FACTORY_MAINTENANCE_TIMERS deleteAt _selectedIndex;
        CRATE_FACTORY_NEEDS_MAINTENANCE deleteAt _selectedIndex;
        CRATE_FACTORY_FIRES deleteAt _selectedIndex;
        CRATE_FACTORY_MORALE deleteAt _selectedIndex;
        CRATE_FACTORY_REQUEST_PENDING deleteAt _selectedIndex;
        CRATE_FACTORY_REQUEST_TYPE deleteAt _selectedIndex;
        CRATE_FACTORY_REQUEST_AMOUNT deleteAt _selectedIndex;
        CRATE_FACTORY_REQUEST_TIMER deleteAt _selectedIndex;
        CRATE_SELECTED_FACTORY = -1;
        systemChat "Factory deleted!";
    }];

    _labelInterval = _display ctrlCreate ["RscText", 1002];
    _labelInterval ctrlSetPosition [0.68, 0.82, 0.30, 0.025];
    _labelInterval ctrlSetText "Interval (minutes):";
    _labelInterval ctrlSetFontHeight 0.032;
    _labelInterval ctrlCommit 0;

    _inputInterval = _display ctrlCreate ["RscEdit", 1003];
    _inputInterval ctrlSetPosition [0.68, 0.845, 0.30, 0.035];
    _inputInterval ctrlSetText "60";
    _inputInterval ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
    _inputInterval ctrlSetFontHeight 0.032;
    _inputInterval ctrlCommit 0;

    _labelType = _display ctrlCreate ["RscText", 1008];
    _labelType ctrlSetPosition [0.68, 0.885, 0.30, 0.022];
    _labelType ctrlSetText "Output Type:";
    _labelType ctrlSetFontHeight 0.03;
    _labelType ctrlCommit 0;

    _comboType = _display ctrlCreate ["RscCombo", 1009];
    _comboType ctrlSetPosition [0.68, 0.907, 0.30, 0.035];
    _comboType lbAdd "Select Factory First";
    _comboType lbSetData [0, ""];
    _comboType lbSetCurSel 0;
    _comboType ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
    _comboType ctrlSetFontHeight 0.03;
    _comboType ctrlCommit 0;

    _btnStopAll = _display ctrlCreate ["RscButton", 1028];
    _btnStopAll ctrlSetPosition [0.0, 0.94, 0.215, 0.035];
    _btnStopAll ctrlSetText "STOP ALL";
    _btnStopAll ctrlSetBackgroundColor [0.6, 0, 0, 1];
    _btnStopAll ctrlSetFontHeight 0.032;
    _btnStopAll ctrlCommit 0;

    _btnStopAll ctrlAddEventHandler ["ButtonClick", {
        {if (!isNull _x) then {terminate _x}} forEach CRATE_SPAWN_SCRIPTS;
        for "_i" from 0 to ((count CRATE_SPAWN_SCRIPTS) - 1) do {
            CRATE_SPAWN_SCRIPTS set [_i, scriptNull];
            CRATE_FACTORY_TIMERS set [_i, 0];
        };
        systemChat "All stopped!";
    }];

    _btnClearAll = _display ctrlCreate ["RscButton", 1018];
    _btnClearAll ctrlSetPosition [0.2175, 0.94, 0.215, 0.035];
    _btnClearAll ctrlSetText "CLEAR ALL";
    _btnClearAll ctrlSetBackgroundColor [0.3, 0.3, 0, 1];
    _btnClearAll ctrlSetFontHeight 0.032;
    _btnClearAll ctrlCommit 0;

    _btnClearAll ctrlAddEventHandler ["ButtonClick", {
        {if (!isNull _x) then {terminate _x}} forEach CRATE_SPAWN_SCRIPTS;
        {
            _fires = _x;
            {deleteVehicle _x} forEach _fires;
        } forEach CRATE_FACTORY_FIRES;
        CRATE_FACTORY_POSITIONS = [];
        CRATE_FACTORY_COUNTS = [];
        CRATE_FACTORY_TIMERS = [];
        CRATE_SPAWN_SCRIPTS = [];
        CRATE_FACTORY_TYPES = [];
        CRATE_PENDING_LOCATION = [];
        CRATE_FACTORY_INTERVALS = [];
        CRATE_FACTORY_CRATETYPES = [];
        CRATE_FACTORY_MAXCRATES = [];
        CRATE_FACTORY_SUPPLIES = [];
        CRATE_FACTORY_SPAWNEDCRATES = [];
        CRATE_FACTORY_FOOD = [];
        CRATE_FACTORY_WATER = [];
        CRATE_FACTORY_ELECTRICITY = [];
        CRATE_FACTORY_METAL = [];
        CRATE_FACTORY_WOOD = [];
        CRATE_FACTORY_COAL = [];
        CRATE_FACTORY_MAINTENANCE_TIMERS = [];
        CRATE_FACTORY_NEEDS_MAINTENANCE = [];
        CRATE_FACTORY_FIRES = [];
        CRATE_FACTORY_MORALE = [];
        CRATE_FACTORY_REQUEST_PENDING = [];
        CRATE_FACTORY_REQUEST_TYPE = [];
        CRATE_FACTORY_REQUEST_AMOUNT = [];
        CRATE_FACTORY_REQUEST_TIMER = [];
        CRATE_SELECTED_FACTORY = -1;
        systemChat "All cleared!";
    }];

    _btnClose = _display ctrlCreate ["RscButton", 1013];
    _btnClose ctrlSetPosition [0.435, 0.94, 0.215, 0.035];
    _btnClose ctrlSetText "CLOSE";
    _btnClose ctrlSetFontHeight 0.032;
    _btnClose ctrlCommit 0;

    _btnClose ctrlAddEventHandler ["ButtonClick", {closeDialog 0}];

    [_display] spawn {
        params ["_display"];
        _lastSelectedFactory = -2;
        while {!isNull _display} do {
            _selectedIndex = CRATE_SELECTED_FACTORY;
            _infoBox = _display displayCtrl 1050;
            _comboType = _display displayCtrl 1009;
            _inputInterval = _display displayCtrl 1003;
            _labelCost = _display displayCtrl 1051;
            if (_selectedIndex >= 0 && _selectedIndex < count CRATE_FACTORY_POSITIONS) then {
                _factoryType = CRATE_FACTORY_TYPES select _selectedIndex;
                _crateCount = CRATE_FACTORY_COUNTS select _selectedIndex;
                _maxCrates = CRATE_FACTORY_MAXCRATES select _selectedIndex;
                _food = CRATE_FACTORY_FOOD select _selectedIndex;
                _water = CRATE_FACTORY_WATER select _selectedIndex;
                _electricity = CRATE_FACTORY_ELECTRICITY select _selectedIndex;
                _metal = CRATE_FACTORY_METAL select _selectedIndex;
                _wood = CRATE_FACTORY_WOOD select _selectedIndex;
                _coal = CRATE_FACTORY_COAL select _selectedIndex;
                _needsMaint = CRATE_FACTORY_NEEDS_MAINTENANCE select _selectedIndex;
                _timeRemaining = CRATE_FACTORY_TIMERS select _selectedIndex;
                _script = CRATE_SPAWN_SCRIPTS select _selectedIndex;
                _currentInterval = CRATE_FACTORY_INTERVALS select _selectedIndex;
                _currentCrateType = CRATE_FACTORY_CRATETYPES select _selectedIndex;
                _morale = CRATE_FACTORY_MORALE select _selectedIndex;
                _hasPendingRequest = CRATE_FACTORY_REQUEST_PENDING select _selectedIndex;
                _requestType = CRATE_FACTORY_REQUEST_TYPE select _selectedIndex;
                _requestAmount = CRATE_FACTORY_REQUEST_AMOUNT select _selectedIndex;

                _status = if (isNull _script) then {"<t color='#888'>OFF</t>"} else {"<t color='#0f0'>ON</t>"};
                if (_needsMaint) then {_status = "<t color='#f00'>MAINT</t>"};
                _timerDisplay = "";
                if (_timeRemaining > 0) then {
                    _m = floor (_timeRemaining / 60);
                    _s = _timeRemaining mod 60;
                    _timerDisplay = format ["<br/>Next: %1:%2", if (_m < 10) then {"0" + str _m} else {str _m}, if (_s < 10) then {"0" + str _s} else {str _s}];
                };
                _typeColor = "#0f0";
                if (_factoryType == "Town") then {_typeColor = "#08f"};
                if (_factoryType == "Powerplant") then {_typeColor = "#f80"};
                if (_factoryType == "Vehicle") then {_typeColor = "#80f"};
                if (_factoryType == "Pier") then {_typeColor = "#0cc"};

                _moraleText = "Good";
                _moraleColor = "#0f0";
                if (_morale < 70) then {_moraleText = "OK"; _moraleColor = "#ff0"};
                if (_morale < 40) then {_moraleText = "Low"; _moraleColor = "#f80"};
                if (_morale < 30) then {_moraleText = "Bad"; _moraleColor = "#f00"};

                _requestText = "";
                if (_hasPendingRequest) then {
                    _requestText = format ["<br/><t color='#f00'>REQ: %1x %2</t>", _requestAmount, _requestType];
                };

                _infoText = format ["<t size='1.2' color='%4'>%1 #%2</t><br/>%3<br/>Crates: %5/%6<br/>Morale: <t color='%8'>%7</t>%9%10", _factoryType, _selectedIndex + 1, _status, _typeColor, _crateCount, _maxCrates, _moraleText, _moraleColor, _requestText, _timerDisplay];
                _infoBox ctrlSetStructuredText parseText _infoText;
                if (_lastSelectedFactory != _selectedIndex) then {
                    _inputInterval ctrlSetText str _currentInterval;
                    _lastSelectedFactory = _selectedIndex;
                };
                _needsRebuild = true;
                if (lbSize _comboType > 0) then {
                    _firstItem = _comboType lbText 0;
                    if (_factoryType == "Town" && (_firstItem == "Food")) then {_needsRebuild = false};
                    if (_factoryType == "Powerplant" && (_firstItem == "Energy")) then {_needsRebuild = false};
                    if (_factoryType == "Vehicle" && (_firstItem == "Small Fuel Tank")) then {_needsRebuild = false};
                    if (_factoryType == "Mineral" && (_firstItem == "Coal (45min)")) then {_needsRebuild = false};
                    if (_factoryType == "Pier" && (_firstItem == "Fish (15min)")) then {_needsRebuild = false};
                };
                if (_needsRebuild) then {
                    lbClear _comboType;
                    if (_factoryType == "Town") then {
                        _comboType lbAdd "Food";
                        _comboType lbSetData [0, "Land_FoodSacks_01_large_white_idap_F"];
                        _comboType lbAdd "Water";
                        _comboType lbSetData [1, "Land_PaperBox_01_open_water_F"];
                        _comboType lbAdd "Wood";
                        _comboType lbSetData [2, "Land_WoodPile_03_F"];
                    };
                    if (_factoryType == "Powerplant") then {
                        _comboType lbAdd "Energy";
                        _comboType lbSetData [0, "Land_PortableServer_01_sand_F"];
                        _comboType lbAdd "Electronics";
                        _comboType lbSetData [1, "Land_PaperBox_01_open_boxes_F"];
                    };
                    if (_factoryType == "Vehicle") then {
                        _comboType lbAdd "Small Fuel Tank";
                        _comboType lbSetData [0, "Land_CanisterFuel_F"];
                        _comboType lbAdd "Wheel";
                        _comboType lbSetData [1, "Land_Wheel_01_F"];
                        _comboType lbAdd "Engine Part";
                        _comboType lbSetData [2, "Land_MetalBarrel_F"];
                    };
                    if (_factoryType == "Mineral") then {
                        _comboType lbAdd "Coal (45min)";
                        _comboType lbSetData [0, "Land_PaperBox_closed_F"];
                        _comboType lbAdd "Metal (60min)";
                        _comboType lbSetData [1, "Land_CargoBox_V1_F"];
                        _comboType lbAdd "Iron (90min)";
                        _comboType lbSetData [2, "Land_PaperBox_open_full_F"];
                        _comboType lbAdd "Diamonds (120min)";
                        _comboType lbSetData [3, "Land_Boxloader_Fort_iso_Brown"];
                    };
                    if (_factoryType == "Pier") then {
                        _comboType lbAdd "Fish (15min)";
                        _comboType lbSetData [0, "Land_WoodenBox_02_F"];
                        _comboType lbAdd "Oil (45min)";
                        _comboType lbSetData [1, "CargoNet_01_barrels_F"];
                        _comboType lbAdd "Gold (90min)";
                        _comboType lbSetData [2, "Land_CratesWooden_F"];
                    };
                    if (_currentCrateType != "") then {
                        _foundIndex = -1;
                        for "_i" from 0 to ((lbSize _comboType) - 1) do {
                            if ((_comboType lbData _i) == _currentCrateType) then {_foundIndex = _i};
                        };
                        if (_foundIndex >= 0) then {_comboType lbSetCurSel _foundIndex} else {_comboType lbSetCurSel 0};
                    } else {
                        _comboType lbSetCurSel 0;
                    };
                };
                _labelCost ctrlSetStructuredText parseText "";
                _supplyBar = _display displayCtrl 1030;
                _supplyLabel = _display displayCtrl 1031;
                (_display displayCtrl 1033) ctrlShow false;
                (_display displayCtrl 1034) ctrlShow false;
                (_display displayCtrl 1035) ctrlShow false;
                (_display displayCtrl 1038) ctrlShow false;
                (_display displayCtrl 1039) ctrlShow false;
                (_display displayCtrl 1040) ctrlShow false;
                (_display displayCtrl 1041) ctrlShow false;
                (_display displayCtrl 1042) ctrlShow false;
                (_display displayCtrl 1043) ctrlShow false;
                (_display displayCtrl 1044) ctrlShow false;
                (_display displayCtrl 1045) ctrlShow false;
                (_display displayCtrl 1046) ctrlShow false;
                if (_factoryType == "Town") then {
                    _barWidth = 0.30 * (_metal / 100);
                    _supplyBar ctrlSetPosition [0.68, 0.505, _barWidth, 0.022];
                    _supplyBar ctrlSetBackgroundColor [0.6, 0.6, 0.7, 1];
                    _supplyBar ctrlCommit 0;
                    _supplyLabel ctrlSetText format ["Metal (Boost): %1%% (x%2)", round _metal, (1 + (_metal / 100)) toFixed 1];
                };
                if (_factoryType == "Powerplant") then {
                    _barWidth = 0.30 * (_coal / 100);
                    _supplyBar ctrlSetPosition [0.68, 0.505, _barWidth, 0.022];
                    _supplyBar ctrlSetBackgroundColor [0.3, 0.3, 0.3, 1];
                    _supplyBar ctrlCommit 0;
                    _supplyLabel ctrlSetText format ["Coal: %1%%", round _coal];
                    _waterLabel = _display displayCtrl 1035;
                    _waterBar = _display displayCtrl 1034;
                    _waterBarBg = _display displayCtrl 1033;
                    _waterBarWidth = 0.30 * (_water / 100);
                    _waterBar ctrlSetPosition [0.68, 0.555, _waterBarWidth, 0.022];
                    _waterBar ctrlSetBackgroundColor [0, 0.5, 1, 1];
                    _waterBar ctrlCommit 0;
                    _waterLabel ctrlSetText format ["Water: %1%%", round _water];
                    _waterLabel ctrlShow true;
                    _waterBarBg ctrlShow true;
                    _waterBar ctrlShow true;
                    _metalLabel = _display displayCtrl 1041;
                    _metalBar = _display displayCtrl 1042;
                    _metalBarBg = _display displayCtrl 1043;
                    _metalBarWidth = 0.30 * (_metal / 100);
                    _metalBar ctrlSetPosition [0.68, 0.605, _metalBarWidth, 0.022];
                    _metalBar ctrlSetBackgroundColor [0.6, 0.6, 0.7, 1];
                    _metalBar ctrlCommit 0;
                    _metalLabel ctrlSetText format ["Metal (Boost): %1%% (x%2)", round _metal, (1 + (_metal / 100)) toFixed 1];
                    _metalLabel ctrlShow true;
                    _metalBarBg ctrlShow true;
                    _metalBar ctrlShow true;
                };
                if (_factoryType == "Vehicle") then {
                    _barWidth = 0.30 * (_electricity / 100);
                    _supplyBar ctrlSetPosition [0.68, 0.505, _barWidth, 0.022];
                    _supplyBar ctrlSetBackgroundColor [1, 1, 0, 1];
                    _supplyBar ctrlCommit 0;
                    _supplyLabel ctrlSetText format ["Electricity: %1%%", round _electricity];
                    _metalLabel = _display displayCtrl 1041;
                    _metalBar = _display displayCtrl 1042;
                    _metalBarBg = _display displayCtrl 1043;
                    _metalBarWidth = 0.30 * (_metal / 100);
                    _metalBar ctrlSetPosition [0.68, 0.555, _metalBarWidth, 0.022];
                    _metalBar ctrlSetBackgroundColor [0.6, 0.6, 0.7, 1];
                    _metalBar ctrlCommit 0;
                    _metalLabel ctrlSetText format ["Metal: %1%%", round _metal];
                    _metalLabel ctrlShow true;
                    _metalBarBg ctrlShow true;
                    _metalBar ctrlShow true;
                };
                if (_factoryType == "Mineral" || _factoryType == "Pier") then {
                    _barWidth = 0.30 * (_food / 100);
                    _supplyBar ctrlSetPosition [0.68, 0.505, _barWidth, 0.022];
                    _supplyBar ctrlSetBackgroundColor [0, 0.8, 0, 1];
                    _supplyBar ctrlCommit 0;
                    _supplyLabel ctrlSetText format ["Food: %1%%", round _food];
                    _waterLabel = _display displayCtrl 1035;
                    _waterBar = _display displayCtrl 1034;
                    _waterBarBg = _display displayCtrl 1033;
                    _waterBarWidth = 0.30 * (_water / 100);
                    _waterBar ctrlSetPosition [0.68, 0.555, _waterBarWidth, 0.022];
                    _waterBar ctrlSetBackgroundColor [0, 0.5, 1, 1];
                    _waterBar ctrlCommit 0;
                    _waterLabel ctrlSetText format ["Water: %1%%", round _water];
                    _waterLabel ctrlShow true;
                    _waterBarBg ctrlShow true;
                    _waterBar ctrlShow true;
                    _woodLabel = _display displayCtrl 1044;
                    _woodBar = _display displayCtrl 1045;
                    _woodBarBg = _display displayCtrl 1046;
                    _woodBarWidth = 0.30 * (_wood / 100);
                    _woodBar ctrlSetPosition [0.68, 0.605, _woodBarWidth, 0.022];
                    _woodBar ctrlSetBackgroundColor [0.6, 0.4, 0.2, 1];
                    _woodBar ctrlCommit 0;
                    _woodLabel ctrlSetText format ["Wood: %1%%", round _wood];
                    _woodLabel ctrlShow true;
                    _woodBarBg ctrlShow true;
                    _woodBar ctrlShow true;
                    _metalLabel = _display displayCtrl 1041;
                    _metalBar = _display displayCtrl 1042;
                    _metalBarBg = _display displayCtrl 1043;
                    _metalBarWidth = 0.30 * (_metal / 100);
                    _metalBar ctrlSetPosition [0.68, 0.655, _metalBarWidth, 0.022];
                    _metalBar ctrlSetBackgroundColor [0.6, 0.6, 0.7, 1];
                    _metalBar ctrlCommit 0;
                    if (_factoryType == "Pier") then {
                        _metalLabel ctrlSetText format ["Metal: %1%%", round _metal];
                    } else {
                        _metalLabel ctrlSetText format ["Metal (Boost): %1%%", round _metal];
                    };
                    _metalLabel ctrlShow true;
                    _metalBarBg ctrlShow true;
                    _metalBar ctrlShow true;
                    _electricityLabel = _display displayCtrl 1038;
                    _electricityBar = _display displayCtrl 1040;
                    _electricityBarBg = _display displayCtrl 1039;
                    _electricityBarWidth = 0.30 * (_electricity / 100);
                    _electricityBar ctrlSetPosition [0.68, 0.705, _electricityBarWidth, 0.022];
                    _electricityBar ctrlSetBackgroundColor [1, 1, 0, 1];
                    _electricityBar ctrlCommit 0;
                    _combinedBoost = 1 + ((_electricity + _metal) / 200);
                    _electricityLabel ctrlSetText format ["Elec (Boost): %1%% (x%2)", round _electricity, _combinedBoost toFixed 1];
                    _electricityLabel ctrlShow true;
                    _electricityBarBg ctrlShow true;
                    _electricityBar ctrlShow true;
                };
            } else {
                _infoBox ctrlSetStructuredText parseText "<t size='1.2'>No Factory</t><br/><br/>Click factory<br/>or click empty area";
                _inputInterval ctrlSetText "60";
                lbClear _comboType;
                _comboType lbAdd "Select Factory First";
                _comboType lbSetData [0, ""];
                _comboType lbSetCurSel 0;
                if (count CRATE_PENDING_LOCATION > 0) then {
                    _comboFactoryType = _display displayCtrl 1024;
                    _factoryType = _comboFactoryType lbData (lbCurSel _comboFactoryType);
                    if (_factoryType == "Town") then {
                        _townCount = {_x == "Town"} count CRATE_FACTORY_TYPES;
                        if (_townCount == 0) then {
                            _labelCost ctrlSetStructuredText parseText "<t size='1.0' color='#0f0'>FREE!</t>";
                        } else {
                            _houseCount = count (nearestObjects [CRATE_PENDING_LOCATION, ["House"], 400]);
                            _foodCost = 2 * _townCount;
                            _waterCost = 3 * _townCount;
                            _metalCost = 0;
                            _houseCostMultiplier = 1 + ((_houseCount / 10) * 0.1);
                            _foodCost = ceil (_foodCost * _houseCostMultiplier);
                            _waterCost = ceil (_waterCost * _houseCostMultiplier);
                            if (_houseCount >= 100) then {_metalCost = 2 + floor(_houseCount / 50)};
                            if (_metalCost > 0) then {
                                _costText = format ["<t size='0.9'>Cost:<br/>%1x Food<br/>%2x Water<br/>%3x Metal<br/><t size='0.8' color='#888'>Houses: %4</t></t>", _foodCost, _waterCost, _metalCost, _houseCount];
                            } else {
                                _costText = format ["<t size='0.9'>Cost:<br/>%1x Food<br/>%2x Water<br/><t size='0.8' color='#888'>Houses: %3</t></t>", _foodCost, _waterCost, _houseCount];
                            };
                            _labelCost ctrlSetStructuredText parseText _costText;
                        };
                    } else {
                        if (_factoryType == "Mineral") then {
                            _mineralCount = {_x == "Mineral"} count CRATE_FACTORY_TYPES;
                            _foodCost = 5 + (5 * _mineralCount);
                            _waterCost = 5 + (5 * _mineralCount);
                            _woodCost = 5 + (5 * _mineralCount);
                            _costText = format ["<t size='0.9'>Cost:<br/>%1x Food<br/>%2x Water<br/>%3x Wood</t>", _foodCost, _waterCost, _woodCost];
                            _labelCost ctrlSetStructuredText parseText _costText;
                        } else {
                            if (_factoryType == "Powerplant") then {
                                _powerCount = {_x == "Powerplant"} count CRATE_FACTORY_TYPES;
                                _coalCost = 4 + (4 * _powerCount);
                                _metalCost = 3 + (3 * _powerCount);
                                _costText = format ["<t size='0.9'>Cost:<br/>%1x Coal<br/>%2x Metal</t>", _coalCost, _metalCost];
                                _labelCost ctrlSetStructuredText parseText _costText;
                            } else {
                                if (_factoryType == "Vehicle") then {
                                    _vehicleCount = {_x == "Vehicle"} count CRATE_FACTORY_TYPES;
                                    _energyCost = 5 + (5 * _vehicleCount);
                                    _metalCost = 5 + (5 * _vehicleCount);
                                    _costText = format ["<t size='0.9'>Cost:<br/>%1x Energy<br/>%2x Metal</t>", _energyCost, _metalCost];
                                    _labelCost ctrlSetStructuredText parseText _costText;
                                } else {
                                    if (_factoryType == "Pier") then {
                                        _pierCount = {_x == "Pier"} count CRATE_FACTORY_TYPES;
                                        _foodCost = 3 + (3 * _pierCount);
                                        _waterCost = 5 + (5 * _pierCount);
                                        _woodCost = 7 + (7 * _pierCount);
                                        _costText = format ["<t size='0.9'>Cost:<br/>%1x Food<br/>%2x Water<br/>%3x Wood</t>", _foodCost, _waterCost, _woodCost];
                                        _labelCost ctrlSetStructuredText parseText _costText;
                                    } else {
                                        _labelCost ctrlSetStructuredText parseText "<t size='1.0' color='#0f0'>FREE</t>";
                                    };
                                };
                            };
                        };
                    };
                } else {
                    _labelCost ctrlSetStructuredText parseText "";
                };
                _lastSelectedFactory = -2;
            };
            sleep 0.5;
        };
    };
}];

systemChat "Crate Spawner action added!";