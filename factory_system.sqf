// Factory Manager - v6 FIXED - Task Tracking + Hover Info + Morale System
player addAction ["Open Crate Spawner", {
    createDialog "RscDisplayEmpty";
    _display = findDisplay -1;

    _bg = _display ctrlCreate ["RscText", 1000];
    _bg ctrlSetPosition [0.0, 0.0, 1.0, 1.0];
    _bg ctrlSetBackgroundColor [0, 0, 0, 0.8];
    _bg ctrlCommit 0;

    _title = _display ctrlCreate ["RscText", 1001];
    _title ctrlSetPosition [0.0, 0.0, 1.0, 0.06];
    _title ctrlSetText "Factory Manager - Click to Place/Select | Hover for Info";
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
    if (isNil "CRATE_FACTORY_TASK_PENDING") then {CRATE_FACTORY_TASK_PENDING = []};
    if (isNil "CRATE_FACTORY_TASK_TYPE") then {CRATE_FACTORY_TASK_TYPE = []};
    if (isNil "CRATE_FACTORY_TASK_ID") then {CRATE_FACTORY_TASK_ID = []};
    if (isNil "CRATE_FACTORY_TASK_TIMER") then {CRATE_FACTORY_TASK_TIMER = []};
    if (isNil "CRATE_FACTORY_TASK_MIN_TIME") then {CRATE_FACTORY_TASK_MIN_TIME = []};
    if (isNil "CRATE_FACTORY_TASK_MAX_TIME") then {CRATE_FACTORY_TASK_MAX_TIME = []};
    if (isNil "CRATE_FACTORY_TASK_START_TIME") then {CRATE_FACTORY_TASK_START_TIME = []};
    if (isNil "CRATE_FACTORY_OPFOR_SPAWNED") then {CRATE_FACTORY_OPFOR_SPAWNED = []};
    if (isNil "CRATE_MOUSE_POS") then {CRATE_MOUSE_POS = []};
    if (isNil "CRATE_FACTORY_LEVEL") then {CRATE_FACTORY_LEVEL = []};

    _map ctrlAddEventHandler ["MouseMoving", {
        params ["_control", "_xPos", "_yPos"];
        CRATE_MOUSE_POS = [_xPos, _yPos];

        _hoveredFactory = -1;
        {
            _factoryScreenPos = _control ctrlMapWorldToScreen _x;
            if (count _factoryScreenPos > 0) then {
                _factoryX = _factoryScreenPos select 0;
                _factoryY = _factoryScreenPos select 1;
                _dist = sqrt (((_factoryX - _xPos) ^ 2) + ((_factoryY - _yPos) ^ 2));
                if (_dist < 0.075) then {
                    _hoveredFactory = _forEachIndex;
                };
            };
        } forEach CRATE_FACTORY_POSITIONS;

        if (isNil "CRATE_HOVERED_FACTORY") then {CRATE_HOVERED_FACTORY = -1};
        CRATE_HOVERED_FACTORY = _hoveredFactory;

        if (_hoveredFactory >= 0) then {
            _factoryType = CRATE_FACTORY_TYPES select _hoveredFactory;
            _morale = CRATE_FACTORY_MORALE select _hoveredFactory;
            _taskPending = CRATE_FACTORY_TASK_PENDING select _hoveredFactory;
            _taskType = CRATE_FACTORY_TASK_TYPE select _hoveredFactory;

            _moraleText = "Good";
            if (_morale < 70) then {_moraleText = "OK"};
            if (_morale < 40) then {_moraleText = "Low"};
            if (_morale < 30) then {_moraleText = "Bad"};

            _taskInfo = "";
            if (_taskPending) then {
                _taskInfo = format ["\nTask: %1", _taskType];
            };

            _food = CRATE_FACTORY_FOOD select _hoveredFactory;
            _water = CRATE_FACTORY_WATER select _hoveredFactory;
            _wood = CRATE_FACTORY_WOOD select _hoveredFactory;
            _metal = CRATE_FACTORY_METAL select _hoveredFactory;
            _coal = CRATE_FACTORY_COAL select _hoveredFactory;
            _elec = CRATE_FACTORY_ELECTRICITY select _hoveredFactory;

            _resourceInfo = "";
            if (_factoryType == "Town") then {
                _resourceInfo = format ["\nMetal: %1%% (Boost)", round _metal];
            };
            if (_factoryType == "Powerplant") then {
                _resourceInfo = format ["\nCoal: %1%% | Water: %2%% | Metal: %3%% (Boost)", round _coal, round _water, round _metal];
            };
            if (_factoryType == "Vehicle") then {
                _resourceInfo = format ["\nElec: %1%% | Metal: %2%%", round _elec, round _metal];
            };
            if (_factoryType == "Mineral" || _factoryType == "Pier") then {
                _resourceInfo = format ["\nFood: %1%% | Water: %2%% | Wood: %3%%\nElec: %4%% + Metal: %5%% (Boost)", round _food, round _water, round _wood, round _elec, round _metal];
            };

            _timerInfo = "";
            _script = CRATE_SPAWN_SCRIPTS select _hoveredFactory;
            if (!isNull _script) then {
                _timeLeft = CRATE_FACTORY_TIMERS select _hoveredFactory;
                _minutes = floor(_timeLeft / 60);
                _seconds = floor(_timeLeft mod 60);
                _secondsStr = str _seconds;
                if (_seconds < 10) then {_secondsStr = "0" + str _seconds};
                _timerInfo = "\nNext: " + str(_minutes) + ":" + _secondsStr;
            } else {
                _timerInfo = "\nStatus: OFF";
            };

            _hintText = format ["%1 Factory #%2\nMorale: %3%4%5%6", _factoryType, _hoveredFactory + 1, _moraleText, _taskInfo, _resourceInfo, _timerInfo];
            hintSilent _hintText;
        } else {
            hintSilent "";
        };
    }];

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
    _infoBox ctrlSetPosition [0.68, 0.09, 0.30, 0.12];
    _infoBox ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
    _infoBox ctrlCommit 0;

    _labelFactoryType = _display ctrlCreate ["RscText", 1023];
    _labelFactoryType ctrlSetPosition [0.68, 0.20, 0.30, 0.025];
    _labelFactoryType ctrlSetText "New Factory Type:";
    _labelFactoryType ctrlSetFontHeight 0.032;
    _labelFactoryType ctrlCommit 0;

    _comboFactoryType = _display ctrlCreate ["RscCombo", 1024];
    _comboFactoryType ctrlSetPosition [0.68, 0.225, 0.30, 0.035];
    _comboFactoryType lbAdd "Town Factory";
    _comboFactoryType lbSetData [0, "Town"];
    _comboFactoryType lbAdd "Mineral Factory";
    _comboFactoryType lbSetData [1, "Mineral"];
    _comboFactoryType lbAdd "Pier Factory";
    _comboFactoryType lbSetData [2, "Pier"];
    _comboFactoryType lbAdd "Powerplant Factory";
    _comboFactoryType lbSetData [3, "Powerplant"];
    _comboFactoryType lbAdd "Vehicle Factory";
    _comboFactoryType lbSetData [4, "Vehicle"];
    _comboFactoryType lbSetCurSel 0;
    _comboFactoryType ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
    _comboFactoryType ctrlSetFontHeight 0.03;
    _comboFactoryType ctrlCommit 0;

    _labelCost = _display ctrlCreate ["RscStructuredText", 1051];
    _labelCost ctrlSetPosition [0.68, 0.26, 0.30, 0.15];
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
        _costText = "";

        if (_factoryType == "Town") then {
            _townCount = {_x == "Town"} count CRATE_FACTORY_TYPES;
            if (_townCount == 0) then {
                _costText = "<t size='1.0' color='#0f0'>FREE!</t>";
            } else {
                _costText = "<t size='0.9'>Cost:<br/>5x Wood</t>";
            };
        };

        if (_factoryType == "Mineral") then {
            _costText = "<t size='0.9'>Cost:<br/>10x Food<br/>15x Water<br/>20x Wood</t>";
        };

        if (_factoryType == "Pier") then {
            _costText = "<t size='0.9'>Cost:<br/>15x Food<br/>20x Water<br/>25x Wood</t>";
        };

        if (_factoryType == "Powerplant") then {
            _costText = "<t size='0.9'>Cost:<br/>20x Coal<br/>25x Metal<br/>15x Wood</t>";
        };

        if (_factoryType == "Vehicle") then {
            _costText = "<t size='0.9'>Cost:<br/>30x Energy<br/>40x Metal<br/>20x Wood</t>";
        };

        _labelCost ctrlSetStructuredText parseText _costText;
    }];

    _btnSpawnFactory = _display ctrlCreate ["RscButton", 1025];
    _btnSpawnFactory ctrlSetPosition [0.68, 0.42, 0.30, 0.04];
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

        _canSpawn = false;
        _costMessage = "";

        if (_factoryType == "Town") then {
            _townCount = {_x == "Town"} count CRATE_FACTORY_TYPES;
            if (_townCount == 0) then {
                _canSpawn = true;
                _costMessage = "Cost: FREE (First town factory)";
            } else {
                _woodCost = 5;
                _nearWoodCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodPile_03_F"], 100];

                if (count _nearWoodCrates < _woodCost) exitWith {
                    systemChat ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWoodCrates));
                };

                for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWoodCrates select _i)};
                _costMessage = "Cost: 5x Wood";
                _canSpawn = true;
            };
        };

        if (_factoryType == "Mineral") then {
            _foodCost = 10;
            _waterCost = 15;
            _woodCost = 20;
            _nearFoodCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_FoodSacks_01_large_white_idap_F"], 100];
            _nearWaterCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PaperBox_01_open_water_F"], 100];
            _nearWoodCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodPile_03_F"], 100];

            _missingResources = [];
            if (count _nearFoodCrates < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFoodCrates))};
            if (count _nearWaterCrates < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWaterCrates))};
            if (count _nearWoodCrates < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWoodCrates))};

            if (count _missingResources > 0) exitWith {
                systemChat ("Missing resources: " + (_missingResources joinString " | "));
            };

            for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFoodCrates select _i)};
            for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWaterCrates select _i)};
            for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWoodCrates select _i)};
            _costMessage = "Cost: 10x Food + 15x Water + 20x Wood";
            _canSpawn = true;
        };

        if (_factoryType == "Powerplant") then {
            _coalCost = 20;
            _metalCost = 25;
            _woodCost = 15;
            _nearCoalCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PaperBox_closed_F"], 100];
            _nearMetalCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_CargoBox_V1_F"], 100];
            _nearWoodCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodPile_03_F"], 100];

            _missingResources = [];
            if (count _nearCoalCrates < _coalCost) then {_missingResources pushBack ("Coal: need " + str(_coalCost) + ", found " + str(count _nearCoalCrates))};
            if (count _nearMetalCrates < _metalCost) then {_missingResources pushBack ("Metal: need " + str(_metalCost) + ", found " + str(count _nearMetalCrates))};
            if (count _nearWoodCrates < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWoodCrates))};

            if (count _missingResources > 0) exitWith {
                systemChat ("Missing resources: " + (_missingResources joinString " | "));
            };

            for "_i" from 0 to (_coalCost - 1) do {deleteVehicle (_nearCoalCrates select _i)};
            for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetalCrates select _i)};
            for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWoodCrates select _i)};
            _costMessage = "Cost: 20x Coal + 25x Metal + 15x Wood";
            _canSpawn = true;
        };

        if (_factoryType == "Vehicle") then {
            _energyCost = 30;
            _metalCost = 40;
            _woodCost = 20;
            _nearEnergyCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PortableServer_01_sand_F"], 100];
            _nearMetalCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_CargoBox_V1_F"], 100];
            _nearWoodCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodPile_03_F"], 100];

            _missingResources = [];
            if (count _nearEnergyCrates < _energyCost) then {_missingResources pushBack ("Energy: need " + str(_energyCost) + ", found " + str(count _nearEnergyCrates))};
            if (count _nearMetalCrates < _metalCost) then {_missingResources pushBack ("Metal: need " + str(_metalCost) + ", found " + str(count _nearMetalCrates))};
            if (count _nearWoodCrates < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWoodCrates))};

            if (count _missingResources > 0) exitWith {
                systemChat ("Missing resources: " + (_missingResources joinString " | "));
            };

            for "_i" from 0 to (_energyCost - 1) do {deleteVehicle (_nearEnergyCrates select _i)};
            for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetalCrates select _i)};
            for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWoodCrates select _i)};
            _costMessage = "Cost: 30x Energy + 40x Metal + 20x Wood";
            _canSpawn = true;
        };

        if (_factoryType == "Pier") then {
            _foodCost = 15;
            _waterCost = 20;
            _woodCost = 25;
            _nearFoodCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_FoodSacks_01_large_white_idap_F"], 100];
            _nearWaterCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PaperBox_01_open_water_F"], 100];
            _nearWoodCrates = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodPile_03_F"], 100];

            _missingResources = [];
            if (count _nearFoodCrates < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFoodCrates))};
            if (count _nearWaterCrates < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWaterCrates))};
            if (count _nearWoodCrates < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWoodCrates))};

            if (count _missingResources > 0) exitWith {
                systemChat ("Missing resources: " + (_missingResources joinString " | "));
            };

            for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFoodCrates select _i)};
            for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWaterCrates select _i)};
            for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWoodCrates select _i)};
            _costMessage = "Cost: 15x Food + 20x Water + 25x Wood";
            _canSpawn = true;
        };

        if (!_canSpawn) exitWith {systemChat "Cannot spawn factory - validation failed!"};

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
        CRATE_FACTORY_TASK_PENDING pushBack false;
        CRATE_FACTORY_TASK_TYPE pushBack "";
        CRATE_FACTORY_TASK_ID pushBack "";
        CRATE_FACTORY_TASK_MIN_TIME pushBack 1800;
        CRATE_FACTORY_TASK_MAX_TIME pushBack 21600;
        CRATE_FACTORY_TASK_TIMER pushBack (1800 + random 19800);
        CRATE_FACTORY_TASK_START_TIME pushBack 0;
        CRATE_FACTORY_OPFOR_SPAWNED pushBack false;
        CRATE_FACTORY_LEVEL pushBack 1;

        CRATE_SELECTED_FACTORY = (count CRATE_FACTORY_POSITIONS) - 1;
        CRATE_PENDING_LOCATION = [];

        systemChat (_factoryType + " Factory #" + str(CRATE_SELECTED_FACTORY + 1) + " spawned! " + _costMessage);
    }];

    _btnUpgrade = _display ctrlCreate ["RscButton", 1036];
    _btnUpgrade ctrlSetPosition [0.68, 0.44, 0.30, 0.035];
    _btnUpgrade ctrlSetText "UPGRADE";
    _btnUpgrade ctrlSetBackgroundColor [0.7, 0.5, 0.2, 1];
    _btnUpgrade ctrlSetFontHeight 0.028;
    _btnUpgrade ctrlCommit 0;

    _btnUpgrade ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        if (CRATE_SELECTED_FACTORY < 0) exitWith {systemChat "Select a factory!"};
        _selectedIndex = CRATE_SELECTED_FACTORY;
        _factoryType = CRATE_FACTORY_TYPES select _selectedIndex;
        _factoryPos = CRATE_FACTORY_POSITIONS select _selectedIndex;
        _currentLevel = CRATE_FACTORY_LEVEL select _selectedIndex;

        if (_currentLevel >= 5) exitWith {systemChat "Factory already at max level!"};

        _nextLevel = _currentLevel + 1;
        _canUpgrade = false;
        _missingResources = [];

        if (_nextLevel == 2) then {
            _foodCost = 3; _waterCost = 3; _woodCost = 3;
            _nearFood = nearestObjects [_factoryPos, ["Land_FoodSacks_01_large_white_idap_F"], 50];
            _nearWater = nearestObjects [_factoryPos, ["Land_PaperBox_01_open_water_F"], 50];
            _nearWood = nearestObjects [_factoryPos, ["Land_WoodPile_03_F"], 50];
            if (count _nearFood < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFood))};
            if (count _nearWater < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWater))};
            if (count _nearWood < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWood))};
            if (count _missingResources == 0) then {
                for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFood select _i)};
                for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWater select _i)};
                for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWood select _i)};
                _canUpgrade = true;
            };
        };

        if (_nextLevel == 3) then {
            _foodCost = 8; _waterCost = 8; _woodCost = 8; _metalCost = 5;
            _nearFood = nearestObjects [_factoryPos, ["Land_FoodSacks_01_large_white_idap_F"], 50];
            _nearWater = nearestObjects [_factoryPos, ["Land_PaperBox_01_open_water_F"], 50];
            _nearWood = nearestObjects [_factoryPos, ["Land_WoodPile_03_F"], 50];
            _nearMetal = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 50];
            if (count _nearFood < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFood))};
            if (count _nearWater < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWater))};
            if (count _nearWood < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWood))};
            if (count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: need " + str(_metalCost) + ", found " + str(count _nearMetal))};
            if (count _missingResources == 0) then {
                for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFood select _i)};
                for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWater select _i)};
                for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWood select _i)};
                for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};
                _canUpgrade = true;
            };
        };

        if (_nextLevel == 4) then {
            _foodCost = 15; _waterCost = 15; _woodCost = 15; _metalCost = 12; _coalCost = 8;
            _nearFood = nearestObjects [_factoryPos, ["Land_FoodSacks_01_large_white_idap_F"], 50];
            _nearWater = nearestObjects [_factoryPos, ["Land_PaperBox_01_open_water_F"], 50];
            _nearWood = nearestObjects [_factoryPos, ["Land_WoodPile_03_F"], 50];
            _nearMetal = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 50];
            _nearCoal = nearestObjects [_factoryPos, ["Land_PaperBox_closed_F"], 50];
            if (count _nearFood < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFood))};
            if (count _nearWater < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWater))};
            if (count _nearWood < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWood))};
            if (count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: need " + str(_metalCost) + ", found " + str(count _nearMetal))};
            if (count _nearCoal < _coalCost) then {_missingResources pushBack ("Coal: need " + str(_coalCost) + ", found " + str(count _nearCoal))};
            if (count _missingResources == 0) then {
                for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFood select _i)};
                for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWater select _i)};
                for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWood select _i)};
                for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};
                for "_i" from 0 to (_coalCost - 1) do {deleteVehicle (_nearCoal select _i)};
                _canUpgrade = true;
            };
        };

        if (_nextLevel == 5) then {
            _foodCost = 25; _waterCost = 25; _woodCost = 25; _metalCost = 20; _coalCost = 15; _energyCost = 10;
            _nearFood = nearestObjects [_factoryPos, ["Land_FoodSacks_01_large_white_idap_F"], 50];
            _nearWater = nearestObjects [_factoryPos, ["Land_PaperBox_01_open_water_F"], 50];
            _nearWood = nearestObjects [_factoryPos, ["Land_WoodPile_03_F"], 50];
            _nearMetal = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 50];
            _nearCoal = nearestObjects [_factoryPos, ["Land_PaperBox_closed_F"], 50];
            _nearEnergy = nearestObjects [_factoryPos, ["Land_PortableServer_01_sand_F"], 50];
            if (count _nearFood < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFood))};
            if (count _nearWater < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWater))};
            if (count _nearWood < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWood))};
            if (count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: need " + str(_metalCost) + ", found " + str(count _nearMetal))};
            if (count _nearCoal < _coalCost) then {_missingResources pushBack ("Coal: need " + str(_coalCost) + ", found " + str(count _nearCoal))};
            if (count _nearEnergy < _energyCost) then {_missingResources pushBack ("Energy: need " + str(_energyCost) + ", found " + str(count _nearEnergy))};
            if (count _missingResources == 0) then {
                for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFood select _i)};
                for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWater select _i)};
                for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWood select _i)};
                for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};
                for "_i" from 0 to (_coalCost - 1) do {deleteVehicle (_nearCoal select _i)};
                for "_i" from 0 to (_energyCost - 1) do {deleteVehicle (_nearEnergy select _i)};
                _canUpgrade = true;
            };
        };

        if (count _missingResources > 0) exitWith {
            systemChat ("Missing resources for Level " + str(_nextLevel) + ": " + (_missingResources joinString " | "));
        };

        if (_canUpgrade) then {
            CRATE_FACTORY_LEVEL set [_selectedIndex, _nextLevel];
            _newMaxCrates = 10 + (_nextLevel * 2);
            CRATE_FACTORY_MAXCRATES set [_selectedIndex, _newMaxCrates];
            systemChat (_factoryType + " Factory #" + str(_selectedIndex + 1) + " upgraded to Level " + str(_nextLevel) + "! Max crates: " + str(_newMaxCrates));
        };
    }];

    _btnResupply = _display ctrlCreate ["RscButton", 1037];
    _btnResupply ctrlSetPosition [0.68, 0.48, 0.30, 0.035];
    _btnResupply ctrlSetText "RESUPPLY";
    _btnResupply ctrlSetBackgroundColor [0.2, 0.6, 0.8, 1];
    _btnResupply ctrlSetFontHeight 0.028;
    _btnResupply ctrlCommit 0;

    _btnResupply ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        if (CRATE_SELECTED_FACTORY < 0) exitWith {systemChat "Select a factory!"};
        _selectedIndex = CRATE_SELECTED_FACTORY;
        _factoryType = CRATE_FACTORY_TYPES select _selectedIndex;
        _factoryPos = CRATE_FACTORY_POSITIONS select _selectedIndex;

        _canResupply = false;
        _missingResources = [];

        if (_factoryType == "Town") then {
            _metalCost = 8;
            _nearMetal = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 50];
            if (count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: need " + str(_metalCost) + ", found " + str(count _nearMetal))};
            if (count _missingResources == 0) then {
                for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};
                CRATE_FACTORY_METAL set [_selectedIndex, 100];
                _canResupply = true;
            };
        };

        if (_factoryType == "Mineral" || _factoryType == "Pier") then {
            _foodCost = 10; _waterCost = 10; _woodCost = 10; _elecCost = 5; _metalCost = 5;
            _nearFood = nearestObjects [_factoryPos, ["Land_FoodSacks_01_large_white_idap_F"], 50];
            _nearWater = nearestObjects [_factoryPos, ["Land_PaperBox_01_open_water_F"], 50];
            _nearWood = nearestObjects [_factoryPos, ["Land_WoodPile_03_F"], 50];
            _nearElec = nearestObjects [_factoryPos, ["Land_PortableServer_01_sand_F"], 50];
            _nearMetal = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 50];
            if (count _nearFood < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFood))};
            if (count _nearWater < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWater))};
            if (count _nearWood < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWood))};
            if (count _nearElec < _elecCost) then {_missingResources pushBack ("Elec: need " + str(_elecCost) + ", found " + str(count _nearElec))};
            if (count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: need " + str(_metalCost) + ", found " + str(count _nearMetal))};
            if (count _missingResources == 0) then {
                for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFood select _i)};
                for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWater select _i)};
                for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWood select _i)};
                for "_i" from 0 to (_elecCost - 1) do {deleteVehicle (_nearElec select _i)};
                for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};
                CRATE_FACTORY_FOOD set [_selectedIndex, 100];
                CRATE_FACTORY_WATER set [_selectedIndex, 100];
                CRATE_FACTORY_WOOD set [_selectedIndex, 100];
                CRATE_FACTORY_ELECTRICITY set [_selectedIndex, 100];
                CRATE_FACTORY_METAL set [_selectedIndex, 100];
                _canResupply = true;
            };
        };

        if (_factoryType == "Powerplant") then {
            _coalCost = 15; _waterCost = 10; _metalCost = 8;
            _nearCoal = nearestObjects [_factoryPos, ["Land_PaperBox_closed_F"], 50];
            _nearWater = nearestObjects [_factoryPos, ["Land_PaperBox_01_open_water_F"], 50];
            _nearMetal = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 50];
            if (count _nearCoal < _coalCost) then {_missingResources pushBack ("Coal: need " + str(_coalCost) + ", found " + str(count _nearCoal))};
            if (count _nearWater < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWater))};
            if (count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: need " + str(_metalCost) + ", found " + str(count _nearMetal))};
            if (count _missingResources == 0) then {
                for "_i" from 0 to (_coalCost - 1) do {deleteVehicle (_nearCoal select _i)};
                for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWater select _i)};
                for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};
                CRATE_FACTORY_COAL set [_selectedIndex, 100];
                CRATE_FACTORY_WATER set [_selectedIndex, 100];
                CRATE_FACTORY_METAL set [_selectedIndex, 100];
                _canResupply = true;
            };
        };

        if (_factoryType == "Vehicle") then {
            _elecCost = 12; _metalCost = 10;
            _nearElec = nearestObjects [_factoryPos, ["Land_PortableServer_01_sand_F"], 50];
            _nearMetal = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 50];
            if (count _nearElec < _elecCost) then {_missingResources pushBack ("Elec: need " + str(_elecCost) + ", found " + str(count _nearElec))};
            if (count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: need " + str(_metalCost) + ", found " + str(count _nearMetal))};
            if (count _missingResources == 0) then {
                for "_i" from 0 to (_elecCost - 1) do {deleteVehicle (_nearElec select _i)};
                for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};
                CRATE_FACTORY_ELECTRICITY set [_selectedIndex, 100];
                CRATE_FACTORY_METAL set [_selectedIndex, 100];
                _canResupply = true;
            };
        };

        if (count _missingResources > 0) exitWith {
            systemChat ("Missing resources for resupply: " + (_missingResources joinString " | "));
        };

        if (_canResupply) then {
            systemChat (_factoryType + " Factory #" + str(_selectedIndex + 1) + " resupplied!");
        };
    }];

    _btnStartFactory = _display ctrlCreate ["RscButton", 1026];
    _btnStartFactory ctrlSetPosition [0.68, 0.52, 0.145, 0.035];
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

                _taskTimer = CRATE_FACTORY_TASK_TIMER select _factoryIndex;
                _hasTask = CRATE_FACTORY_TASK_PENDING select _factoryIndex;
                if (!_hasTask && _taskTimer > 0) then {
                    _taskTimer = _taskTimer - 0.5;
                    CRATE_FACTORY_TASK_TIMER set [_factoryIndex, _taskTimer];
                    if (_taskTimer <= 0) then {
                        _isCivilian = (random 1 < 0.75);
                        _taskType = if (_isCivilian) then {"Civilian"} else {"Military"};
                        _allTasks = call BIS_fnc_taskChildren;
                        _nearbyTasks = [];
                        {
                            _taskPos = [_x] call BIS_fnc_taskDestination;
                            if (!isNil "_taskPos" && {_taskPos distance2D _factoryPos < 400}) then {
                                _nearbyTasks pushBack _x;
                            };
                        } forEach _allTasks;

                        if (count _nearbyTasks > 0) then {
                            _selectedTask = selectRandom _nearbyTasks;
                            CRATE_FACTORY_TASK_PENDING set [_factoryIndex, true];
                            CRATE_FACTORY_TASK_TYPE set [_factoryIndex, _taskType];
                            CRATE_FACTORY_TASK_ID set [_factoryIndex, _selectedTask];
                            CRATE_FACTORY_TASK_START_TIME set [_factoryIndex, time];
                            systemChat format ["Factory %1: %2 task detected nearby!", _factoryIndex + 1, _taskType];
                        };
                        _minTime = CRATE_FACTORY_TASK_MIN_TIME select _factoryIndex;
                        _maxTime = CRATE_FACTORY_TASK_MAX_TIME select _factoryIndex;
                        CRATE_FACTORY_TASK_TIMER set [_factoryIndex, (_minTime + random (_maxTime - _minTime))];
                    };
                };

                if (_hasTask) then {
                    _taskID = CRATE_FACTORY_TASK_ID select _factoryIndex;
                    _taskState = [_taskID] call BIS_fnc_taskState;
                    if (_taskState == "SUCCEEDED" || _taskState == "FAILED" || _taskState == "CANCELED") then {
                        _startTime = CRATE_FACTORY_TASK_START_TIME select _factoryIndex;
                        _elapsedTime = time - _startTime;
                        _minTime = CRATE_FACTORY_TASK_MIN_TIME select _factoryIndex;
                        _maxTime = CRATE_FACTORY_TASK_MAX_TIME select _factoryIndex;
                        _midpoint = (_minTime + _maxTime) / 2;

                        if (_elapsedTime < _midpoint) then {
                            _minTime = _minTime + 3600;
                            _maxTime = 21600;
                            systemChat format ["Factory %1: Task completed early! Next task window: %2min-%3min", _factoryIndex + 1, round(_minTime/60), round(_maxTime/60)];
                        } else {
                            _maxTime = (_maxTime - 3600) max 1800;
                            _minTime = 1800;
                            systemChat format ["Factory %1: Task completed late! Next task window: %2min-%3min", _factoryIndex + 1, round(_minTime/60), round(_maxTime/60)];
                        };

                        CRATE_FACTORY_TASK_MIN_TIME set [_factoryIndex, _minTime];
                        CRATE_FACTORY_TASK_MAX_TIME set [_factoryIndex, _maxTime];

                        CRATE_FACTORY_TASK_PENDING set [_factoryIndex, false];
                        CRATE_FACTORY_TASK_TYPE set [_factoryIndex, ""];
                        CRATE_FACTORY_TASK_ID set [_factoryIndex, ""];
                        CRATE_FACTORY_TASK_START_TIME set [_factoryIndex, 0];
                        _currentMorale = CRATE_FACTORY_MORALE select _factoryIndex;
                        _newMorale = (_currentMorale + 2) min 100;
                        CRATE_FACTORY_MORALE set [_factoryIndex, _newMorale];
                        CRATE_FACTORY_TASK_TIMER set [_factoryIndex, (_minTime + random (_maxTime - _minTime))];

                        _fires = CRATE_FACTORY_FIRES select _factoryIndex;
                        {deleteVehicle _x} forEach _fires;
                        CRATE_FACTORY_FIRES set [_factoryIndex, []];
                        CRATE_FACTORY_OPFOR_SPAWNED set [_factoryIndex, false];
                    } else {
                        _currentMorale = CRATE_FACTORY_MORALE select _factoryIndex;
                        _newMorale = (_currentMorale - 0.1) max 0;
                        CRATE_FACTORY_MORALE set [_factoryIndex, _newMorale];

                        if (_newMorale < 40 && _newMorale >= 30) then {
                            _opforSpawned = CRATE_FACTORY_OPFOR_SPAWNED select _factoryIndex;
                            if (!_opforSpawned && random 1 < 0.3) then {
                                _spawnCount = 2 + floor(random 4);
                                for "_i" from 1 to _spawnCount do {
                                    _randomOffset = [random 30 - 15, random 30 - 15, 0];
                                    _spawnPos = _factoryPos vectorAdd _randomOffset;
                                    _grp = createGroup east;
                                    _unit = _grp createUnit ["O_Soldier_F", _spawnPos, [], 0, "NONE"];
                                };
                                CRATE_FACTORY_OPFOR_SPAWNED set [_factoryIndex, true];
                                systemChat format ["Factory %1: OPFOR units spotted nearby!", _factoryIndex + 1];
                            };
                        };

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
                };

                if (_factoryType == "Town") then {
                    _taskPending = CRATE_FACTORY_TASK_PENDING select _factoryIndex;
                    if (_taskPending) then {
                        sleep 5;
                    } else {
                        _metal = CRATE_FACTORY_METAL select _factoryIndex;
                        _speedBoost = 1 + (_metal / 100);
                        _adjustedInterval = _intervalSeconds / _speedBoost;
                        _spawnedCrates = CRATE_FACTORY_SPAWNEDCRATES select _factoryIndex;
                        _spawnedCrates = _spawnedCrates select {!isNull _x && _x distance2D _factoryPos < 40};
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
                };
                if (_factoryType == "Powerplant") then {
                    _taskPending = CRATE_FACTORY_TASK_PENDING select _factoryIndex;
                    if (_taskPending) then {
                        sleep 5;
                    } else {
                        _coal = CRATE_FACTORY_COAL select _factoryIndex;
                        _water = CRATE_FACTORY_WATER select _factoryIndex;
                        _metal = CRATE_FACTORY_METAL select _factoryIndex;
                        _speedBoost = 1 + (_metal / 100);
                        if (_coal <= 0 || _water <= 0) then {
                            sleep 5;
                        } else {
                        _spawnedCrates = CRATE_FACTORY_SPAWNEDCRATES select _factoryIndex;
                        _spawnedCrates = _spawnedCrates select {!isNull _x && _x distance2D _factoryPos < 40};
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
                };
                if (_factoryType == "Vehicle") then {
                    _taskPending = CRATE_FACTORY_TASK_PENDING select _factoryIndex;
                    if (_taskPending) then {
                        sleep 5;
                    } else {
                        _electricity = CRATE_FACTORY_ELECTRICITY select _factoryIndex;
                        _metal = CRATE_FACTORY_METAL select _factoryIndex;
                        if (_electricity <= 0 || _metal <= 0) then {
                            sleep 5;
                        } else {
                        _spawnedCrates = CRATE_FACTORY_SPAWNEDCRATES select _factoryIndex;
                        _spawnedCrates = _spawnedCrates select {!isNull _x && _x distance2D _factoryPos < 40};
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
                };
                if (_factoryType == "Mineral" || _factoryType == "Pier") then {
                    _taskPending = CRATE_FACTORY_TASK_PENDING select _factoryIndex;
                    if (_taskPending) then {
                        sleep 5;
                    } else {
                        _food = CRATE_FACTORY_FOOD select _factoryIndex;
                        _water = CRATE_FACTORY_WATER select _factoryIndex;
                        _wood = CRATE_FACTORY_WOOD select _factoryIndex;
                        _electricity = CRATE_FACTORY_ELECTRICITY select _factoryIndex;
                        _metal = CRATE_FACTORY_METAL select _factoryIndex;
                        if (_food <= 0 || _water <= 0 || _wood <= 0) then {
                            sleep 5;
                        } else {
                        _spawnedCrates = CRATE_FACTORY_SPAWNEDCRATES select _factoryIndex;
                        _spawnedCrates = _spawnedCrates select {!isNull _x && _x distance2D _factoryPos < 40};
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
                };
                sleep 0.5;
            };
        };
        CRATE_SPAWN_SCRIPTS set [_selectedIndex, _newScript];
        systemChat "Factory started!";
    }];

    _btnStopFactory = _display ctrlCreate ["RscButton", 1027];
    _btnStopFactory ctrlSetPosition [0.835, 0.52, 0.145, 0.035];
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
    _btnDelete ctrlSetPosition [0.68, 0.56, 0.30, 0.035];
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
        CRATE_FACTORY_TASK_PENDING deleteAt _selectedIndex;
        CRATE_FACTORY_TASK_TYPE deleteAt _selectedIndex;
        CRATE_FACTORY_TASK_ID deleteAt _selectedIndex;
        CRATE_FACTORY_TASK_TIMER deleteAt _selectedIndex;
        CRATE_FACTORY_OPFOR_SPAWNED deleteAt _selectedIndex;
        CRATE_FACTORY_LEVEL deleteAt _selectedIndex;
        CRATE_SELECTED_FACTORY = -1;
        systemChat "Factory deleted!";
    }];

    _labelInterval = _display ctrlCreate ["RscText", 1002];
    _labelInterval ctrlSetPosition [0.68, 0.60, 0.30, 0.025];
    _labelInterval ctrlSetText "Interval (minutes):";
    _labelInterval ctrlSetFontHeight 0.032;
    _labelInterval ctrlCommit 0;

    _inputInterval = _display ctrlCreate ["RscEdit", 1003];
    _inputInterval ctrlSetPosition [0.68, 0.625, 0.30, 0.035];
    _inputInterval ctrlSetText "60";
    _inputInterval ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
    _inputInterval ctrlSetFontHeight 0.032;
    _inputInterval ctrlCommit 0;

    _labelType = _display ctrlCreate ["RscText", 1008];
    _labelType ctrlSetPosition [0.68, 0.665, 0.30, 0.022];
    _labelType ctrlSetText "Output Type:";
    _labelType ctrlSetFontHeight 0.03;
    _labelType ctrlCommit 0;

    _comboType = _display ctrlCreate ["RscCombo", 1009];
    _comboType ctrlSetPosition [0.68, 0.687, 0.30, 0.035];
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
        CRATE_FACTORY_TASK_PENDING = [];
        CRATE_FACTORY_TASK_TYPE = [];
        CRATE_FACTORY_TASK_ID = [];
        CRATE_FACTORY_TASK_TIMER = [];
        CRATE_FACTORY_OPFOR_SPAWNED = [];
        CRATE_FACTORY_LEVEL = [];
        CRATE_SELECTED_FACTORY = -1;
        CRATE_HOVERED_FACTORY = -1;
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
                _factoryPos = CRATE_FACTORY_POSITIONS select _selectedIndex;

                _spawnedCrates = CRATE_FACTORY_SPAWNEDCRATES select _selectedIndex;
                _spawnedCrates = _spawnedCrates select {!isNull _x && _x distance2D _factoryPos < 40};
                CRATE_FACTORY_SPAWNEDCRATES set [_selectedIndex, _spawnedCrates];
                _crateCount = count _spawnedCrates;
                CRATE_FACTORY_COUNTS set [_selectedIndex, _crateCount];

                _maxCrates = CRATE_FACTORY_MAXCRATES select _selectedIndex;
                _script = CRATE_SPAWN_SCRIPTS select _selectedIndex;
                _currentInterval = CRATE_FACTORY_INTERVALS select _selectedIndex;
                _currentCrateType = CRATE_FACTORY_CRATETYPES select _selectedIndex;

                _status = if (isNull _script) then {"<t color='#888'>OFF</t>"} else {"<t color='#0f0'>ON</t>"};
                _factoryLevel = CRATE_FACTORY_LEVEL select _selectedIndex;

                _typeColor = "#0f0";
                if (_factoryType == "Town") then {_typeColor = "#08f"};
                if (_factoryType == "Powerplant") then {_typeColor = "#f80"};
                if (_factoryType == "Vehicle") then {_typeColor = "#80f"};
                if (_factoryType == "Pier") then {_typeColor = "#0cc"};

                _infoText = format ["<t size='1.3' color='%4'>%1 #%2</t><br/>Level %7 | %3<br/>Crates: %5/%6", _factoryType, _selectedIndex + 1, _status, _typeColor, _crateCount, _maxCrates, _factoryLevel];
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
                    _costText = "";

                    if (_factoryType == "Town") then {
                        _townCount = {_x == "Town"} count CRATE_FACTORY_TYPES;
                        if (_townCount == 0) then {
                            _costText = "<t size='1.0' color='#0f0'>FREE!</t>";
                        } else {
                            _costText = "<t size='0.9'>Cost:<br/>5x Wood</t>";
                        };
                    };

                    if (_factoryType == "Mineral") then {
                        _costText = "<t size='0.9'>Cost:<br/>10x Food<br/>15x Water<br/>20x Wood</t>";
                    };

                    if (_factoryType == "Pier") then {
                        _costText = "<t size='0.9'>Cost:<br/>15x Food<br/>20x Water<br/>25x Wood</t>";
                    };

                    if (_factoryType == "Powerplant") then {
                        _costText = "<t size='0.9'>Cost:<br/>20x Coal<br/>25x Metal<br/>15x Wood</t>";
                    };

                    if (_factoryType == "Vehicle") then {
                        _costText = "<t size='0.9'>Cost:<br/>30x Energy<br/>40x Metal<br/>20x Wood</t>";
                    };

                    _labelCost ctrlSetStructuredText parseText _costText;
                } else {
                    _labelCost ctrlSetStructuredText parseText "";
                };
                _lastSelectedFactory = -2;
            };
            sleep 0.5;
        };
    };
}];

systemChat "Factory Manager loaded! Hover over factories for info.";