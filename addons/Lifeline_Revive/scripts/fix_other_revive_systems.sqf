diag_log "                                                                                                '"; 
diag_log "                                                                                                '"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 
diag_log "====================================== fix_other_revive_systems.sqf ========================================='"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 

// _cnt = 1;
// while {_cnt > 0} do {
// 	hint format ["WIP countdown: %1", _cnt];
// 	_cnt = _cnt - 1;
// 	sleep 1;
// };

[] execvm "Lifeline_Revive\scripts\StartActionMenu.sqf";

Lifeline_mod_dedi = false;

if (Lifeline_mod && !hasInterface) then {
	Lifeline_mod_dedi = true;
	publicVariable "Lifeline_mod_dedi";
	[2, "++++++++++++++++++++++++ DEDICATED MOD SERVER +++++++++++++++++++++++++"] remoteExec ["diag_log", 0];
};

// just for the Arma 3 hint "Lifeline Revive X of y units" message.
if (Lifeline_added_units == 0) then {
	Lifeline_added_units_hint_trig = false;
} else {
	Lifeline_added_units_hint_trig = true;
};

if (hasInterface) then {
// Wait for mission to start AND player to be in game
	waitUntil {
		sleep 0.3;
		!isNull player && 
		{time > 0} && 
		{!isNull (findDisplay 46)} && 
		{alive player}
	};

} else {
	//pause until game started
	waitUntil {time > 0}; 
};

// Check if Antistasi mod is loaded
Lifeline_antistasiLoaded = false;

// Method 1: Check for a specific class from Antistasi
if (isClass (configFile >> "CfgPatches" >> "A3A_core")) then {
    Lifeline_antistasiLoaded = true;
};

// Method 2: Alternative check for Antistasi
if (!Lifeline_antistasiLoaded && {isClass (configFile >> "A3A" >> "Events")}) then {
    Lifeline_antistasiLoaded = true;
};

// Method 3: Check for Antistasi functions
if (!Lifeline_antistasiLoaded && {!isNil "A3A_fnc_initServer"}) then {
    Lifeline_antistasiLoaded = true;
};

if (Lifeline_antistasiLoaded) then {
    // Your Antistasi compatibility code here
} else {
    // Regular initialization code
};

// Detect if a DRO mission is running
if (((toLower missionName) find "dynamic recon ops") != -1 
|| ((toLower missionName) find "dynamic%20combat%20ops") != -1 
|| ((toLower missionName) find "dynamic%20recon%20ops") != -1) then { 
	waitUntil {(missionNameSpace getVariable "lobbyComplete") == 1}; 
	waitUntil {!(isNil "newUnitsReady")};
	waitUntil {(newUnitsReady == true)};
	reviveDisabled = 3;
	waitUntil {(missionNameSpace getVariable "playersReady") == 1}; 
};

// wait for players 
waitUntil {count (allPlayers - entities "HeadlessClient_F") >0};

Lifeline_ASmission = false;

if (isServer && Lifeline_antistasiLoaded && (((toLower missionName) find "antistasi") != -1) == true) then {
    waitUntil {
        !isNil "theBoss" &&
        !isNil "A3A_Events_fnc_addEventListener" &&
        !isNil "A3A_fnc_initServer" &&
        !isNil "A3A_fnc_initClient" &&
        !isNil "A3A_fnc_patrolInit" &&
        !isNil "A3A_fnc_loadPlayer" &&
        !isNil "A3A_fnc_scheduler"
    };
	Lifeline_ASmission = true;
    sleep 5;
};

[] execvm "Lifeline_Revive\scripts\Lifeline_Debugging.sqf"; 

// these functions here for text aligned on right edge of screen according to screen resolution.
Lifeline_get_right_align = {
	((safeZoneW - 1) * 0.48)
};

Lifeline_right_align = [] call Lifeline_get_right_align;

Lifeline_display_textright = {
	params ["_text","_ypos","_sec"];
	// [_text,Lifeline_right_align,_ypos,_sec,2,0,_layer] spawn BIS_fnc_dynamicText;	
	[_text,Lifeline_right_align,_ypos,_sec,0,0,Lifelinetxt2Layer] spawn BIS_fnc_dynamicText;	
};

Lifeline_display_textright2 = {
	params ["_text","_ypos","_sec"];
	[_text,((safeZoneW - 1) * 0.48),_ypos,_sec,0,0,Lifelinetxt1Layer] spawn BIS_fnc_dynamicText;
};

diag_log "===============================START fix_other_revive_systems.sqf==========================='";
if (isNil "oldACE") then {
		Lifeline_ACEcheck_ = false;
	} else {
		Lifeline_ACEcheck_ = true;
};

