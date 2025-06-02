// This file only loads for server version of Lifeline Revive.
// It declares same variables as the MOD version..
// The file is included in the mod folder for compatibility of testing.
// This makes it easier to have same core files for both versions.

diag_log "                                                                                                '"; 
diag_log "                                                                                                '"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 
diag_log "======================================== server_or_mission_only.sqf ========================================='"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 

Lifeline_mod = false;

	//emulate the MOD version where CBA settings only exist if ACE is loaded or not. 
	if (Lifeline_ACEcheck_ == false) then {
		Lifeline_ACE_vanillaFAK = nil;
		Lifeline_ACE_CIVILIANlimitbleedtime = nil;
		Lifeline_ACE_OPFORlimitbleedtime = nil;
		Lifeline_ACE_Blackout = nil;
		Lifeline_ACE_Bandage_Method = nil;
		Lifeline_ACE_BluFor = nil;
	};

	if (Lifeline_ACEcheck_ == true) then {
		Lifeline_BandageLimit = nil;
		Lifeline_InstantDeath = nil;
		Lifeline_BleedOutTime = nil;
		Lifeline_autoRecover = nil;
		Lifeline_CPR_likelihood = nil;
		Lifeline_CPR_less_bleedouttime = nil;
		Lifeline_IncapThres = nil;
		Lifeline_cntdwn_disply = nil;
		Lifeline_Fatigue = nil;	
	};

	Lifeline_yellowmarker = true;
	Lifeline_remove_3rd_pty_revive = true;
	Lifeline_RevMethod = 2; 
	Lifeline_hintsilent = true;
	Lifeline_debug_soundalert = true;

	Lifeline_SOGAI_orangetrian = false; // SOG AI 

	Lifeline_ACE_vanillaFAK = true;

	Lifeline_MASCAL_sides = []; 

	if (Lifeline_ACEcheck_ == true) then {

		if (Lifeline_ACE_vanillaFAK) then {
			[401, ["ACE_morphine","ACE_tourniquet","ACE_quikclot","ACE_elasticBandage","ACE_packingBandage","ACE_epinephrine","ACE_adenosine","ACE_splint","ACE_plasmaIV_500","ACE_CableTie"]] call ace_common_fnc_registerItemReplacement;
		};

	};

	Lifeline_SOGAIcheck_ = false;

	//check for SOG AI 
	if (isClass (configFile >> "cfgPatches" >> "JBOY_SOGAI_mod")) then {
		diag_log "XEH_preInit.sqf +++++++++++ SOG AI DETECTED +++++++++++++++'";
		Lifeline_SOGAIcheck_ = true;
		[] spawn {
			waitUntil {(!isNil "jboy_medicStart")};
			jboy_medicStart = compile preprocessFileLineNumbers ("");
		};
		if (Lifeline_Idle_Crouch) then {	
			[] spawn {
				waitUntil {(!isNil "jboy_followersCopyLeaderStance")};
				jboy_followersCopyLeaderStance = compile preprocessFileLineNumbers ("");
			};	
		};
		[] spawn {
			if (Lifeline_SOGAI_orangetrian == false) then {
				waitUntil {isNil {missionNameSpace getVariable "JBOY_showInjuredIcon"}};
				missionNameSpace setVariable ["JBOY_showInjuredIcon", false];
			};
		};
	};

	// Lifeline_Idle_Crouch_Speed = 0; // the speed of a unit to consider "idle". Between 0 - 5.

	Lifeline_travel_meth = 1; //TEMP TEST. animation method for medic just before arriving at incap. 0 is normal without using stance. 1 is using stance (prone)
	// 1 = "remoteexec ['addeventhandler', _x] (Default)",
	// 2 = "remoteExec ['call'] curley brackets {}", 
	// 3 = "remoteExec FNC ['Lifeline_custom_DamageH'", 
	// 4 = "remoteExec CALL FNC ['Lifeline_custom_DamageH'"
	// Debug_to = 2; //either "allplayers" or "2" which is server.
	Debug_to = 0; //either "allplayers" or "2" which is server.

	//for on screen text
	Lifelinetxt1Layer = "Lifelinetxt1" call BIS_fnc_rscLayer; 
	Lifelinetxt2Layer = "Lifelinetxt2" call BIS_fnc_rscLayer; 
	LifelineBleedoutLayer = "LifelineBleedouttxt" call BIS_fnc_rscLayer; 
	LifelineDistLayer = "LifelineDistLayertxt" call BIS_fnc_rscLayer; 
	LifelinetxtdebugLayer1 = "Lifelinetxtdebug1" call BIS_fnc_rscLayer; 
	LifelinetxtdebugLayer2 = "Lifelinetxtdebug2" call BIS_fnc_rscLayer; 
	LifelinetxtdebugLayer3 = "Lifelinetxtdebug3" call BIS_fnc_rscLayer; 

	// FONTS
	// Lifelinefonts =["EtelkaMonospacePro","EtelkaMonospaceProBold","EtelkaNarrowMediumPro","LCD14","LucidaConsoleB","PuristaBold","PuristaLight","PuristaMedium","PuristaSemibold","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight","TahomaB"];
	Lifelinefonts =["EtelkaMonospacePro","PuristaBold","PuristaLight","PuristaMedium","PuristaSemibold","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight"];
	//select the font above
	_selectfont = 5;
	Lifeline_HUD_dist_font = Lifelinefonts select _selectfont;

	publicVariable "Lifeline_Scope";
	publicVariable "Lifeline_RevProtect";
	publicVariable "Lifeline_RevMethod";
	publicVariable "Lifeline_BleedOutTime";
	publicVariable "Lifeline_InstantDeath";
	publicVariable "Lifeline_autoRecover";
	publicVariable "Lifeline_BandageLimit";
	publicVariable "Lifeline_SmokePerc";
	publicVariable "Lifeline_EnemySmokePerc";
	publicVariable "Lifeline_SmokeColour";
	publicVariable "Lifeline_radio";
	publicVariable "Lifeline_MedicComments";
	publicVariable "Lifeline_Voices";
	publicVariable "Lifeline_BloodPool";
	publicVariable "Lifeline_Litter";
	publicVariable "Lifeline_HUD_distance"; 
	publicVariable "Lifeline_HUD_medical"; 
	publicVariable "Lifeline_HUD_names";  
	publicVariable "Lifeline_ACE_Bandage_Method";
	publicVariable "Lifeline_IncapThres";
	publicVariable "Lifeline_Revive_debug";
	publicVariable "Lifeline_version";
	publicVariable "Lifeline_cntdwn_disply";

