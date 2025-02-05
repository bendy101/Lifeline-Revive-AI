waitUntil {time > 0}; //this pauses until actual game starts.
diag_log "                                                                                   			               '"; 
diag_log "============================================================================================================='";
diag_log "==================================================== MOD ===================================================='";
diag_log "================================================== init.sqf ================================================='";
diag_log "============================================================================================================='";
diag_log "============================================================================================================='";

if (isServer) then {
		if (!isNil "actionLifelineID1") then {player removeAction actionLifelineID1};
		if (!isNil "actionLifelineID2") then {player removeAction actionLifelineID2};
		if (!isNil "actionLifelineID3") then {player removeAction actionLifelineID3};
		if (!isNil "actionLifelineID3") then {player removeAction actionLifelineID4};

	// Lifeline_launchScript = "\Lifeline_Revive\fix_other_revive_sys.sqf"; 
	Lifeline_launchScript = "\Lifeline_Revive\scripts\fix_other_revive_systems.sqf"; 	
	Lifeline_cancel = false;

	_players = allPlayers - entities "HeadlessClient_F";

	Lifeline_Side = side (_players select 0);
	// _scope1count = count (allunits select {isplayer leader _x && simulationEnabled _x});
	_scope1count = count (allunits select {group _x == group player && simulationEnabled _x && rating _x > -2000});
	_scope2count = count (allunits select {(side (group _x) == Lifeline_Side) && simulationEnabled _x && rating _x > -2000});
	_scope3count = count (allunits select {(side (group _x) == Lifeline_Side) && simulationEnabled _x  && (_x in playableUnits) && rating _x > -2000});

	//add leading zeros for neat text
	_scope1count = ((if (_scope1count < 100) then {"0"} else {""}) + (if (_scope1count < 10) then {"0"} else {""}) + str _scope1count);
	_scope2count = ((if (_scope2count < 100) then {"0"} else {""}) + (if (_scope2count < 10) then {"0"} else {""}) + str _scope2count);
	_scope3count = ((if (_scope3count < 100) then {"0"} else {""}) + (if (_scope3count < 10) then {"0"} else {""}) + str _scope3count);

	// if (isServer) then {

	Lifelinestartedscript = false;
	publicVariable "Lifelinestartedscript";

	LifelineremoveactionmenuIDs = {		
		if (Lifeline_cancel == false) then {
			Lifeline_launchScript remoteExec ["execVM",0,true];
			// Lifeline_launchScript remoteExec ["execVM",allPlayers,true];
		};
		if (!isNil "actionLifelineID1") then {player removeAction actionLifelineID1};
		if (!isNil "actionLifelineID2") then {player removeAction actionLifelineID2};
		if (!isNil "actionLifelineID3") then {player removeAction actionLifelineID3};
		player removeAction actionLifelineID4;
		Lifelinestartedscript = true;
	};

	if (Lifeline_Scope_CBA == 4 || Lifeline_Scope_CBA == 1) then {
		actionLifelineID1 = player addAction [format ["<t size='1.5' color='#DAF7A6'>Start Lifeline Revive | </t><t size='1.5' color='#00FF0A'>%1 units</t><t size='1.5' color='#DAF7A6'> | Group</t>",_scope1count], {hint "..initializing";Lifeline_Scope=1;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
	};
	if (Lifeline_Scope_CBA == 4 || Lifeline_Scope_CBA == 2) then {
		actionLifelineID2 = player addAction [format ["<t size='1.5' color='#DAF7A6'>Start Lifeline Revive | </t><t size='1.5' color='#00FF0A'>%1 units</t><t size='1.5' color='#DAF7A6'> | Side</t>",_scope2count], {hint "..initializing";Lifeline_Scope=2;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
	};
	if ((Lifeline_Scope_CBA == 4 || Lifeline_Scope_CBA == 3) && isMultiplayer) then {
		actionLifelineID3 = player addAction [format ["<t size='1.5' color='#DAF7A6'>Start Lifeline Revive | </t><t size='1.5' color='#00FF0A'>%1 units</t><t size='1.5' color='#DAF7A6'> | Side Playable Slots</t>",_scope3count], {hint "..initializing";Lifeline_Scope=3;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
	};

	actionLifelineID4 = player addAction ["<t size='1.5' color='#FF5733'>Cancel Lifeline Revive</t>", {Lifeline_cancel = true;[] call LifelineremoveactionmenuIDs;}];

	//remind host player to start or cancel Lifeline Revive
	[] spawn {
		sleep 600;
		if (Lifelinestartedscript == false) then {	 
			["Please start Lifeline Revive. Scroll the mouse wheel to choose. ", "Lifeline Revive: please start or cancel", true, false] call BIS_fnc_guiMessage;  	
		};
	};

}; //if (isServer) then {