// GENERIC REMOVAL OF HANDLERS>>> DIRTY METHOD. Only used to override prairie fire so far...
Lifeline_remove_all_handlers_dirty = {
	params ["_unit"];
	_unit removeAllEventHandlers "Killed"; 
	_unit removeAllEventHandlers "Respawn"; 
	_unit removeAllEventHandlers "HandleHeal";
	_unit removeAllEventHandlers "handleDamage";
};

// attempt to remove 3rd part revives AFTER mission load. This method not recomended, use CBA setting to do this before mission for more thourough method.
if (isNil "oldACE" && Lifeline_remove_3rd_pty_revive == false) then {

	_3rdpartyReviveDetected = "";
	//Detect SOG PF REVIVE 
	SOG_ReviveDetected_ = false;
	if (!isNil "vn_advanced_revive_started" && Lifeline_remove_3rd_pty_revive == false) then {
		SOG_ReviveDetected_ = true;
		_3rdpartyReviveDetected = "SOG PF Revive";
	};
	// Detect Sunday Revive
	if (!isNil "rev_AIListen") then {
		_3rdpartyReviveDetected = "Sunday Revive";
	};
	if (!isNil "AIS_Core_3DEHId") then {
		_3rdpartyReviveDetected = "Pscycho's Revive";
		removeMissionEventHandler ["Draw3D", AIS_Core_3DEHId];
		removeMissionEventHandler ["EachFrame", AIS_Core_eachFrameHandlerId];
	};
	if (!isNil "AIS_REVIVE_INIT_UNITS") then {
		_3rdpartyReviveDetected = "Pscycho's Revive";
		// removeMissionEventHandler ["Draw3D", AIS_Core_3DEHId];
		removeMissionEventHandler ["EachFrame", AIS_Core_eachFrameHandlerId];
	};

	if (!isNil "TCB_AIS_PATH") then {
		_3rdpartyReviveDetected = "Pscycho's Revive (old)";
		tcb_fnc_handleDamage = nil;
		tcb_fnc_keyUnbind = nil;
		tcb_fnc_firstAid = nil;
		tcb_fnc_isHealable = nil;
		tcb_fnc_progressBar = nil;
		tcb_fnc_isMedic = nil;
		tcb_fnc_drag = nil;
		tcb_fnc_carry = nil;
		tcb_fnc_drop = nil;
		tcb_fnc_injuredEffects = nil;
		tcb_fnc_progressBarInit = nil;
		tcb_fnc_sendaihealer = nil;
		tcb_fnc_delbody = nil;
		tcb_fnc_quote = nil;
		tcb_fnc_deadcam = nil;
		tcb_fnc_lookingForWoundedMates = nil;
		tcb_fnc_checklauncher = nil;
		tcb_fnc_allowToHeal = nil;
		tcb_fnc_medicEquipment = nil;
		tcb_fnc_setDamage = nil;
		tcb_fnc_arrayPushStack = nil;
		tcb_fnc_garbage = nil;
		tcb_fnc_bloodEffect = nil;
		tcb_fnc_resetBleeding = nil;
		tcb_fnc_setBleeding = nil;
		tcb_fnc_help = nil;
		tcb_fnc_impactEffect = nil;
		tcb_fnc_callHelp = nil;
		tcb_fnc_diary = nil;
		tcb_fnc_removeKits = nil;
		tcb_fnc_restoreKits = nil;	
	};

	//FORCE DISABLE RECENT PSYCHO REVIVE AND PRAIRIE SOG, DIRTY METHOD 
	if (_3rdpartyReviveDetected != "") then {
		{
			if (!isNil "AIS_Core_3DEHId") then {
				if (!isNil "ais_hkEH") then {_x removeEventHandler ["Killed", ais_hkEH]};
				if (!isNil "ais_hdEH") then {_x removeEventHandler ["HandleDamage", ais_hdEH]};
				if (!isNil "ais_hrEH") then {_x removeEventHandler ["Respawn", ais_hrEH]};
				if (!isNil "ais_hhEH") then {_x removeEventHandler ["HandleHeal", ais_hhEH]};
			};
			if (!isNil "TCB_AIS_PATH" || SOG_ReviveDetected_ == true || _3rdpartyReviveDetected == "Sunday Revive") then {
				if (local _x) then {
					_x call Lifeline_remove_all_handlers_dirty;
				} else {
					_x remoteExec ["Lifeline_remove_all_handlers_dirty"];
				};
			};
		} foreach (allunits select {isplayer leader _x && simulationEnabled _x});
	};

	// FORCE DISABLE Farooq Revive
	// Overwrite player initialization.
	far_player_init = compileFinal "";
	[{!isNil "far_debugging"}, {
	_3rdpartyReviveDetected = "Farooq Revive";
		far_isDragging = nil;  // Disable "Drag & Carry animation fix" loop - cannot be killed because spawned while true.
		far_muteRadio = nil;   // Disable initialization hint.
		far_muteACRE = nil;    // Same, but for very old versions.
		far_debugging = false; // Disable adding event handlers to AI in SP.
	}, [], 5] call CBA_fnc_waitUntilAndExecute;

	if (_3rdpartyReviveDetected != "" && isServer) then {
	[_3rdpartyReviveDetected] spawn {
	params ["_3rdpartyReviveDetected"]; 
	diag_log format ["A revive system already exists: %1.  
		It is best to restart the mission and turn it off, usually located in the parameters (player slot screen, top right corner).  
	If this option does not exist, then Lifeline Revive can attempt to kill it on load. Mostly works but not fully tested.", _3rdpartyReviveDetected];  
	private _yoresult = [format ["A revive system already exists: %1.  
		It is best to restart the mission and turn it off, usually located in the parameters (player slot screen, top right corner).  
		If this option does not exist, then Lifeline Revive can attempt to kill it on load. Mostly works but not fully tested.", _3rdpartyReviveDetected], "revive system already exists", true, false] call BIS_fnc_guiMessage;  
		};
	};

}; // if (isNil "oldACE" && Lifeline_remove_3rd_pty_revive == false) then {

// if (isNil "oldACE") then {

	_players = allPlayers - entities "HeadlessClient_F";
	Lifeline_Side = side (_players select 0);

	// FORCE DISABLE BI Revive for Lifeline_RevMethod 2. (this works. I could not get the global turnoff working.)
	BI_ReviveDetected_ = getMissionConfigValue ["ReviveMode", 0]; 
	if (hasInterface) then {
		if ((player call BIS_fnc_reviveEnabled) == true) then {BI_ReviveDetected_ = 1};
	};

	//remove BI revive
	if !(isDedicated && hasInterface) then {
		if (player call BIS_fnc_reviveEnabled) then {  
				[player] call BIS_fnc_disableRevive;
		};
		sleep 0.1;
		//again remove damage handler locally
		// player removeAllEventHandlers "handleDamage";
		// [format ["%1 !!!!!!!!! REMOVE ALL DAMAGE HANDLERS PLAYER !!!!!!!!!!!!!", name player]] remoteExec ["diag_log", 2];
	};

	if (BI_ReviveDetected_ == 0) then {
	};

    // ==========DETECT MISSION TYPE WITH HINT AT START

		 _text = ""; 
		 _tickets = 0; 
		 _colour = "14d145"; 

		 if (teamSwitchEnabled == true) then { 
		 _text = "This is a teamswitch mission."; 
		 }; 

		 BI_RespawnDetected = getMissionConfigValue ["Respawn", 0]; 
		  // can be stored also as a string, convert to number if so.
		 	if (typeName BI_RespawnDetected == "STRING") then { 
			  if (BI_RespawnDetected == "NONE") exitWith {BI_RespawnDetected = 0}; 			 
			  if (BI_RespawnDetected == "BIRD") exitWith {BI_RespawnDetected = 1}; 
			  if (BI_RespawnDetected == "INSTANT") exitWith {BI_RespawnDetected = 2}; 
			  if (BI_RespawnDetected == "BASE") exitWith {BI_RespawnDetected = 3}; 
			  if (BI_RespawnDetected == "GROUP") exitWith {BI_RespawnDetected = 4}; 
			  if (BI_RespawnDetected == "SIDE") exitWith {BI_RespawnDetected = 5}; 
			}; 

		if (hasInterface) then {

		 if (typeName BI_RespawnDetected == "SCALAR") then { 
			  if (BI_RespawnDetected == 0) then { 
				  _text = "No respawn. This is a realism mission."; 
			  }; 			 
			  if (BI_RespawnDetected == 1) then { 
				  _text = "No respawn. This is a realism mission."; 
			  }; 
			  if (BI_RespawnDetected == 2) then { 
					_tickets = [player, nil, true] call BIS_fnc_respawnTickets;
					if (_tickets != -1) then { 
					_text = format ["This is a respawn mission. %1 respawns.", _tickets];  
					} else { _text = "This is a respawn mission.";}; 
			  }; 
			  if (BI_RespawnDetected == 3) then { 
					_tickets = [player, nil, true] call BIS_fnc_respawnTickets;
					if (_tickets != -1) then { 
					_text = format ["This is a respawn mission. %1 respawns.", _tickets];  
					} else { _text = "This is a respawn mission.";}; 
			  }; 
			  if (BI_RespawnDetected == 4) then { 
				  // _text = "This is a teamswitch at death mission."; 
				  // _text = "No respawn, instead teamswitch at death."; 
				  // _text = "Teamswitch instead of respawn. Only at death.";
				  _text = "Teamswitch instead of respawn. Only when KIA.";
				  // _text = "Respawn is teamswitch at death."; 
			  }; 
			  if (BI_RespawnDetected == 5) then { 
				  // _text = "Teamswitch mission. Switch anytime and at death.";  
				  // _text = "Teamswitch instead of respawn. Anytime and at death.";  
				  // _text = "Teamswitch instead of respawn. Anytime manually and when KIA.";  
				  _text = "Teamswitch instead of respawn. Manually or when KIA.";  
				  // _text = "Respawn is teamswitch. Any time and at death.";  
			  }; 
		 }; 
		_modtext = "Lifeline Revive | Detection of mission settings:"; 	

		 if (_text != "") then { 		  	
			// _textformat = format ["<t align='right' size='%3' color='#%1'>%2</t>",_colour,_text, 0.6];
			_textformat = format ["<t align='right' size='0.4' color='#%1'>%2<br /><t align='right' size='%4' color='#%1'>%3</t>",_colour,_modtext, _text, 0.6]; 
			_ypos = 1.3;_sec = 60;
			[_textformat,_ypos,_sec,Lifelinetxt2Layer] remoteExec ["Lifeline_display_textright", allplayers]; 
		 };
		}; // if (hasInterface) then {

// }; // end isNil "oldACE"

// PVP check
/* if (isServer) then {
    // Initialize PVP status on server
    Lifeline_PVPstatus = false;
    publicVariable "Lifeline_PVPstatus";
    // Wait for at least one player to join
    waitUntil {
        sleep 1;
        count (allPlayers - entities "HeadlessClient_F") > 0
    };
};

if (hasInterface) then {

	player setVariable ["Lifeline_Captive",(captive player),true]; //2025

	playerSide1 = side group player; 
	_currentSides = missionNamespace getVariable ["Lifeline_PVPcheckSides", []];
	_currentSides pushBackUnique playerSide1;
	missionNamespace setVariable ["Lifeline_PVPcheckSides", _currentSides, true];
	enemyUnitsJa = allUnits select {[playerSide1, side group _x] call BIS_fnc_sideIsEnemy};
	publicVariable "enemyUnitsJa";
};

// Update PVP status based on player sides
if (isServer) then {
    _playersides = missionNamespace getVariable ["Lifeline_PVPcheckSides", []];
    if (count _playersides > 1) then {
        Lifeline_PVPstatus = true;
    } else {
        Lifeline_PVPstatus = false;
    };
    publicVariable "Lifeline_PVPstatus";
}; */

//Detect PVP status if not defined (mission reload safety)
Lifeline_PVPstatus = false;

// if (isNil "Lifeline_PVPstatus") then {
	// Simple, reliable PVP Detection
	_players = allPlayers - entities "HeadlessClient_F";
	if (count _players > 0) then {
		// Collect all unique player sides
		_currentSides = [];
		{
			_playerSide = side group _x;
			_currentSides pushBackUnique _playerSide;
		} forEach _players;
		// Determine PVP status: multiple sides = PVP, single side = PVE
		if (count _currentSides > 1) then {
			Lifeline_PVPstatus = true;
		} else {
			Lifeline_PVPstatus = false;
		};
	} else {
		// No players found, default to PVE
		Lifeline_PVPstatus = false;
	};
	// Ensure this gets shared with other clients/server
	publicVariable "Lifeline_PVPstatus";
// };

// _players = allPlayers - entities "HeadlessClient_F";

// if there are only players on one side, then set the side to that side. If its PVP
// Needs updating to include allies.
// Lifeline_Side = side (_players select 0);// publicVariable "Lifeline_Side"; // THIS IS A SINGLE SIDE. NEED TO UPDATE TO ARRAY VERSION  FOR ALLIES.
Lifeline_OPFOR_Sides = Lifeline_Side call BIS_fnc_enemySides;
publicVariable "Lifeline_OPFOR_Sides"; // THIS IS AN ARRAY OF ENEMY SIDES

// if (Lifeline_Scope == 4 || Lifeline_mod_dedi ) then {
if (Lifeline_Scope == 4) then {
	if !(Lifeline_mod_dedi) then {
		[false,Lifeline_PVPstatus] spawn Lifeline_StartActionMenu;
	} else {
		_player = _players select 0;
		[true,Lifeline_PVPstatus] remoteExec ["Lifeline_StartActionMenu", _player, true];
	};
} else {
	//============================ LOAD MAIN FILES =============================
	// if (isNil "oldACE") then {
		// [] execvm "Lifeline_Revive\scripts\non_ace\Lifeline_DamageHandlerFNC.sqf";
	// };
	[] execvm "Lifeline_Revive\scripts\Lifeline_Global.sqf"; 
	[] execvm "Lifeline_Revive\scripts\Lifeline_ReviveEngine.sqf"; 

	if (Lifeline_Hotwire) then {
		[] execvm "Lifeline_Revive\scripts\bonus\hotwire_vehicles.sqf"; 
	};

};
