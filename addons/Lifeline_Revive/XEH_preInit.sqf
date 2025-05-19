Lifeline_Version = "Lifeline Revive AI";
Lifeline_Version_no = "2025-05-03 19:04:55";
Lifeline_mod = true;

  // these diag_logs have a single space character at start for my regex clean later
diag_log "                                                                                   			               '"; 
diag_log "============================================================================================================='";
diag_log "==================================================== MOD ===================================================='";
diag_log "============================================== XEH_preInit.sqf =============================================='";
diag_log "============================================================================================================='";
diag_log "============================================================================================================='";
diag_log format ["================================ VERSION: %1    %2'", Lifeline_Version, Lifeline_Version_no];

// check for ACE medical
if (isClass (configFile >> "cfgPatches" >> "ace_medical")) then {
	diag_log "++++++++++++++++++++ ACE MEDICAL +++++++++++++++++++'";
	Lifeline_ACEcheck_ = true;
} else {
	oldACE = nil;
	Lifeline_ACEcheck_ = false;
	diag_log "++++++++++++++++++++ NO ACE MEDICAL ++++++++++++++++++++'";
};

#include "\a3\ui_f\hpp\defineDIKCodes.inc"

["Lifeline Revive AI", "LifelineREV4", ["Activate", "Lifeline Revive AI"], {
    _this call LifelineREV4_fnc_keyDown
}, {
    _this call LifelineREV4_fnc_keyUp
}, [DIK_L, [true, true, true]]] call CBA_fnc_addKeybind;

LifelinePVEOPFORText = "__ These settings are ignored in PVP. Only for PVE __";
// LifelinePVEOPFORText2 = "OPFOR in PVE (ignored in PVP)";
// LifelinePVEOPFORText2 = "OPFOR in PVE (PVP games use main)";
LifelinePVEOPFORText2 = "OPFOR in PVE";
// LifelinePVEOPFORText2 = "OPFOR in PVE (auto for PVP games)";
// LifelinePVEOPFORText2 = "OPFOR in PVE";
// LifelinePVEOPFORText2 = "OPFOR in PVE (PVP uses global settings)";

//MAIN
   //_MAIN
