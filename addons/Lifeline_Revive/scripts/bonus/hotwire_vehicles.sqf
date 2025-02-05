diag_log "============================================================================================================='";
diag_log "============================================================================================================='";
diag_log "========================================== hotwire_vehicles.sqf ==========================================='";
diag_log "============================================================================================================='";
diag_log "============================================================================================================='";

Lifeline_check_glass_windows = {
	params ["_unit"];
	_hasGlass = false;

	 // Example hit points commonly associated with glass 
	_glassHitPoints = selectionNames _unit;

	{
	// if (toLower _x find "glass_1" >= 0 || toLower _x find "glass_2" >= 0) then {
		if (toLower _x find "glass_1" >= 0 || toLower _x find "glass_2" >= 0 || toLower _x find "glass2" >= 0 || toLower _x find "glass3" >= 0) then {
			_hasGlass = true;
		};
	} forEach _glassHitPoints;
	_hasGlass
};

// another method 
Lifeline_check_glass_windows_hp = {
	params ["_unit"];
	_hasGlass = false;

	// Example hit points commonly associated with glass 
	_glassHitPoints = getAllHitPointsDamage _unit select 0;

	{
	// if (toLower _x find "glass_1" >= 0 || toLower _x find "glass_2" >= 0) then {
		if (toLower _x find "hitglass_1" >= 0 || toLower _x find "hitglass_2" >= 0 || toLower _x find "hitglass1" >= 0 || toLower _x find "hitglass2" >= 0) then {
			_hasGlass = true;
		};
	} forEach _glassHitPoints;
	_hasGlass
};

Lifeline_check_smashed_windows2 = {
	params ["_unit"];
	_isSmashed = false;
	_hitPointsData = getAllHitPointsDamage _unit; // get all hit points damage data 

	// Extract the arrays 
	_hitParts = _hitPointsData select 0; // Array of hit part names 
	// _hitPartPoints = _hitPointsData select 1; // Array of hit point names 
	_hitDamages = _hitPointsData select 2; // Array of hit part damage values 

	// Loop through the damage values to find those with damage = 1 
	{
		_index = _forEachIndex;
		_damage = _x;

		if (_damage > 0.5) then {
			if (toLower (_hitParts select _index) find "glass" >= 0) then {
				_isSmashed = true;
			};
		};
	} forEach _hitDamages;
	_isSmashed
};

Lifeline_check_smashed_windowsff = {
	params ["_unit"];
	_hitPointsData = getAllHitPointsDamage _unit; // get all hit points damage data  

	// Extract the arrays  
	_hitParts = _hitPointsData select 0; // Array of hit part names  
	_hitDamages = _hitPointsData select 2; // Array of hit part damage values  

	_glassBroken = false; // Initialize flag  

	{
		_index = _forEachIndex;
		_hitPart = _hitParts select _index;
		_damage = _hitDamages select _index;

			// Check if the hit part is glass  
		if (toLower _hitPart find "glass" >= 0) then {
			// get the hit point class name from the config  
			_hitPointConfigPath = configFile >> "CfgVehicles" >> (typeOf _unit) >> "HitPoints" >> _hitPart;

				// Get the "armor" value (damage threshold to consider it broken)  
			_breakThreshold = getNumber (_hitPointConfigPath >> "armor");

				// if the current damage is greater than or equal to the threshold  
			if (_damage >= _breakThreshold) then {
				_glassBroken = true;
			};
		};
	} forEach _hitParts;

	_glassBroken
};

Lifeline_check_smashed_windows = {
	params ["_unit"];

	_hitPointsData = getAllHitPointsDamage _unit; // get all hit points damage data  

	// Extract the arrays  
	_hitParts = _hitPointsData select 0; // Array of hit part names  
	_hitDamages = _hitPointsData select 2; // Array of hit part damage values  

	_glassBroken = false; // Initialize flag  

	{
		_index = _forEachIndex;
		_hitPart = _hitParts select _index;
		_damage = _hitDamages select _index;

			// Check if the hit part is glass  
		if (toLower _hitPart find "glass" >= 0) then {
			// if the current damage is greater than or equal to the threshold  
			if (_damage > 0.9) then {
				_glassBroken = true;
			};
		};
	} forEach _hitParts;
	_glassBroken
};

Lifeline_check_toolkit = {
	params ["_unit"];
	_hasToolKit = false;
	{
		if (toLower _x find "toolkit" >= 0 || toLower _x find "repairkit" >= 0) then {
			_hasToolKit = true;
		};
	} forEach (items _unit);

	_hasToolKit
};

Lifeline_hotwire_hint = {
	_counter = 8;
	_diagtext = "hotwiring";
	while {_counter > 0} do {
		hintsilent _diagtext;
		_diagtext = _diagtext + ".";
		_counter = _counter - 1;
		sleep 1;
		};	 
}; 
Lifeline_hotwire_addvehicles = {

	// loop thru all vehicles in mission 
	{
			_vehicleArmor = getNumber (configFile >> "Cfgvehicles" >> (typeOf _x) >> "armor");
			_haswindows = [_x] call Lifeline_check_glass_windows;
			// _haswindows = [_x] call Lifeline_check_glass_windows_hp; 

			if (((_haswindows == true && _vehicleArmor <= 200) || _vehicleArmor <= 80 && _haswindows == false) && !(_x isKindOf "Tank")) then {
				_x addAction ["Hotwire Vehicle", {
					params ["_target", "_caller"];

					_haswindows = [cursorObject] call Lifeline_check_glass_windows;
					_isSmashed = [cursorObject] call Lifeline_check_smashed_windows;
					_hasToolKit = [_caller] call Lifeline_check_toolkit;

					if (_isSmashed == true || _haswindows == false) then {
						if (_hasToolKit) then {
							[] call  Lifeline_hotwire_hint;
							_target lock 0;
							hint "Successfully Hotwired.";
							if (fuel cursorObject == 1) then {
								cursorObject setFuel (random 1);
							};
						} else {
							hint "Can't hotwire without a toolkit.";
						};
					} else {
						if (_hasToolKit) then {
							hint "You need to break in.\nSmash the window first."; 
						} else {
							hint "Can't hotwire without a toolkit.\nYou also need to break in.";
						};
					};
				}, [], 8, false, true, "",
				"_this distance cursorObject < 3.5 && ((locked cursorObject) in [2, 3, -1])"
				];
			};
	} forEach vehicles;

};

[] call Lifeline_hotwire_addvehicles;