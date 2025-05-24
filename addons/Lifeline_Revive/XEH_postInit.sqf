diag_log "                                                                                   			               '"; 
diag_log "============================================================================================================='";
diag_log "==================================================== MOD ===================================================='";
diag_log "============================================= XEH_postInit.sqf =============================================='";
diag_log "============================================================================================================='";
diag_log "============================================================================================================='";

if !(Lifeline_revive_enable) exitWith {diag_log "1. nnnnnnnnnnnnnnnnnnnnnn MOD DISABLED. EXIT. nnnnnnnnnnnnnnnnnnnnnnn'";};

if (Lifeline_ACEcheck_ == true) then {
	diag_log format ["kkkkkkkkkkkkkkkkkkkkkkkkkkkk ACE oldACE var = %1 kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk'", oldACE];
};

diag_log format ["kkkkkkkkkkkkkkkkkkkkkkkkkkkk ACE Lifeline_ACEcheck_ var = %1 kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk'", Lifeline_ACEcheck_];

player setVariable ["tcb_ais_aisInit",true];

_players = allPlayers - entities "HeadlessClient_F";
Lifeline_Side = side (_players select 0);

	{
		_x setVariable ["tcb_ais_aisInit",true];
	} foreach (allunits select {(simulationEnabled _x)});

// check for ACE medical
if (isClass (configFile >> "cfgPatches" >> "ace_medical")) then {

	diag_log "+++++++++++ACE MEDICAL (2ND TIME) +++++++++++++++'";
	_aceversion = [] call ace_common_fnc_getVersion; //unfortunatley gets a string, so need to parse below
	_aceversionarr = _aceversion splitString ".";
	aceversion = (_aceversionarr select 1) + "." +  (_aceversionarr select 2);
	aceversion = parseNumber aceversion;

	if (aceversion >= 16) then {
		oldACE = false;
		fix_medical_fnc_deserializeState = compile preprocessFile "Lifeline_Revive\scripts\ace\fnc_deserializeState3.16.sqf";
	} else {
		oldACE = true;
		fix_medical_fnc_deserializeState = compile preprocessFile "Lifeline_Revive\scripts\ace\fnc_deserializeState3.15.sqf";
	};

} else {

	oldACE = nil;

	diag_log "=====kkkkkkkkkkkkkkkkkkkkkkkkkkk NO ACE MEDICAL kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk===='";
};

//check for SOG AI 
if (isClass (configFile >> "cfgPatches" >> "JBOY_SOGAI_mod")) then {
	diag_log "XEH_postInit.sqf +++++++++++ SOG AI DETECTED +++++++++++++++'";
	[] spawn {
		waitUntil {(!isNil "jboy_medicStart")};
		jboy_medicStart = compile preprocessFileLineNumbers ("");
		if (Lifeline_SOGAI_orangetrian == false) then {
			waitUntil {isNil {missionNameSpace getVariable "JBOY_showInjuredIcon"}};
			missionNameSpace setVariable ["JBOY_showInjuredIcon", false];
		};

	};
};

taofoldingmap = 0;

if (isClass (configFile >> "cfgPatches" >> "htfm")) then {
	taofoldingmap = 1;
};

if (isClass (configFile >> "cfgPatches" >> "tao_rewrite_main")) then {
	taofoldingmap = 2;
};

[] execvm "Lifeline_Revive\init.sqf";
[] execvm "Lifeline_Revive\initserver.sqf";