["Lifeline_revive_enable", "CHECKBOX", ["ENABLE "+Lifeline_Version, "On or Off.\n\n"], "Lifeline Revive AI", true,true] call CBA_fnc_addSetting;
["Lifeline_Scope", "LIST",     ["Scope", "Scope of mod. Which units will Lifeline Revive affect?\n\n\n"], ["Lifeline Revive AI","_MAIN"], [[1, 2, 3, 4], ["Group","Playable Slots", "Side", "Choose in Mission"], 3],true] call CBA_fnc_addSetting;
["Lifeline_RevProtect", "LIST",     ["Shield while reviving",     "Protection during revive process. 3 levels.
1. Invincible during revive for both medic and incap. Even bullets won't affect them.
2. Semi-Realism mode. The medic and incap is turned pseudo 'captive' to avoid being targeted.
   Enemy won't target them - however stray bullets and extra damage can still kill.
3. Protection Off. Most Realism. Both medic and incap, can be both targeted and killed while reviving.\n\n"], ["Lifeline Revive AI","_MAIN"], [[1,2,3], ["Invincible","Captive Hack", "Off - Realism"], 1],true] call CBA_fnc_addSetting;

//OPFOR
	//SEPERATE CBA
// ["Lifeline_Include_OPFOR", "CHECKBOX", ["ENABLE REVIVE FOR OPFOR IN PVE", "On or Off.\n\n"], ["Lifeline Revive OPFOR",LifelinePVEOPFORText], true,true] call CBA_fnc_addSetting;
	//IN MAIN CBA
// ["Lifeline_Include_OPFOR", "CHECKBOX", ["Include OPFOR in PVE", "This is for PVE only. When in PVP, the main settings apply to both sides equally.
// These setting exist so you can tweak the enemy in PVE.
// e.g. how easy are they to kill with instant death setting.\n\n"], ["Lifeline Revive AI",LifelinePVEOPFORText2], true,true] call CBA_fnc_addSetting;
["Lifeline_Include_OPFOR", "CHECKBOX", ["Include OPFOR in PVE", "OPFOR = Opposing Forces, aka enemy.
This is for PVE only. When in PVP, the main settings apply to both sides equally.
These setting exist so you can tweak the enemy in PVE.
e.g. how easy are they to kill with instant death setting.

You also have this option in the load menu at start of 
mission if your scope option above (1st option) is set to
'Choose in Mission'.
\n\n"], ["Lifeline Revive AI",LifelinePVEOPFORText2], false,true] call CBA_fnc_addSetting;

// ["Lifeline_RevProtectOPFOR", "LIST",     ["Shield while reviving",     "Protection during revive process. 3 levels.
// 1. Invincible during revive for both medic and incap. Even bullets won't affect them.
// 2. Semi-Realism mode. The medic and incap is turned pseudo 'captive' to avoid being targeted.
//    Enemy won't target them - however stray bullets and extra damage can still kill.
// 3. Protection Off. Most Realism. Both medic and incap, can be both targeted and killed while reviving.\n\n"], ["Lifeline Revive OPFOR","_MAIN"], [[1,2,3], ["Invincible","Captive Hack", "Off - Realism"], 1],true] call CBA_fnc_addSetting;

if (Lifeline_ACEcheck_ == false) then {
	//MAIN
	["Lifeline_BandageLimit", "SLIDER",   ["Bandage Range",   "Number of bandages is calculated within this range, depending on damage.
	If you have this set to 8, then maximum damage  
	equals 8 bandages (if not killed). If you get half that damage it will equal 4 bandages.
	*Set this to 1 if you want fastest revive: only 1 action needed for any revive, 
	like Arma vanilla revive.
	\n\n"], ["Lifeline Revive AI","_MAIN"], [1, 10, 8, 0],true,{Lifeline_BandageLimit = round Lifeline_BandageLimit}] call CBA_fnc_addSetting;
	["Lifeline_InstantDeath", "LIST",     ["Instant Death",  "0 = Off. Always go into incapacited state.
1 = Moderate. A bit more casual, instant death still happens with headshots etc.
2 = Realism. Instant death on realistic level."], ["Lifeline Revive AI","_MAIN"], [[0,1,2], ["Off","Moderate", "Realism"], 1],true] call CBA_fnc_addSetting;
	["Lifeline_BleedOutTime", "SLIDER",   ["Bleedout Time",   "Select how long an INCAPACITATED unit can survive in state before dying or autorevive\n\n"], ["Lifeline Revive AI","_MAIN"], [0, 600, 300, 0],true,{Lifeline_BleedOutTime = round Lifeline_BleedOutTime}] call CBA_fnc_addSetting;
	["Lifeline_autoRecover", "SLIDER",   ["Auto Recover",   "Percentage chance of regaining consciousness\n\n"], ["Lifeline Revive AI","_MAIN"], [0, 1, .3, 0, true],true,{Lifeline_autoRecover = round (Lifeline_autoRecover * 100)}] call CBA_fnc_addSetting;
	["Lifeline_CPR_likelihood", "SLIDER",   ["Likelihood of Cardiac Arrest w High Damage",   "If damage over CPR threshold, how likley?\n\n"], ["Lifeline Revive AI","_MAIN"], [0, 1, .9, 0, true],true,{Lifeline_cpr_likelihood = round (Lifeline_cpr_likelihood * 100)}] call CBA_fnc_addSetting;
	["Lifeline_CPR_less_bleedouttime", "SLIDER",   ["Less Bleedout Time when Cardiac Arrest",   "Bleedout time is compressed to this percentage.\n\n"], ["Lifeline Revive AI","_MAIN"], [0, 1, .6, 0, true],true,{Lifeline_CPR_less_bleedouttime = round (Lifeline_CPR_less_bleedouttime * 100)}] call CBA_fnc_addSetting;
	["Lifeline_IncapThres", "SLIDER",   ["Incap Threshold",   "The damage level that triggers incapacitated state.   
	The lower the theshold, the easier it is to incapacitate. 
	e.g. If you have 0.6, then you only need 0.6 damage to go unconcious.
	(in Arma, damage is from 0-1, with 1 being lethal)		\n\n"], ["Lifeline Revive AI","_MAIN"], [0.5, 0.8, 0.7, 1],true,{Lifeline_IncapThres = (round(Lifeline_IncapThres * 10)/10)}] call CBA_fnc_addSetting;
	//OPFOR
	// ["Lifeline_BandageLimitOPFOR", "SLIDER",   ["Bandage Range",   "Range of bandages any incap needs to revive.\nHigher damage = more bandages within this range\nSet it to 1 for easiest and fastest revive"], ["Lifeline Revive OPFOR","_MAIN"], [1, 10, 8, 0],true,{Lifeline_BandageLimitOPFOR = round Lifeline_BandageLimitOPFOR}] call CBA_fnc_addSetting;

		// SEPARATE CBA
/* 	["Lifeline_InstantDeathOPFOR", "LIST",     ["Instant Death",  "0 = Off. Always go into incapacited state.
1 = Moderate. A bit more casual, instant death still happens with headshots etc.
2 = Realism. Instant death on realistic level."], ["Lifeline Revive OPFOR","_MAIN"], [[0,1,2], ["Off","Moderate", "Realism"], 2],true] call CBA_fnc_addSetting; */
		// IN MAIN CBA
	["Lifeline_InstantDeathOPFOR", "LIST",     ["Instant Death",  "0 = Off. Always go into incapacited state.
1 = Moderate. A bit more casual, instant death still happens with headshots etc.
2 = Realism. Instant death on realistic level."], ["Lifeline Revive AI",LifelinePVEOPFORText2], [[0,1,2], ["Off","Moderate", "Realism"], 2],true] call CBA_fnc_addSetting;

	// ["Lifeline_BleedOutTimeOPFOR", "SLIDER",   ["Bleedout Time",   "Select how long an INCAPACITATED unit can survive in state before dying or autorevive\n\n"], ["Lifeline Revive OPFOR","_MAIN"], [0, 600, 300, 0],true,{Lifeline_BleedOutTimeOPFOR = round Lifeline_BleedOutTimeOPFOR}] call CBA_fnc_addSetting;
	// ["Lifeline_autoRecoverOPFOR", "SLIDER",   ["Auto Recover",   "Percentage chance of regaining consciousness\n\n"], ["Lifeline Revive OPFOR","_MAIN"], [0, 1, .3, 0, true],true,{Lifeline_autoRecoverOPFOR = round (Lifeline_autoRecoverOPFOR * 100)}] call CBA_fnc_addSetting;
	// ["Lifeline_CPR_likelihoodOPFOR", "SLIDER",   ["Likelihood of Cardiac Arrest w High Damage",   "If damage over CPR threshold, how likley?\n\n"], ["Lifeline Revive OPFOR","_MAIN"], [0, 1, .9, 0, true],true,{Lifeline_cpr_likelihoodOPFOR = round (Lifeline_cpr_likelihoodOPFOR * 100)}] call CBA_fnc_addSetting;
	// ["Lifeline_CPR_less_bleedouttimeOPFOR", "SLIDER",   ["Less Bleedout Time when Cardiac Arrest",   "If heart is stopped and need CPR, then bleedout time is compressed to this percentage.\n\n"], ["Lifeline Revive OPFOR","_MAIN"], [0, 1, .6, 0, true],true,{Lifeline_CPR_less_bleedouttimeOPFOR = round (Lifeline_CPR_less_bleedouttimeOPFOR * 100)}] call CBA_fnc_addSetting;
	// ["Lifeline_IncapThresOPFOR", "SLIDER",   ["Incap Threshold",   "Damage level to trigger incapacitated. Default 0.7\n\n"], ["Lifeline Revive OPFOR","_MAIN"], [0.5, 0.8, 0.7, 1],true,{Lifeline_IncapThresOPFOR = (round(Lifeline_IncapThresOPFOR * 10)/10)}] call CBA_fnc_addSetting;
};

//MAIN
["Lifeline_SelfHeal_Cond", "LIST",     ["AI Self Revive",     "AI will patch themselves up.
0 = Off
1 = On
2 = No Enemy <100m line-of-sight

The last option is to prioritize return fire when enemy is within 100m.
 \n\n"], ["Lifeline Revive AI","_MAIN"], [[0,1,2], ["Off","On", "No Enemy <100m line-of-sight"], 2],true] call CBA_fnc_addSetting;

    //HUD & MAP
	["Lifeline_HUD_distance", "CHECKBOX", ["Distance of Medic (bottom right)", "Show distance of medic.\nBottom right near bleedout timer.\n\n"], ["Lifeline Revive AI","HUD & MAP"], false,true] call CBA_fnc_addSetting;
	["Lifeline_HUD_medical", "CHECKBOX", ["Medical Action Hint (bottom right)", "Show which medical action is happening.\ne.g. CPR, blood IV, morphine, body part bandage and number of bandages\n\n"], ["Lifeline Revive AI","HUD & MAP"], true,true] call CBA_fnc_addSetting;

if (Lifeline_ACEcheck_ == false) then {
	["Lifeline_HUD_names", "LIST",     ["Incapacitated List & Medics (top right)", 
	"
	Incapacitated units and also medics on their way.

	0. Off
	1. Names
	2. Names, distance & bandage
	3. Names & distance
	4. Names & bandage

	*note there is an extra option available in debugging, 
	the revive pair timer called 
	'pair timer for HUD list of units'.
	This is the timeout left before resetting the medic.  \n\n"], ["Lifeline Revive AI","HUD & MAP"], [[0, 1, 2, 3, 4], ["Off","Names", "Names, distance & bandage", "Names & distance", "Names & bandage"], 3],true] call CBA_fnc_addSetting;
} else {
	["Lifeline_HUD_names", "LIST",     ["Incapacitated List & Medics (top right)", 
	"
	Incapacitated units and also medics on their way.

	0. Off
	1. Names
	2. Names & distance

	*note there is an extra option available in debugging, 
	the revive pair timer called 
	'pair timer for HUD list of units'.
	This is the timeout left before resetting the medic.  \n\n"], ["Lifeline Revive AI","HUD & MAP"], [[0, 1, 3], ["Off","Names", "Names & distance"], 0],true] call CBA_fnc_addSetting;
};
/* ["Lifeline_HUD_nameformat", "LIST",     ["Name Format", 
"1. Full Name
2. Last Name
3. Unit No, Last Name 
4. Last Name, Group   
5. Unit No, Group
6. Unit No, Last Name, Group
7. Unit No, Full Name, Group 

\n\n"], ["Lifeline Revive AI","HUD & MAP"], [[1, 2, 3, 4, 5, 6, 7], ["Full Name","Last Name", "Unit No, Last Name", "Last Name, Group", "Unit No, Group", "Unit No, Last Name, Group", "Unit No, Full Name, Group"], 5],true] call CBA_fnc_addSetting; */

["Lifeline_HUD_nameformat", "LIST",     ["Name Format", 
"1. Fullname
2. Surname
3. Unit No, Surname
4. Surname, Group   
5. Unit No, Group
6. Unit No, Surname, Group
7. Unit No, Fullname, Group 

\n\n"], ["Lifeline Revive AI","HUD & MAP"], [[1, 2, 3, 4, 5, 6, 7], ["Fullname","Surname", "Unit No. / Surname", "Surname / Group", "Unit No. / Group", "Unit No. / Surname / Group", "Unit No. / Fullname / Group"], 5],true] call CBA_fnc_addSetting;

["Lifeline_HUD_namesize", "LIST",     ["Text Size for List", 
"1. Normal
2. Small
3. Smaller
\n\n"], ["Lifeline Revive AI","HUD & MAP"], [[1, 2, 3], ["Normal","Small", "Smaller"], 0],true] call CBA_fnc_addSetting;
["Lifeline_Map_mark", "CHECKBOX", ["Show markers on map", "Incapacitated and dead shown on map\n\n"], ["Lifeline Revive AI","HUD & MAP"], false,true] call CBA_fnc_addSetting;
//MASCAL setting for later
/* if (Lifeline_ACEcheck_ ) then {
	["Lifeline_MASCAL", "CHECKBOX", ["MASCAL alert", "When MASCAL (mass casualty) and all units are down,\nshow a message on the HUD.\n\n"], ["Lifeline Revive AI","HUD & MAP"], false,true,{if (Lifeline_MASCAL == true) then {Lifeline_MASCAL = 1} else {Lifeline_MASCAL = 0}}] call CBA_fnc_addSetting;
} else {
	["Lifeline_MASCAL", "LIST",     ["MASCAL alert", "When MASCAL (mass casualty) and all units are down,\nshow a message on the HUD.\nThere is an option to detect auto-revive units after a delay of 30 secs. \nThen you know to wait for them to recover.\n\n"], ["Lifeline Revive AI","HUD & MAP"], [[0,1,2], ["Off", "Simple Alert","Plus Recovering Units Alert"], 1]] call CBA_fnc_addSetting;
}; */
if (Lifeline_ACEcheck_ == false) then {["Lifeline_cntdwn_disply", "SLIDER",   ["Bleedout Timer Display - When to Show",   "When to show countdown display, in seconds left.\ne.g. you could have bleedout set to 300 seconds but the\ncountdown display may only appear at 120 seconds.\nThen it acts more like a warning of time remaining.\n0 = off\n\n"], ["Lifeline Revive AI","HUD & MAP"], [0, 600, 300, 0],true,{Lifeline_cntdwn_disply = round Lifeline_cntdwn_disply}] call CBA_fnc_addSetting};

//MAIN
    //SMOKE
["Lifeline_SmokePerc", "SLIDER",   ["Smoke Chance",   "Percentage Chance of using Smoke when Healing\n\n"], ["Lifeline Revive AI","SMOKE"], [0, 1, .3, 0, true],true,{Lifeline_SmokePerc = round (Lifeline_SmokePerc * 100)}] call CBA_fnc_addSetting;
["Lifeline_EnemySmokePerc", "SLIDER",   ["Smoke Chance, Enemy Nearby",   "Overrides Setting Above if Enemy < 300m\n\n"], ["Lifeline Revive AI","SMOKE"], [0, 1, .7, 0, true],true,{Lifeline_EnemySmokePerc = round (Lifeline_EnemySmokePerc * 100)}] call CBA_fnc_addSetting;
["Lifeline_SmokeColour", "LIST",     ["Colour of Smoke",     "Colour of Smoke\n\n"], ["Lifeline Revive AI","SMOKE"], [["white","yellow","red","purple","orange","green","random"], ["white","yellow","red","purple","orange","green","random"], 0],true] call CBA_fnc_addSetting;

    //SOUND
["Lifeline_radio", "CHECKBOX", ["Allow radio status messages", "Allow radio status messages. If medic is over 50m away, radio to assure.\n\n"], ["Lifeline Revive AI","SOUND"], true,true] call CBA_fnc_addSetting;
["Lifeline_MedicComments", "CHECKBOX", ["AI Medic Comments", "Allow AI medic to speak with assurances to incap during revive.\nIgnored for ACE as this is compulsory due to black screen when incap.\n\n"], ["Lifeline Revive AI","SOUND"], true,true] call CBA_fnc_addSetting;
["Lifeline_Voices", "LIST",     ["Voice Accents",  "Commonwealth (British + Australian) or USA\n\n"], ["Lifeline Revive AI","SOUND"], [[1,2,3], ["All","British Empire", "USA"], 0],true] call CBA_fnc_addSetting;

    //TECH TWEAKS
["Lifeline_Idle_Medic_Stop", "CHECKBOX", ["6 second limit on idle medics", "Sometime AI in Arma is retarded. This stops them being idle after 6 seconds\n\n"], ["Lifeline Revive AI","~MISC"], false,true] call CBA_fnc_addSetting;
["Lifeline_AI_skill", "SLIDER",   ["AI Skill",   "AI skill level. The skill level of AI in your squad or side.\n0 means ignore & use mission setting.\n\n"], ["Lifeline Revive AI","~BONUS. Unrelated to revive but useful"], [0, 1, 0, 1],true,{Lifeline_AI_skill = (round(Lifeline_AI_skill * 10)/10)}] call CBA_fnc_addSetting;
["Lifeline_Anim_Method", "LIST",     ["Prone animation method", "Old: Smoother animation but busier with the weapon always pulled out between bandages, and takes longer to revive.
New method: no weapon pulled out between bandages - but due to arma bugs - there is a small animation glitch in the loop (frame jump)\n\n"], ["Lifeline Revive AI","~MISC"], [[0, 1], ["Old Method","New Method"], 1],true] call CBA_fnc_addSetting;

   //MEDIC SELECTION 
// ["Lifeline_Blacklist_MedicOnly", "CHECKBOX", ["Arma Medics Only", "Only designated medics can revive\n\n"], ["Lifeline Revive AI","MEDIC SELECTION"], false,true] call CBA_fnc_addSetting;
["Lifeline_Medic_Limit", "LIST",     ["Number of Medics",  "This is to keep combat effectiveness up.
	Limit maximum number of medics in action at any one time.
	Less medics in action = more firepower.

- No limits. Any in Scope ('Scope' is set above). Other groups units can revive your team.
- Any amount from Group. Incapacated will only get medics from their group.
- 1 per Group
- 2 per Group
- 3 per Group
- 1 per Group + any not under fire
- 2 per Group + any not under fire
- 3 per Group + any not under fire

 *Note: these limits are unblocked when MASCAL (mass casualty) has happened.

'1 per Group + any not under fire' means 1 medic always per group, plus any other units not under fire.
 'fire' is supression > 0.1

"], ["Lifeline Revive AI","MEDIC SELECTION"], [[-1,0,1,2,3,4,5,6], ["No limits. Any in Scope", "Any in group", "1 per group", "2 per group", "3 per group", "1 per group + any not under fire", "2 per group + any not under fire", "3 per group + any not under fire"], 1],true] call CBA_fnc_addSetting;
["Lifeline_Dedicated_Medic", "CHECKBOX", ["Always Use Vanilla Arma 3 Medic", "Always force the vanilla Arma 3 medic to be used.    
	If you want only the vanilla Arma 3 medic in action, then set this to 'true' and choose '1' from 'Number of Medics' above.

	*Note if there is no vanilla Arma 3 medic in the squad, then the trait will be set to last unit in squad.\n\n"], ["Lifeline Revive AI","MEDIC SELECTION"], false,true] call CBA_fnc_addSetting;

["Lifeline_LimitDist", "SLIDER",   ["Distance Limit", "Only units within this distance will be become a medic.\nThis means distance from the incap.\nIn metres.\n\n"], ["Lifeline Revive AI","MEDIC SELECTION"], [200, 4000, 1000, 0],true,{Lifeline_LimitDist = round(_this)}] call CBA_fnc_addSetting;
["Lifeline_Blacklist_Mounted_Weapons", "CHECKBOX", ["Mounted Weapons - Blacklist", "Units with mounted weapons cannot become medics.\nThis includes gunners of vehicles.\n\n*Note: blacklist is unblocked when MASCAL (mass casualty) has happened.\n\n"], ["Lifeline Revive AI","MEDIC SELECTION"], true,true] call CBA_fnc_addSetting;
["Lifeline_Blacklist_Drivers", "CHECKBOX", ["Drivers and Pilots - Blacklist", "Units driving or piloting a machine cannot become medics.\n\n*Note: blacklist is unblocked when MASCAL (mass casualty) has happened.\n\n"], ["Lifeline Revive AI","MEDIC SELECTION"], true,true] call CBA_fnc_addSetting;
["Lifeline_Blacklist_Armour", "CHECKBOX", ["Armour - Blacklist", "Units in tanks and armour cannot become medics\n\n*Note: blacklist is unblocked when MASCAL (mass casualty) has happened.\n\n"], ["Lifeline Revive AI","MEDIC SELECTION"], true,true] call CBA_fnc_addSetting;
["Lifeline_Blacklist_Air", "CHECKBOX", ["Air - Blacklist", "Units in helicopters/planes cannot become medics.\nThey do not need to be driving or a pilot.\n\n*Note: blacklist is unblocked when MASCAL (mass casualty) has happened.\n\n"], ["Lifeline Revive AI","MEDIC SELECTION"], true,true] call CBA_fnc_addSetting;
["Lifeline_Blacklist_Car", "CHECKBOX", ["Cars or Trucks - Blacklist", "Units in vehicles like cars or trucks cannot become medics\n\n*Note: blacklist is unblocked when MASCAL (mass casualty) has happened.\n\n"], ["Lifeline Revive AI","MEDIC SELECTION"], false,true] call CBA_fnc_addSetting;
// ["Lifeline_MASCAL_unblock", "CHECKBOX", ["Unblock Limits when MASCAL", "When all units are down (MASCAL) you have a last chance to get a medic\nby unblocking the blacklist and number limits\n\n"], ["Lifeline Revive AI","MEDIC SELECTION"], true,true] call CBA_fnc_addSetting;

// ["Lifeline_VIP_PLayer_MASCAL", "CHECKBOX", ["MASCAL unblock blacklist", "When all units are down (MASCAL) you can have a last chance to get a medic\nby unblocking the blacklist\n\n"], ["Lifeline Revive AI","MEDIC SELECTION"], false,true] call CBA_fnc_addSetting;

//OPFOR
// ["Lifeline_SmokePercOPFOR", "SLIDER",   ["Smoke Chance",   "Percentage Chance of using Smoke when Healing\n\n"], ["Lifeline Revive OPFOR","SMOKE"], [0, 1, .3, 0, true],true,{Lifeline_SmokePercOPFOR = round (Lifeline_SmokePercOPFOR * 100)}] call CBA_fnc_addSetting;
// ["Lifeline_EnemySmokePercOPFOR", "SLIDER",   ["Smoke Chance, Enemy Nearby",   "Overrides Setting Above if Enemy < 300m\n\n"], ["Lifeline Revive OPFOR","SMOKE"], [0, 1, .7, 0, true],true,{Lifeline_EnemySmokePercOPFOR = round (Lifeline_EnemySmokePercOPFOR * 100)}] call CBA_fnc_addSetting;
// ["Lifeline_SmokeColourOPFOR", "LIST",     ["Colour of Smoke",     "Colour of Smoke\n\n"], ["Lifeline Revive OPFOR","SMOKE"], [["white","yellow","red","purple","orange","green","random"], ["white","yellow","red","purple","orange","green","random"], 0],true] call CBA_fnc_addSetting;

//=========================

if (Lifeline_ACEcheck_ == false) then {
	// ["Lifeline_kill_other_revives", "CHECKBOX", ["Kill Other Revive Systems (experimental)", "Kill Other Revive Systems like Psycho Revive"], "Lifeline Revive AI", true] call CBA_fnc_addSetting;
	//setting this variable not found error for when ACE is not loaded. Fix this all later with better method.
	Lifeline_ACE_Bandage_Method = 1;
	Lifeline_RevMethod = 2;
};

if (Lifeline_ACEcheck_ == true) then {
	//MAIN
	["Lifeline_ACE_Bandage_Method", "LIST",     ["ACE Bandage method",     "1. Default ACE bandaging.\n2. Less Bandages required.\n\n"], ["Lifeline Revive AI","_MAIN"], [[1, 2], ["Default ACE bandaging","Less Bandages required"], 1]] call CBA_fnc_addSetting;
	//TWEAKS | Missions not designed for ACE
	["Lifeline_ACE_Blackout", "CHECKBOX", ["Disable ACE Unconsc. Blackout Screen", "Disable the ACE blackout effect when unconscious\n\n"], ["Lifeline Revive AI","~MISC"], false,true] call CBA_fnc_addSetting;
	["Lifeline_ACE_OPFORlimitbleedtime", "SLIDER",   ["PVE: Limit Enemy Bleedout Time",   
	"Workshop missions often require certain number of enemies killed to 
	complete a task or trigger a script. If you have ACE loaded and 
	the mission is not designed for ACE, you have to wait sometimes ages 
	for enemies to bleedout before the task is triggered.
	This setting limits bleedout time for enemy with ACE medical.
	Set to zero to disable.
	If the mission is PVP, this is bypassed.\n\n"], ["Lifeline Revive AI","TWEAKS | ACE Compat. For Any Mission"], [0, 120, 90, 0],true,{Lifeline_ACE_OPFORlimitbleedtime = round Lifeline_ACE_OPFORlimitbleedtime}] call CBA_fnc_addSetting;
	["Lifeline_ACE_CIVILIANlimitbleedtime", "CHECKBOX", ["Include Civilians for Bleedout Limit Above", "Include Civilians to setting above\n\n"], ["Lifeline Revive AI","TWEAKS | ACE Compat. For Any Mission"], false,true] call CBA_fnc_addSetting;
	["Lifeline_ACE_vanillaFAK", "CHECKBOX", ["Incl. Plasma, Splints w vanilla FirstAidKit conversion", "Missions not designed for ACE can have you stuck without\nsplints or plasma IV when you need it. This fixes that.\n\n"], ["Lifeline Revive AI","TWEAKS | ACE Compat. For Any Mission"], true,true, nil ,true] call CBA_fnc_addSetting;
	Lifeline_RevMethod = 3;
};

    //~BONUS. Unrelated to revive but useful
if (Lifeline_ACEcheck_ == false) then {["Lifeline_Fatigue", "LIST",     ["Fatigue",  "Force Fatigue Settings."], ["Lifeline Revive AI","~BONUS. Unrelated to revive but useful"], [[0,1,2], ["Mission Settings","Enabled", "Disabled"], 0],true] call CBA_fnc_addSetting};
["Lifeline_Hotwire", "CHECKBOX", ["Hotwire Locked Vehicles with Toolkit", "Vehicles you cannot access can now be unlocked.\nHotwire them with toolkit.\nIf the vehicle is enclosed, then you need to break in first.\nDoes not apply to armoured units.\n\n"], ["Lifeline Revive AI","~BONUS. Unrelated to revive but useful"], true,true] call CBA_fnc_addSetting;
["Lifeline_ExplSpec", "CHECKBOX", ["Make all your units Explosive Specialists", "It is frustrating when you accidently plant a bomb then cannot undo it.\nThis fixes that.\n\n"], ["Lifeline Revive AI","~BONUS. Unrelated to revive but useful"], true,true] call CBA_fnc_addSetting;
["Lifeline_Idle_Crouch", "CHECKBOX", ["Idle Crouch", "When a unit is standing and idle, it will temporarily go into a 'crouch'.\nThis only applies to 'aware' behaviour mode.\n\n"], ["Lifeline Revive AI","~BONUS. Unrelated to revive but useful"], true,true] call CBA_fnc_addSetting;
["Lifeline_Idle_Crouch_Speed", "SLIDER",   ["Idle Crouch 'Idle' Threshold",   "For the Idle Crouch, this determinds what speed\na unit is moving to be considered 'idle'\n0 for dead still, and 1-5 for 'very slow' to 'slow'\n\n"], ["Lifeline Revive AI","~BONUS. Unrelated to revive but useful"], [0, 5, 3, 0],true,{Lifeline_Idle_Crouch_Speed = round Lifeline_Idle_Crouch_Speed}] call CBA_fnc_addSetting;
if (Lifeline_ACEcheck_ == true) then {["Lifeline_ACE_BluFor", "LIST",     ["Only Show ACE Blufor Tracker with GPS",     
"ACE Blufor tracker shows even without a GPS. Unrealistic.
This option means ACE Blufor tracking will only show if you have a GPS.
You still need Blue Force tracking enabled in ACE settings.

There is also an option to only show Blufor tracking if the HUD minimap is open. 
If you have a lot of markers on the map, you can view main map with less clutter 
by closing minimap which will also disable Blufor tracking.\n\n"], ["Lifeline Revive AI","~BONUS. Unrelated to revive but useful"], [[0, 1, 2], ["ACE default (show regardless of GPS)","Only w GPS unit","Only w GPS minimap on"], 1]] call CBA_fnc_addSetting};

    //~DEBUG
["Lifeline_Revive_debug", "CHECKBOX", ["Debug On", "Debug On. Settings below only work if this is on"], ["Lifeline Revive AI","~~DEBUG"], false,true] call CBA_fnc_addSetting;
["Lifeline_HUD_dist_font", "LIST",     ["Font for distance hint",  "Font for distance hint"], ["Lifeline Revive AI","~~DEBUG"], [["EtelkaMonospacePro","PuristaBold","PuristaLight","PuristaMedium","PuristaSemibold","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight"], ["EtelkaMonospacePro","PuristaBold","PuristaLight","PuristaMedium","PuristaSemibold","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight"], 0],true] call CBA_fnc_addSetting;

["Lifeline_yellowmarker", "CHECKBOX", ["3D Arrow Markers", "in debug mode, show 3D markers when medic 20 metres away from incap."], ["Lifeline Revive AI","~~DEBUG"], false,true] call CBA_fnc_addSetting;

["Lifeline_remove_3rd_pty_revive", "CHECKBOX", ["Remove Other Revive Systems Before Mission", "Uncheck this if you want the choice of cancelling Lifeline Revive in the mission.\nNot the best method however, its better to disable mod and restart mission (not restart Arma 3).\nDo this by unchecking 'ENABLE Lifeline Revive' and restarting mission.\n\n"], ["Lifeline Revive AI","~MISC"], true,true] call CBA_fnc_addSetting;
["Lifeline_hintsilent", "CHECKBOX", ["Debug Hints", "Debug Hints. Using BI 'hinstsilent'"], ["Lifeline Revive AI","~~DEBUG"], false,true] call CBA_fnc_addSetting;
["Lifeline_debug_soundalert", "CHECKBOX", ["Error Sound Alerts", "Sound Alerts when there is a bug."], ["Lifeline Revive AI","~~DEBUG"], false,true] call CBA_fnc_addSetting;
["Lifeline_HUD_names_pairtime", "CHECKBOX", ["pair timer for HUD list of units", "incl time for pairs in HUD list of incapped units and medics"], ["Lifeline Revive AI","~~DEBUG"], false,true] call CBA_fnc_addSetting;
["Lifeline_StartReviveBETA", "CHECKBOX", ["BETA: test version of medic journey to incap", "Still not 100% convinced with my new code for the final 20 metres of medic getting to incap. \nStill testing.  \n\n"], ["Lifeline Revive AI","~~DEBUG"], false,true] call CBA_fnc_addSetting;

//OPFOR
	// SEPARATE CBA
// ["Lifeline_Idle_CrouchOPFOR", "CHECKBOX", ["Idle Crouch", "When a unit is standing and idle, it will temporarily go into a 'crouch'.\nThis only applies to 'aware' behaviour mode.\n\n"], ["Lifeline Revive OPFOR","~BONUS. Unrelated to revive but useful"], true,true] call CBA_fnc_addSetting;
	// IN MAIN CBA
["Lifeline_Idle_CrouchOPFOR", "CHECKBOX", ["Idle Crouch (under ~BONUS heading for BLUFOR)", "When a unit is standing and idle, it will temporarily go into a 'crouch'.\nThis only applies to 'aware' behaviour mode.\n\n"], ["Lifeline Revive AI",LifelinePVEOPFORText2], false,true] call CBA_fnc_addSetting;
	// SEPARATE CBA
// ["Lifeline_ShowOpfor_HUDlist", "CHECKBOX", ["Show HUD namelist for OPFOR", "Revive pairs and names in HUD.\n\n"], ["Lifeline Revive OPFOR","~~DEBUG"], false,true] call CBA_fnc_addSetting;
["Lifeline_ShowOpfor_HUDlist", "CHECKBOX", ["Include OPFOR in Incap List (if OPFOR is ON)", "Only if OPFOR in PVE is selected, you can also add OPFOR to the list of incapacitated units in the top right. They will be a purple colour. \nOnly for debugging.\n\n"], ["Lifeline Revive AI","~~DEBUG"], false,true] call CBA_fnc_addSetting;

if (Lifeline_ACEcheck_ == true) then {

	if (Lifeline_ACE_vanillaFAK) then {
		[401, ["ACE_morphine","ACE_tourniquet","ACE_quikclot","ACE_elasticBandage","ACE_packingBandage","ACE_epinephrine","ACE_adenosine","ACE_splint","ACE_plasmaIV_500","ACE_CableTie"]] call ace_common_fnc_registerItemReplacement;
	};

};

if (Lifeline_remove_3rd_pty_revive == true && Lifeline_revive_enable) then {

	// SOG:PF CDLC revive system
	// Pretend revive system was already initialized.
	// See: vn_fnc_module_advancedrevive
	vn_advanced_revive_started = true;

	// Farooq Revive
	// Overwrite player initialization.
	far_player_init = compileFinal "";
	[{!isNil "far_debugging"}, {
		far_isDragging = nil;  // Disable "Drag & Carry animation fix" loop - cannot be killed because spawned while true.
		far_muteRadio = nil;   // Disable initialization hint.
		far_muteACRE = nil;    // Same, but for very old versions.
		far_debugging = false; // Disable adding event handlers to AI in SP.
	}, [], 5] call CBA_fnc_waitUntilAndExecute;

	//Physcho Revive (old)
	player setVariable ["tcb_ais_aisInit",true];
	//Trick Physcho Revive into thinking ACE is loaded, so it exits.
	// PAR_revive = compileFinal "PAR_revive = true";

	[{!isNil "GRLIB_revive"}, {
		GRLIB_revive = 0; 
	}, [], 5] call CBA_fnc_waitUntilAndExecute;
	// [{!isNil "GRLIB_fatigue"}, {
		// GRLIB_fatigue = 1;  
	// }, [], 5] call CBA_fnc_waitUntilAndExecute;
	[{!isNil "FHQ_FirstAidSystem"}, {
		FHQ_FirstAidSystem = 0;  
	}, [], 5] call CBA_fnc_waitUntilAndExecute;
	[{!isNil "G_Revive_System"}, {
		G_Revive_System = false;  
	}, [], 5] call CBA_fnc_waitUntilAndExecute;

	//Physcho Revive in Liberation
	// GRLIB_revive = 0;
	// GRLIB_fatigue  = 1;
	// FHQ_FirstAidSystem = 0;
	/* PAR_EventHandler = compileFinal nil;
	PAR_fn_nearestMedic = compileFinal nil;
	PAR_fn_medic = compileFinal nil;
	PAR_fn_medicRelease = compileFinal nil;
	PAR_fn_medicRecall = compileFinal nil;
	PAR_fn_checkMedic = compileFinal nil;
	PAR_fn_911 = compileFinal nil;
	PAR_fn_sortie = compileFinal nil;
	PAR_fn_death = compileFinal nil;
	PAR_fn_unconscious = compileFinal nil;
	PAR_fn_eject = compileFinal nil;
	PAR_fn_checkWounded = compileFinal nil;
	PAR_Player_Init = compileFinal nil;
	PAR_EventHandler = compileFinal nil; */

};

//TEMPTEST
{
    if (!isPlayer _x) then {
        _x enableAI "ALL";
    };
} forEach allUnits;

disabledAI = 0;

if (Lifeline_revive_enable) then {

	Lifeline_RevSmokeOn = true; // fix this later.

	//for on screen text
	Lifelinetxt1Layer = "Lifelinetxt1" call BIS_fnc_rscLayer; 
	Lifelinetxt2Layer = "Lifelinetxt2" call BIS_fnc_rscLayer; 
	LifelinetxtdebugLayer1 = "Lifelinetxtdebug1" call BIS_fnc_rscLayer; 
	LifelinetxtdebugLayer2 = "Lifelinetxtdebug2" call BIS_fnc_rscLayer; 
	LifelinetxtdebugLayer3 = "Lifelinetxtdebug3" call BIS_fnc_rscLayer; 

	Lifeline_travel_meth = 1; //method of revive travel when changing stance to hit ground. 0 = use playnow anim, 1 =  use unit posture (unitPos)

	Debug_to = 2; //for debug sound
	// for experimentation
	// Lifelinefonts =["EtelkaMonospacePro","EtelkaMonospaceProBold","EtelkaNarrowMediumPro","LCD14","LucidaConsoleB","PuristaBold","PuristaLight","PuristaMedium","PuristaSemibold","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight","TahomaB"];
	Lifelinefonts =["EtelkaMonospacePro","PuristaBold","PuristaLight","PuristaMedium","PuristaSemibold","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight"];

	// some missions delete action menus (mouse scroll wheel menu) on start. So this will load the RO
	LifelineREV4_fnc_keyDown = {
		// Code to execute when the key is pressed down.
		// You can put your function logic here.
		// hint "MyKey is pressed!";
		Lifeline_Scope = 4;
		hint "..initializing";
		execVM "\Lifeline_Revive\init.sqf";
		execVM "\Lifeline_Revive\initserver.sqf";
	};

	/* LifelineREV4_fnc_keyUp = {
		// Code to execute when the key is released.
		// You can put your function logic here.
	}; 
	*/

	// temp debug vars	
	Debug_Lifeline_downequalstrue = true;	
	Debug_unconsciouswithouthandler = true;
	Debug_overtheshold = true;	
	Debug_Zeusorthirdparty = true;	
	Debug_invincible_or_captive = true;
	Debug_incapdeathtimelimit_not_zero = true;
	Debug_reviveinprogresserror = true;

};