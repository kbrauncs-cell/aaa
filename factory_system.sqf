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
    if (isNil "CRATE_SELECTED_FACTORY") then {CRATE_SELECTED_FACTORY = -1};
    if (isNil "CRATE_FACTORY_FIRES") then {CRATE_FACTORY_FIRES = []};
    if (isNil "CRATE_FACTORY_MORALE") then {CRATE_FACTORY_MORALE = []};
    if (isNil "CRATE_FACTORY_TASK_PENDING") then {CRATE_FACTORY_TASK_PENDING = []};
    if (isNil "CRATE_FACTORY_TASK_TYPE") then {CRATE_FACTORY_TASK_TYPE = []};
    if (isNil "CRATE_FACTORY_TASK_ID") then {CRATE_FACTORY_TASK_ID = []};
    if (isNil "CRATE_FACTORY_TASK_TIMER") then {CRATE_FACTORY_TASK_TIMER = []};
    if (isNil "CRATE_FACTORY_TASK_MIN_TIME") then {CRATE_FACTORY_TASK_MIN_TIME = []};
    if (isNil "CRATE_FACTORY_TASK_MAX_TIME") then {CRATE_FACTORY_TASK_MAX_TIME = []};
    if (isNil "CRATE_FACTORY_OPFOR_SPAWNED") then {CRATE_FACTORY_OPFOR_SPAWNED = []};
    if (isNil "CRATE_MOUSE_POS") then {CRATE_MOUSE_POS = []};
    if (isNil "CRATE_FACTORY_LEVEL") then {CRATE_FACTORY_LEVEL = []};
    if (isNil "FOOD_WATER_CRATES") then {FOOD_WATER_CRATES = []};
    if (isNil "DROPPED_ITEMS_GLOBAL") then {DROPPED_ITEMS_GLOBAL = []};
    if (isNil "PLAYER_CARRYING_ITEM") then {PLAYER_CARRYING_ITEM = objNull};

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
                _costText = "<t size='0.8'>Cost:<br/>3 Food | 3 Water<br/>5 Wood</t>";
            };
        };

        if (_factoryType == "Mineral") then {
            _costText = "<t size='0.8'>Cost:<br/>8 Food | 10 Water<br/>15 Wood</t>";
        };

        if (_factoryType == "Pier") then {
            _costText = "<t size='0.8'>Cost:<br/>10 Food | 12 Water<br/>18 Wood</t>";
        };

        if (_factoryType == "Powerplant") then {
            _costText = "<t size='0.7'>Cost:<br/>10F 10W 15Wood 15Metal 20Coal<br/>5 Iron | 5 Fish</t>";
        };

        if (_factoryType == "Vehicle") then {
            _costText = "<t size='0.65'>Cost:<br/>12F 12W 20Wood 30Metal 15Coal 25Energy<br/>10Iron 5Diamonds 8Fish 8Oil 5Gold 10Electronics</t>";
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
                _foodCost = 3; _waterCost = 3; _woodCost = 5;
                _nearFood = nearestObjects [CRATE_PENDING_LOCATION, ["Box_IND_AmmoVeh_F"], 100];
                _nearWater = nearestObjects [CRATE_PENDING_LOCATION, ["Box_IND_Wps_F"], 100];
                _nearWood = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodPile_03_F"], 100];

                _missingResources = [];
                if (count _nearFood < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFood))};
                if (count _nearWater < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWater))};
                if (count _nearWood < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWood))};

                if (count _missingResources > 0) exitWith {
                    systemChat ("Missing resources: " + (_missingResources joinString " | "));
                };

                for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFood select _i)};
                for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWater select _i)};
                for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWood select _i)};
                _costMessage = "Cost: 3 Food + 3 Water + 5 Wood";
                _canSpawn = true;
            };
        };

        if (_factoryType == "Mineral") then {
            _foodCost = 8; _waterCost = 10; _woodCost = 15;
            _nearFood = nearestObjects [CRATE_PENDING_LOCATION, ["Box_IND_AmmoVeh_F"], 100];
            _nearWater = nearestObjects [CRATE_PENDING_LOCATION, ["Box_IND_Wps_F"], 100];
            _nearWood = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodPile_03_F"], 100];

            _missingResources = [];
            if (count _nearFood < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFood))};
            if (count _nearWater < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWater))};
            if (count _nearWood < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWood))};

            if (count _missingResources > 0) exitWith {
                systemChat ("Missing resources: " + (_missingResources joinString " | "));
            };

            for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFood select _i)};
            for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWater select _i)};
            for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWood select _i)};
            _costMessage = "Cost: 8 Food + 10 Water + 15 Wood";
            _canSpawn = true;
        };

        if (_factoryType == "Powerplant") then {
            _foodCost = 10; _waterCost = 10; _woodCost = 15; _metalCost = 15; _coalCost = 20; _ironCost = 5; _fishCost = 5;
            _nearFood = nearestObjects [CRATE_PENDING_LOCATION, ["Box_IND_AmmoVeh_F"], 100];
            _nearWater = nearestObjects [CRATE_PENDING_LOCATION, ["Box_IND_Wps_F"], 100];
            _nearWood = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodPile_03_F"], 100];
            _nearMetal = nearestObjects [CRATE_PENDING_LOCATION, ["Land_CargoBox_V1_F"], 100];
            _nearCoal = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PaperBox_closed_F"], 100];
            _nearIron = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PaperBox_open_full_F"], 100];
            _nearFish = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodenBox_02_F"], 100];

            _missingResources = [];
            if (count _nearFood < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFood))};
            if (count _nearWater < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWater))};
            if (count _nearWood < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWood))};
            if (count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: need " + str(_metalCost) + ", found " + str(count _nearMetal))};
            if (count _nearCoal < _coalCost) then {_missingResources pushBack ("Coal: need " + str(_coalCost) + ", found " + str(count _nearCoal))};
            if (count _nearIron < _ironCost) then {_missingResources pushBack ("Iron: need " + str(_ironCost) + ", found " + str(count _nearIron))};
            if (count _nearFish < _fishCost) then {_missingResources pushBack ("Fish: need " + str(_fishCost) + ", found " + str(count _nearFish))};

            if (count _missingResources > 0) exitWith {
                systemChat ("Missing resources: " + (_missingResources joinString " | "));
            };

            for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFood select _i)};
            for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWater select _i)};
            for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWood select _i)};
            for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};
            for "_i" from 0 to (_coalCost - 1) do {deleteVehicle (_nearCoal select _i)};
            for "_i" from 0 to (_ironCost - 1) do {deleteVehicle (_nearIron select _i)};
            for "_i" from 0 to (_fishCost - 1) do {deleteVehicle (_nearFish select _i)};
            _costMessage = "Cost: 10F + 10W + 15Wood + 15Metal + 20Coal + 5Iron + 5Fish";
            _canSpawn = true;
        };

        if (_factoryType == "Vehicle") then {
            _foodCost = 12; _waterCost = 12; _woodCost = 20; _metalCost = 30; _coalCost = 15; _energyCost = 25; _ironCost = 10; _diamondCost = 5; _fishCost = 8; _oilCost = 8; _goldCost = 5; _electronicsCost = 10;
            _nearFood = nearestObjects [CRATE_PENDING_LOCATION, ["Box_IND_AmmoVeh_F"], 100];
            _nearWater = nearestObjects [CRATE_PENDING_LOCATION, ["Box_IND_Wps_F"], 100];
            _nearWood = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodPile_03_F"], 100];
            _nearMetal = nearestObjects [CRATE_PENDING_LOCATION, ["Land_CargoBox_V1_F"], 100];
            _nearCoal = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PaperBox_closed_F"], 100];
            _nearEnergy = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PortableServer_01_sand_F"], 100];
            _nearIron = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PaperBox_open_full_F"], 100];
            _nearDiamond = nearestObjects [CRATE_PENDING_LOCATION, ["Land_Boxloader_Fort_iso_Brown"], 100];
            _nearFish = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodenBox_02_F"], 100];
            _nearOil = nearestObjects [CRATE_PENDING_LOCATION, ["CargoNet_01_barrels_F"], 100];
            _nearGold = nearestObjects [CRATE_PENDING_LOCATION, ["Land_CratesWooden_F"], 100];
            _nearElectronics = nearestObjects [CRATE_PENDING_LOCATION, ["Land_PaperBox_01_open_boxes_F"], 100];

            _missingResources = [];
            if (count _nearFood < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFood))};
            if (count _nearWater < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWater))};
            if (count _nearWood < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWood))};
            if (count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: need " + str(_metalCost) + ", found " + str(count _nearMetal))};
            if (count _nearCoal < _coalCost) then {_missingResources pushBack ("Coal: need " + str(_coalCost) + ", found " + str(count _nearCoal))};
            if (count _nearEnergy < _energyCost) then {_missingResources pushBack ("Energy: need " + str(_energyCost) + ", found " + str(count _nearEnergy))};
            if (count _nearIron < _ironCost) then {_missingResources pushBack ("Iron: need " + str(_ironCost) + ", found " + str(count _nearIron))};
            if (count _nearDiamond < _diamondCost) then {_missingResources pushBack ("Diamonds: need " + str(_diamondCost) + ", found " + str(count _nearDiamond))};
            if (count _nearFish < _fishCost) then {_missingResources pushBack ("Fish: need " + str(_fishCost) + ", found " + str(count _nearFish))};
            if (count _nearOil < _oilCost) then {_missingResources pushBack ("Oil: need " + str(_oilCost) + ", found " + str(count _nearOil))};
            if (count _nearGold < _goldCost) then {_missingResources pushBack ("Gold: need " + str(_goldCost) + ", found " + str(count _nearGold))};
            if (count _nearElectronics < _electronicsCost) then {_missingResources pushBack ("Electronics: need " + str(_electronicsCost) + ", found " + str(count _nearElectronics))};

            if (count _missingResources > 0) exitWith {
                systemChat ("Missing resources: " + (_missingResources joinString " | "));
            };

            for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFood select _i)};
            for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWater select _i)};
            for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWood select _i)};
            for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};
            for "_i" from 0 to (_coalCost - 1) do {deleteVehicle (_nearCoal select _i)};
            for "_i" from 0 to (_energyCost - 1) do {deleteVehicle (_nearEnergy select _i)};
            for "_i" from 0 to (_ironCost - 1) do {deleteVehicle (_nearIron select _i)};
            for "_i" from 0 to (_diamondCost - 1) do {deleteVehicle (_nearDiamond select _i)};
            for "_i" from 0 to (_fishCost - 1) do {deleteVehicle (_nearFish select _i)};
            for "_i" from 0 to (_oilCost - 1) do {deleteVehicle (_nearOil select _i)};
            for "_i" from 0 to (_goldCost - 1) do {deleteVehicle (_nearGold select _i)};
            for "_i" from 0 to (_electronicsCost - 1) do {deleteVehicle (_nearElectronics select _i)};
            _costMessage = "Cost: 12F 12W 20Wood 30Metal 15Coal 25Energy 10Iron 5Diamonds 8Fish 8Oil 5Gold 10Electronics";
            _canSpawn = true;
        };

        if (_factoryType == "Pier") then {
            _foodCost = 10; _waterCost = 12; _woodCost = 18;
            _nearFood = nearestObjects [CRATE_PENDING_LOCATION, ["Box_IND_AmmoVeh_F"], 100];
            _nearWater = nearestObjects [CRATE_PENDING_LOCATION, ["Box_IND_Wps_F"], 100];
            _nearWood = nearestObjects [CRATE_PENDING_LOCATION, ["Land_WoodPile_03_F"], 100];

            _missingResources = [];
            if (count _nearFood < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFood))};
            if (count _nearWater < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWater))};
            if (count _nearWood < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWood))};

            if (count _missingResources > 0) exitWith {
                systemChat ("Missing resources: " + (_missingResources joinString " | "));
            };

            for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFood select _i)};
            for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWater select _i)};
            for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWood select _i)};
            _costMessage = "Cost: 10 Food + 12 Water + 18 Wood";
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
        CRATE_FACTORY_FIRES pushBack [];
        CRATE_FACTORY_MORALE pushBack 100;
        CRATE_FACTORY_TASK_PENDING pushBack false;
        CRATE_FACTORY_TASK_TYPE pushBack "";
        CRATE_FACTORY_TASK_ID pushBack "";
        CRATE_FACTORY_TASK_MIN_TIME pushBack 1800;
        CRATE_FACTORY_TASK_MAX_TIME pushBack 21600;
        CRATE_FACTORY_TASK_TIMER pushBack (1800 + random 19800);
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
        _foodCost = 0; _waterCost = 0; _woodCost = 0; _metalCost = 0; _coalCost = 0; _energyCost = 0;
        _ironCost = 0; _diamondCost = 0; _fishCost = 0; _oilCost = 0; _goldCost = 0; _electronicsCost = 0;
        _fuelTankCost = 0; _wheelCost = 0; _enginePartCost = 0;

        if (_factoryType == "Town") then {
            if (_nextLevel == 2) then {_foodCost = 2; _waterCost = 2; _woodCost = 3; _metalCost = 1};
            if (_nextLevel == 3) then {_foodCost = 5; _waterCost = 5; _woodCost = 8; _metalCost = 3; _coalCost = 2; _ironCost = 2; _fishCost = 3};
            if (_nextLevel == 4) then {_foodCost = 10; _waterCost = 10; _woodCost = 12; _metalCost = 8; _coalCost = 5; _energyCost = 3; _ironCost = 5; _fishCost = 5; _electronicsCost = 3; _diamondCost = 2; _oilCost = 3};
            if (_nextLevel == 5) then {_foodCost = 15; _waterCost = 15; _woodCost = 18; _metalCost = 12; _coalCost = 8; _energyCost = 8; _ironCost = 8; _diamondCost = 5; _goldCost = 5; _electronicsCost = 6; _fuelTankCost = 3; _wheelCost = 3};
        };

        if (_factoryType == "Mineral") then {
            if (_nextLevel == 2) then {_foodCost = 3; _waterCost = 4; _woodCost = 5; _metalCost = 2; _coalCost = 1};
            if (_nextLevel == 3) then {_foodCost = 8; _waterCost = 10; _woodCost = 12; _metalCost = 5; _coalCost = 4; _energyCost = 2; _fishCost = 4; _electronicsCost = 2};
            if (_nextLevel == 4) then {_foodCost = 15; _waterCost = 18; _woodCost = 20; _metalCost = 12; _coalCost = 10; _energyCost = 5; _ironCost = 8; _fishCost = 8; _electronicsCost = 5; _oilCost = 5; _goldCost = 3};
            if (_nextLevel == 5) then {_foodCost = 25; _waterCost = 25; _woodCost = 30; _metalCost = 20; _coalCost = 15; _energyCost = 12; _ironCost = 12; _diamondCost = 8; _goldCost = 8; _electronicsCost = 10; _oilCost = 8; _fuelTankCost = 5; _wheelCost = 4; _enginePartCost = 4};
        };

        if (_factoryType == "Pier") then {
            if (_nextLevel == 2) then {_foodCost = 4; _waterCost = 5; _woodCost = 6; _metalCost = 2; _coalCost = 1; _energyCost = 1};
            if (_nextLevel == 3) then {_foodCost = 10; _waterCost = 12; _woodCost = 15; _metalCost = 6; _coalCost = 5; _energyCost = 3; _ironCost = 4; _electronicsCost = 3};
            if (_nextLevel == 4) then {_foodCost = 18; _waterCost = 20; _woodCost = 25; _metalCost = 15; _coalCost = 12; _energyCost = 8; _ironCost = 10; _diamondCost = 4; _electronicsCost = 6; _goldCost = 5};
            if (_nextLevel == 5) then {_foodCost = 30; _waterCost = 30; _woodCost = 35; _metalCost = 25; _coalCost = 18; _energyCost = 15; _ironCost = 15; _diamondCost = 10; _goldCost = 12; _electronicsCost = 12; _oilCost = 10; _fuelTankCost = 6; _wheelCost = 5; _enginePartCost = 5};
        };

        if (_factoryType == "Powerplant") then {
            if (_nextLevel == 2) then {_foodCost = 5; _waterCost = 5; _woodCost = 8; _metalCost = 5; _coalCost = 8; _energyCost = 3};
            if (_nextLevel == 3) then {_foodCost = 12; _waterCost = 15; _woodCost = 18; _metalCost = 12; _coalCost = 15; _energyCost = 8; _ironCost = 6; _fishCost = 6};
            if (_nextLevel == 4) then {_foodCost = 22; _waterCost = 25; _woodCost = 30; _metalCost = 20; _coalCost = 25; _energyCost = 15; _ironCost = 12; _diamondCost = 6; _fishCost = 12; _oilCost = 8; _goldCost = 6};
            if (_nextLevel == 5) then {_foodCost = 35; _waterCost = 35; _woodCost = 40; _metalCost = 35; _coalCost = 35; _energyCost = 25; _ironCost = 18; _diamondCost = 12; _goldCost = 15; _oilCost = 15; _fuelTankCost = 8; _wheelCost = 8; _enginePartCost = 8};
        };

        if (_factoryType == "Vehicle") then {
            if (_nextLevel == 2) then {_foodCost = 6; _waterCost = 6; _woodCost = 10; _metalCost = 8; _coalCost = 5; _energyCost = 5};
            if (_nextLevel == 3) then {_foodCost = 15; _waterCost = 18; _woodCost = 25; _metalCost = 18; _coalCost = 12; _energyCost = 15; _ironCost = 8; _fishCost = 8; _electronicsCost = 8};
            if (_nextLevel == 4) then {_foodCost = 28; _waterCost = 30; _woodCost = 40; _metalCost = 30; _coalCost = 20; _energyCost = 25; _ironCost = 15; _diamondCost = 8; _fishCost = 15; _electronicsCost = 15; _oilCost = 12; _goldCost = 10};
            if (_nextLevel == 5) then {_foodCost = 45; _waterCost = 45; _woodCost = 50; _metalCost = 50; _coalCost = 30; _energyCost = 40; _ironCost = 25; _diamondCost = 15; _goldCost = 20; _oilCost = 20; _electronicsCost = 25; _fuelTankCost = 12; _wheelCost = 12; _enginePartCost = 12};
        };

        _nearFood = nearestObjects [_factoryPos, ["Box_IND_AmmoVeh_F"], 50];
        _nearWater = nearestObjects [_factoryPos, ["Box_IND_Wps_F"], 50];
        _nearWood = nearestObjects [_factoryPos, ["Land_WoodPile_03_F"], 50];
        _nearMetal = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 50];
        _nearCoal = nearestObjects [_factoryPos, ["Land_PaperBox_closed_F"], 50];
        _nearEnergy = nearestObjects [_factoryPos, ["Land_PortableServer_01_sand_F"], 50];
        _nearIron = nearestObjects [_factoryPos, ["Land_PaperBox_open_full_F"], 50];
        _nearDiamond = nearestObjects [_factoryPos, ["Land_Boxloader_Fort_iso_Brown"], 50];
        _nearFish = nearestObjects [_factoryPos, ["Land_WoodenBox_02_F"], 50];
        _nearOil = nearestObjects [_factoryPos, ["CargoNet_01_barrels_F"], 50];
        _nearGold = nearestObjects [_factoryPos, ["Land_CratesWooden_F"], 50];
        _nearElectronics = nearestObjects [_factoryPos, ["Land_PaperBox_01_open_boxes_F"], 50];
        _nearFuelTank = nearestObjects [_factoryPos, ["Land_CanisterFuel_F"], 50];
        _nearWheel = nearestObjects [_factoryPos, ["Land_Wheel_01_F"], 50];
        _nearEnginePart = nearestObjects [_factoryPos, ["Land_MetalBarrel_F"], 50];

        _missingResources = [];
        if (_foodCost > 0 && count _nearFood < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + ", found " + str(count _nearFood))};
        if (_waterCost > 0 && count _nearWater < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + ", found " + str(count _nearWater))};
        if (_woodCost > 0 && count _nearWood < _woodCost) then {_missingResources pushBack ("Wood: need " + str(_woodCost) + ", found " + str(count _nearWood))};
        if (_metalCost > 0 && count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: need " + str(_metalCost) + ", found " + str(count _nearMetal))};
        if (_coalCost > 0 && count _nearCoal < _coalCost) then {_missingResources pushBack ("Coal: need " + str(_coalCost) + ", found " + str(count _nearCoal))};
        if (_energyCost > 0 && count _nearEnergy < _energyCost) then {_missingResources pushBack ("Energy: need " + str(_energyCost) + ", found " + str(count _nearEnergy))};
        if (_ironCost > 0 && count _nearIron < _ironCost) then {_missingResources pushBack ("Iron: need " + str(_ironCost) + ", found " + str(count _nearIron))};
        if (_diamondCost > 0 && count _nearDiamond < _diamondCost) then {_missingResources pushBack ("Diamonds: need " + str(_diamondCost) + ", found " + str(count _nearDiamond))};
        if (_fishCost > 0 && count _nearFish < _fishCost) then {_missingResources pushBack ("Fish: need " + str(_fishCost) + ", found " + str(count _nearFish))};
        if (_oilCost > 0 && count _nearOil < _oilCost) then {_missingResources pushBack ("Oil: need " + str(_oilCost) + ", found " + str(count _nearOil))};
        if (_goldCost > 0 && count _nearGold < _goldCost) then {_missingResources pushBack ("Gold: need " + str(_goldCost) + ", found " + str(count _nearGold))};
        if (_electronicsCost > 0 && count _nearElectronics < _electronicsCost) then {_missingResources pushBack ("Electronics: need " + str(_electronicsCost) + ", found " + str(count _nearElectronics))};
        if (_fuelTankCost > 0 && count _nearFuelTank < _fuelTankCost) then {_missingResources pushBack ("Fuel Tanks: need " + str(_fuelTankCost) + ", found " + str(count _nearFuelTank))};
        if (_wheelCost > 0 && count _nearWheel < _wheelCost) then {_missingResources pushBack ("Wheels: need " + str(_wheelCost) + ", found " + str(count _nearWheel))};
        if (_enginePartCost > 0 && count _nearEnginePart < _enginePartCost) then {_missingResources pushBack ("Engine Parts: need " + str(_enginePartCost) + ", found " + str(count _nearEnginePart))};

        if (count _missingResources > 0) exitWith {
            systemChat ("Missing resources for Level " + str(_nextLevel) + ": " + (_missingResources joinString " | "));
        };

        if (_foodCost > 0) then {for "_i" from 0 to (_foodCost - 1) do {deleteVehicle (_nearFood select _i)}};
        if (_waterCost > 0) then {for "_i" from 0 to (_waterCost - 1) do {deleteVehicle (_nearWater select _i)}};
        if (_woodCost > 0) then {for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWood select _i)}};
        if (_metalCost > 0) then {for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)}};
        if (_coalCost > 0) then {for "_i" from 0 to (_coalCost - 1) do {deleteVehicle (_nearCoal select _i)}};
        if (_energyCost > 0) then {for "_i" from 0 to (_energyCost - 1) do {deleteVehicle (_nearEnergy select _i)}};
        if (_ironCost > 0) then {for "_i" from 0 to (_ironCost - 1) do {deleteVehicle (_nearIron select _i)}};
        if (_diamondCost > 0) then {for "_i" from 0 to (_diamondCost - 1) do {deleteVehicle (_nearDiamond select _i)}};
        if (_fishCost > 0) then {for "_i" from 0 to (_fishCost - 1) do {deleteVehicle (_nearFish select _i)}};
        if (_oilCost > 0) then {for "_i" from 0 to (_oilCost - 1) do {deleteVehicle (_nearOil select _i)}};
        if (_goldCost > 0) then {for "_i" from 0 to (_goldCost - 1) do {deleteVehicle (_nearGold select _i)}};
        if (_electronicsCost > 0) then {for "_i" from 0 to (_electronicsCost - 1) do {deleteVehicle (_nearElectronics select _i)}};
        if (_fuelTankCost > 0) then {for "_i" from 0 to (_fuelTankCost - 1) do {deleteVehicle (_nearFuelTank select _i)}};
        if (_wheelCost > 0) then {for "_i" from 0 to (_wheelCost - 1) do {deleteVehicle (_nearWheel select _i)}};
        if (_enginePartCost > 0) then {for "_i" from 0 to (_enginePartCost - 1) do {deleteVehicle (_nearEnginePart select _i)}};

        CRATE_FACTORY_LEVEL set [_selectedIndex, _nextLevel];
        _newMaxCrates = 10 + (_nextLevel * 2);
        CRATE_FACTORY_MAXCRATES set [_selectedIndex, _newMaxCrates];
        systemChat (_factoryType + " Factory #" + str(_selectedIndex + 1) + " upgraded to Level " + str(_nextLevel) + "! Max crates: " + str(_newMaxCrates));
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
        _factoryLevel = CRATE_FACTORY_LEVEL select _selectedIndex;

        _baseCost = 1 + _factoryLevel;
        _metalCost = _baseCost + floor(random 2);

        if (_factoryType == "Town") then {
            _nearMetal = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 50];
            if (count _nearMetal < _metalCost) exitWith {
                systemChat ("Missing Metal: need " + str(_metalCost) + ", found " + str(count _nearMetal));
            };
            for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};
            CRATE_FACTORY_METAL set [_selectedIndex, 100];
            systemChat (_factoryType + " Factory #" + str(_selectedIndex + 1) + " resupplied for " + str(_metalCost) + " Metal!");
        };

        if (_factoryType == "Mineral" || _factoryType == "Pier") then {
            _foodCost = _baseCost + floor(random 3);
            _waterCost = _baseCost + floor(random 3);
            _woodCost = _baseCost + floor(random 3);
            _elecCost = _baseCost + floor(random 2);
            _nearFood = nearestObjects [_factoryPos, ["Box_IND_AmmoVeh_F"], 50];
            _nearWater = nearestObjects [_factoryPos, ["Box_IND_Wps_F"], 50];
            _nearWood = nearestObjects [_factoryPos, ["Land_WoodPile_03_F"], 50];
            _nearElec = nearestObjects [_factoryPos, ["Land_PortableServer_01_sand_F"], 50];
            _nearMetal = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 50];

            _foodValue = 0;
            {
                _itemCount = _x getVariable ["crateItemCount", 250];
                _foodValue = _foodValue + (_itemCount / 250);
            } forEach _nearFood;

            _waterValue = 0;
            {
                _itemCount = _x getVariable ["crateItemCount", 250];
                _waterValue = _waterValue + (_itemCount / 250);
            } forEach _nearWater;

            _missingResources = [];
            if (_foodValue < _foodCost) then {_missingResources pushBack ("Food: need " + str(_foodCost) + " value, have " + str(floor(_foodValue * 10) / 10))};
            if (_waterValue < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + " value, have " + str(floor(_waterValue * 10) / 10))};
            if (count _nearWood < _woodCost) then {_missingResources pushBack ("Wood: " + str(_woodCost))};
            if (count _nearElec < _elecCost) then {_missingResources pushBack ("Elec: " + str(_elecCost))};
            if (count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: " + str(_metalCost))};

            if (count _missingResources > 0) exitWith {
                systemChat ("Missing: " + (_missingResources joinString " | "));
            };

            {deleteVehicle _x} forEach _nearFood;
            {deleteVehicle _x} forEach _nearWater;
            for "_i" from 0 to (_woodCost - 1) do {deleteVehicle (_nearWood select _i)};
            for "_i" from 0 to (_elecCost - 1) do {deleteVehicle (_nearElec select _i)};
            for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};

            CRATE_FACTORY_FOOD set [_selectedIndex, 100];
            CRATE_FACTORY_WATER set [_selectedIndex, 100];
            CRATE_FACTORY_WOOD set [_selectedIndex, 100];
            CRATE_FACTORY_ELECTRICITY set [_selectedIndex, 100];
            CRATE_FACTORY_METAL set [_selectedIndex, 100];

            systemChat (_factoryType + " Factory #" + str(_selectedIndex + 1) + " resupplied!");
        };

        if (_factoryType == "Powerplant") then {
            _coalCost = _baseCost + 2 + floor(random 3);
            _waterCost = _baseCost + floor(random 3);
            _nearCoal = nearestObjects [_factoryPos, ["Land_PaperBox_closed_F"], 50];
            _nearWater = nearestObjects [_factoryPos, ["Box_IND_Wps_F"], 50];
            _nearMetal = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 50];

            _waterValue = 0;
            {
                _itemCount = _x getVariable ["crateItemCount", 250];
                _waterValue = _waterValue + (_itemCount / 250);
            } forEach _nearWater;

            _missingResources = [];
            if (count _nearCoal < _coalCost) then {_missingResources pushBack ("Coal: " + str(_coalCost))};
            if (_waterValue < _waterCost) then {_missingResources pushBack ("Water: need " + str(_waterCost) + " value, have " + str(floor(_waterValue * 10) / 10))};
            if (count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: " + str(_metalCost))};

            if (count _missingResources > 0) exitWith {
                systemChat ("Missing: " + (_missingResources joinString " | "));
            };

            for "_i" from 0 to (_coalCost - 1) do {deleteVehicle (_nearCoal select _i)};
            {deleteVehicle _x} forEach _nearWater;
            for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};

            CRATE_FACTORY_COAL set [_selectedIndex, 100];
            CRATE_FACTORY_WATER set [_selectedIndex, 100];
            CRATE_FACTORY_METAL set [_selectedIndex, 100];

            systemChat (_factoryType + " Factory #" + str(_selectedIndex + 1) + " resupplied!");
        };

        if (_factoryType == "Vehicle") then {
            _elecCost = _baseCost + 1 + floor(random 3);
            _nearElec = nearestObjects [_factoryPos, ["Land_PortableServer_01_sand_F"], 50];
            _nearMetal = nearestObjects [_factoryPos, ["Land_CargoBox_V1_F"], 50];

            _missingResources = [];
            if (count _nearElec < _elecCost) then {_missingResources pushBack ("Elec: " + str(_elecCost))};
            if (count _nearMetal < _metalCost) then {_missingResources pushBack ("Metal: " + str(_metalCost))};

            if (count _missingResources > 0) exitWith {
                systemChat ("Missing: " + (_missingResources joinString " | "));
            };

            for "_i" from 0 to (_elecCost - 1) do {deleteVehicle (_nearElec select _i)};
            for "_i" from 0 to (_metalCost - 1) do {deleteVehicle (_nearMetal select _i)};

            CRATE_FACTORY_ELECTRICITY set [_selectedIndex, 100];
            CRATE_FACTORY_METAL set [_selectedIndex, 100];

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
                _taskTimer = CRATE_FACTORY_TASK_TIMER select _factoryIndex;
                _hasTask = CRATE_FACTORY_TASK_PENDING select _factoryIndex;
                if (!_hasTask && _taskTimer > 0) then {
                    _taskTimer = _taskTimer - 0.5;
                    CRATE_FACTORY_TASK_TIMER set [_factoryIndex, _taskTimer];
                    if (_taskTimer <= 0) then {
                        _playerNearby = (player distance2D _factoryPos < 400);
                        if (_playerNearby) then {
                            _allTasks = call BIS_fnc_taskChildren;
                            _existingTasks = [];
                            {
                                _taskPos = [_x] call BIS_fnc_taskDestination;
                                if (!isNil "_taskPos" && {_taskPos distance2D _factoryPos < 400}) then {
                                    _existingTasks pushBack _x;
                                };
                            } forEach _allTasks;

                            _waitForTask = true;
                            _maxWaitTime = 60;
                            _waitedTime = 0;

                            while {_waitForTask && _waitedTime < _maxWaitTime} do {
                                sleep 1;
                                _waitedTime = _waitedTime + 1;
                                _newTasks = call BIS_fnc_taskChildren;
                                {
                                    _taskPos = [_x] call BIS_fnc_taskDestination;
                                    if (!isNil "_taskPos" && {_taskPos distance2D _factoryPos < 400} && {!(_x in _existingTasks)}) then {
                                        _isCivilian = (random 1 < 0.75);
                                        _taskType = if (_isCivilian) then {"Civilian"} else {"Military"};
                                        CRATE_FACTORY_TASK_PENDING set [_factoryIndex, true];
                                        CRATE_FACTORY_TASK_TYPE set [_factoryIndex, _taskType];
                                        CRATE_FACTORY_TASK_ID set [_factoryIndex, _x];
                                        systemChat format ["Factory %1: %2 task created and tracked!", _factoryIndex + 1, _taskType];
                                        _waitForTask = false;
                                    };
                                } forEach _newTasks;
                            };
                        };

                        _minTime = CRATE_FACTORY_TASK_MIN_TIME select _factoryIndex;
                        _maxTime = CRATE_FACTORY_TASK_MAX_TIME select _factoryIndex;
                        _newTimer = _minTime + random (_maxTime - _minTime);
                        _midpoint = (_minTime + _maxTime) / 2;

                        if (_newTimer < _midpoint) then {
                            _minTime = (_minTime + 3600) min 21600;
                            _maxTime = 21600;
                            systemChat format ["Factory %1: Timer early! Next: %2min-%3min", _factoryIndex + 1, round(_minTime/60), round(_maxTime/60)];
                        } else {
                            _maxTime = (_maxTime - 3600) max 1800;
                            _minTime = 1800;
                            systemChat format ["Factory %1: Timer late! Next: %2min-%3min", _factoryIndex + 1, round(_minTime/60), round(_maxTime/60)];
                        };

                        CRATE_FACTORY_TASK_MIN_TIME set [_factoryIndex, _minTime];
                        CRATE_FACTORY_TASK_MAX_TIME set [_factoryIndex, _maxTime];
                        CRATE_FACTORY_TASK_TIMER set [_factoryIndex, _newTimer];
                    };
                };

                if (_hasTask) then {
                    _taskID = CRATE_FACTORY_TASK_ID select _factoryIndex;
                    _taskState = [_taskID] call BIS_fnc_taskState;
                    if (_taskState == "SUCCEEDED" || _taskState == "FAILED" || _taskState == "CANCELED") then {
                        CRATE_FACTORY_TASK_PENDING set [_factoryIndex, false];
                        CRATE_FACTORY_TASK_TYPE set [_factoryIndex, ""];
                        CRATE_FACTORY_TASK_ID set [_factoryIndex, ""];

                        _fires = CRATE_FACTORY_FIRES select _factoryIndex;
                        {deleteVehicle _x} forEach _fires;
                        CRATE_FACTORY_FIRES set [_factoryIndex, []];
                        CRATE_FACTORY_OPFOR_SPAWNED set [_factoryIndex, false];

                        systemChat format ["Factory %1: Task complete! Morale recovering gradually.", _factoryIndex + 1];
                    } else {
                        _currentMorale = CRATE_FACTORY_MORALE select _factoryIndex;
                        _newMorale = (_currentMorale - 0.00463) max 0;
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
                } else {
                    _currentMorale = CRATE_FACTORY_MORALE select _factoryIndex;
                    _newMorale = (_currentMorale + 0.00278) min 100;
                    CRATE_FACTORY_MORALE set [_factoryIndex, _newMorale];
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

                            if (_crateType == "Box_IND_AmmoVeh_F") then {
                                clearItemCargoGlobal _crate;
                                _crate addItemCargoGlobal ["ACE_MRE_ChickenTikkaMasala", 250];
                                _crate setVariable ["crateItemCount", 250, true];
                                _crate setVariable ["crateItemType", "food", true];
                                _crate setVariable ["droppedItems", [], true];
                                _crate setVariable ["nextDropTime", time + (300 + random 600), true];
                                FOOD_WATER_CRATES pushBack _crate;
                            };
                            if (_crateType == "Box_IND_Wps_F") then {
                                clearItemCargoGlobal _crate;
                                _crate addItemCargoGlobal ["ACE_WaterBottle", 250];
                                _crate setVariable ["crateItemCount", 250, true];
                                _crate setVariable ["crateItemType", "water", true];
                                _crate setVariable ["droppedItems", [], true];
                                _crate setVariable ["nextDropTime", time + (300 + random 600), true];
                                FOOD_WATER_CRATES pushBack _crate;
                            };

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

                                if (_crateType == "B_Slingload_01_Fuel_F") then {
                                    [_crate, 100] call ace_refuel_fnc_setFuel;
                                };
                                if (_crateType == "B_Slingload_01_Ammo_F") then {
                                    [_crate, 50] call ace_rearm_fnc_setSupplyCount;
                                };

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
        CRATE_FACTORY_FIRES deleteAt _selectedIndex;
        CRATE_FACTORY_MORALE deleteAt _selectedIndex;
        CRATE_FACTORY_TASK_PENDING deleteAt _selectedIndex;
        CRATE_FACTORY_TASK_TYPE deleteAt _selectedIndex;
        CRATE_FACTORY_TASK_ID deleteAt _selectedIndex;
        CRATE_FACTORY_TASK_TIMER deleteAt _selectedIndex;
        CRATE_FACTORY_TASK_MIN_TIME deleteAt _selectedIndex;
        CRATE_FACTORY_TASK_MAX_TIME deleteAt _selectedIndex;
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
        CRATE_FACTORY_FIRES = [];
        CRATE_FACTORY_MORALE = [];
        CRATE_FACTORY_TASK_PENDING = [];
        CRATE_FACTORY_TASK_TYPE = [];
        CRATE_FACTORY_TASK_ID = [];
        CRATE_FACTORY_TASK_TIMER = [];
        CRATE_FACTORY_TASK_MIN_TIME = [];
        CRATE_FACTORY_TASK_MAX_TIME = [];
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
                        _comboType lbSetData [0, "Box_IND_AmmoVeh_F"];
                        _comboType lbAdd "Water";
                        _comboType lbSetData [1, "Box_IND_Wps_F"];
                        _comboType lbAdd "Wood";
                        _comboType lbSetData [2, "Land_WoodPile_03_F"];
                    };
                    if (_factoryType == "Powerplant") then {
                        _comboType lbAdd "Energy";
                        _comboType lbSetData [0, "Land_PortableServer_01_sand_F"];
                        _comboType lbAdd "Electronics";
                        _comboType lbSetData [1, "Land_PaperBox_01_open_boxes_F"];
                        _comboType lbAdd "Fuel";
                        _comboType lbSetData [2, "B_Slingload_01_Fuel_F"];
                        _comboType lbAdd "Ammo";
                        _comboType lbSetData [3, "B_Slingload_01_Ammo_F"];
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
                        _comboType lbAdd "Gunpowder (75min)";
                        _comboType lbSetData [4, "Land_Pallet_MilBoxes_F"];
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
                            _costText = "<t size='0.8'>Cost:<br/>3 Food | 3 Water<br/>5 Wood</t>";
                        };
                    };

                    if (_factoryType == "Mineral") then {
                        _costText = "<t size='0.8'>Cost:<br/>8 Food | 10 Water<br/>15 Wood</t>";
                    };

                    if (_factoryType == "Pier") then {
                        _costText = "<t size='0.8'>Cost:<br/>10 Food | 12 Water<br/>18 Wood</t>";
                    };

                    if (_factoryType == "Powerplant") then {
                        _costText = "<t size='0.7'>Cost:<br/>10F 10W 15Wood 15Metal 20Coal<br/>5 Iron | 5 Fish</t>";
                    };

                    if (_factoryType == "Vehicle") then {
                        _costText = "<t size='0.65'>Cost:<br/>12F 12W 20Wood 30Metal 15Coal 25Energy<br/>10Iron 5Diamonds 8Fish 8Oil 5Gold 10Electronics</t>";
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

// Background monitoring for Food/Water crates - Rain damage and item dropping
[] spawn {
    while {true} do {
        sleep 5;
        FOOD_WATER_CRATES = FOOD_WATER_CRATES select {!isNull _x};
        {
            _crate = _x;
            _itemCount = _crate getVariable ["crateItemCount", 250];
            _itemType = _crate getVariable ["crateItemType", "food"];
            _cratePos = getPosATL _crate;

            // Rain damage
            if (rain > 0.1 && _itemCount > 0) then {
                _damageAmount = floor(1 + (rain * 2));
                _newCount = (_itemCount - _damageAmount) max 0;
                _crate setVariable ["crateItemCount", _newCount, true];
                if (_itemType == "food") then {
                    clearItemCargoGlobal _crate;
                    if (_newCount > 0) then {
                        _crate addItemCargoGlobal ["ACE_MRE_ChickenTikkaMasala", _newCount];
                    };
                } else {
                    clearItemCargoGlobal _crate;
                    if (_newCount > 0) then {
                        _crate addItemCargoGlobal ["ACE_WaterBottle", _newCount];
                    };
                };
            };

            // Random item dropping
            _nextDropTime = _crate getVariable ["nextDropTime", 0];
            _droppedItems = _crate getVariable ["droppedItems", []];
            _droppedItems = _droppedItems select {!isNull _x};
            _crate setVariable ["droppedItems", _droppedItems, true];

            if (time >= _nextDropTime && count _droppedItems < 15 && _itemCount > 0) then {
                _dropClass = if (_itemType == "food") then {"Land_FoodSack_01_full_brown_idap_F"} else {"Land_WaterBottle_01_pack_F"};
                _randomDist = 3 + random 8;
                _randomAngle = random 360;
                _dropPos = [(_cratePos select 0) + (_randomDist * cos _randomAngle), (_cratePos select 1) + (_randomDist * sin _randomAngle), 0];
                _droppedItem = _dropClass createVehicle _dropPos;
                _droppedItem setPos _dropPos;
                _droppedItem setVariable ["parentCrate", _crate, true];
                _droppedItem setVariable ["itemType", _itemType, true];
                _droppedItems pushBack _droppedItem;
                _crate setVariable ["droppedItems", _droppedItems, true];
                _crate setVariable ["nextDropTime", time + (180 + random 420), true];
                DROPPED_ITEMS_GLOBAL pushBackUnique _droppedItem;

                // Remove items from crate when dropping
                _removeAmount = 1 + floor(random 3);
                _newCount = (_itemCount - _removeAmount) max 0;
                _crate setVariable ["crateItemCount", _newCount, true];
                if (_itemType == "food") then {
                    clearItemCargoGlobal _crate;
                    if (_newCount > 0) then {
                        _crate addItemCargoGlobal ["ACE_MRE_ChickenTikkaMasala", _newCount];
                    };
                } else {
                    clearItemCargoGlobal _crate;
                    if (_newCount > 0) then {
                        _crate addItemCargoGlobal ["ACE_WaterBottle", _newCount];
                    };
                };
            };
        } forEach FOOD_WATER_CRATES;
    };
};

// Pickup and return system with visual lines
[] spawn {
    while {true} do {
        sleep 0.1;
        DROPPED_ITEMS_GLOBAL = DROPPED_ITEMS_GLOBAL select {!isNull _x};
        
        {
            _item = _x;
            _itemPos = getPosATL _item;
            _playerPos = getPosATL player;
            _parentCrate = _item getVariable ["parentCrate", objNull];
            
            if (_playerPos distance2D _itemPos < 2 && isNull PLAYER_CARRYING_ITEM) then {
                _item setVariable ["nearPlayer", true, true];
                if (!(_item getVariable ["hasPickupAction", false])) then {
                    _pickupAction = player addAction [
                        "<t color='#00ff00'>Pick up item</t>",
                        {
                            params ["_target", "_caller", "_actionId", "_item"];
                            PLAYER_CARRYING_ITEM = _item;
                            _item attachTo [player, [0, 0.5, 0.5]];
                            _item setVariable ["pickedUp", true, true];
                            player removeAction _actionId;
                            _item setVariable ["hasPickupAction", false, true];
                        },
                        _item,
                        1.5,
                        true,
                        true,
                        "",
                        "true",
                        2
                    ];
                    _item setVariable ["pickupActionId", _pickupAction, true];
                    _item setVariable ["hasPickupAction", true, true];
                };
            } else {
                if (_item getVariable ["hasPickupAction", false]) then {
                    _actionId = _item getVariable ["pickupActionId", -1];
                    if (_actionId >= 0) then {
                        player removeAction _actionId;
                    };
                    _item setVariable ["hasPickupAction", false, true];
                };
            };
            
            if (!isNull PLAYER_CARRYING_ITEM && PLAYER_CARRYING_ITEM == _item && !isNull _parentCrate) then {
                
                if (_playerPos distance2D _cratePos < 2) then {
                    if (!(_item getVariable ["hasReturnAction", false])) then {
                        _returnAction = player addAction [
                            "<t color='#00ff00'>Return item to crate</t>",
                            {
                                params ["_target", "_caller", "_actionId", "_args"];
                                _item = _args select 0;
                                _crate = _args select 1;
                                detach _item;
                                deleteVehicle _item;
                                PLAYER_CARRYING_ITEM = objNull;
                                
                                _droppedItems = _crate getVariable ["droppedItems", []];
                                _droppedItems = _droppedItems - [_item];
                                _crate setVariable ["droppedItems", _droppedItems, true];
                                DROPPED_ITEMS_GLOBAL = DROPPED_ITEMS_GLOBAL - [_item];
                                
                                _itemCount = _crate getVariable ["crateItemCount", 0];
                                _itemType = _crate getVariable ["crateItemType", "food"];
                                _returnAmount = 1 + floor(random 3);
                                _newCount = (_itemCount + _returnAmount) min 250;
                                _crate setVariable ["crateItemCount", _newCount, true];
                                if (_itemType == "food") then {
                                    clearItemCargoGlobal _crate;
                                    _crate addItemCargoGlobal ["ACE_MRE_ChickenTikkaMasala", _newCount];
                                } else {
                                    clearItemCargoGlobal _crate;
                                    _crate addItemCargoGlobal ["ACE_WaterBottle", _newCount];
                                };
                                
                                player removeAction _actionId;
                                _item setVariable ["hasReturnAction", false, true];
                                systemChat "Item returned to crate!";
                            },
                            [_item, _parentCrate],
                            1.5,
                            true,
                            true,
                            "",
                            "true",
                            2
                        ];
                        _item setVariable ["returnActionId", _returnAction, true];
                        _item setVariable ["hasReturnAction", true, true];
                    };
                } else {
                    if (_item getVariable ["hasReturnAction", false]) then {
                        _actionId = _item getVariable ["returnActionId", -1];
                        if (_actionId >= 0) then {
                            player removeAction _actionId;
                        };
                        _item setVariable ["hasReturnAction", false, true];
                    };
                };
            };
        } forEach DROPPED_ITEMS_GLOBAL;
    };
};

// Draw lines from player to crate when carrying items
addMissionEventHandler ["Draw3D", {
    if (!isNull PLAYER_CARRYING_ITEM) then {
        _parentCrate = PLAYER_CARRYING_ITEM getVariable ["parentCrate", objNull];
        if (!isNull _parentCrate) then {
            _playerPos = getPosATL player;
            _cratePos = getPosATL _parentCrate;
            if (_playerPos distance2D _cratePos < 15) then {
                drawLine3D [_playerPos, _cratePos, [0, 1, 0, 0.5]];
            };
        };
    };
}];
