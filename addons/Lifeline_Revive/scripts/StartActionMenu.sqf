if (isServer) then {

	Lifeline_StartActionMenu = {

		_firstrun = false;
		Lifeline_MenuLoop = true;
		Lifeline_MenuScript = _thisScript; // Store the script handle

		_scope1countcompare = 0;
		_scope2countcompare = 0;
		_scope3countcompare = 0;
		_scopeOPFORcountcompare = 0;
		_scope1count = 0;
		_scope2count = 0;
		_scope3count = 0;
		_scope1count = 0;
		_scope1countOPFOR = 0;
		_scope2count = 0;
		_scope2countOPFOR = 0;
		_scope3count = 0;
		_scope3countOPFOR = 0;
		_scopeOPFORcount = 0;

		_scopeOPFORcounttext = "";	
		_scope1counttext = "";
		_scope2counttext = "";
		_scope3counttext = "";
		_scope1counttext = "";
		_scope2counttext = "";
		_scope3counttext = "";
		_scope1countOPFORtext = "";	
		_scope2countOPFORtext = "";
		_scope3countOPFORtext = "";

		_scope1texttotal = "";
		_scope2texttotal = "";
		_scope3texttotal = "";

		_LLRtext = "Start LLR";
		_colour = "#bfc9ca";
		_colourblue = "#009aff";
		_colourred = "#FF5733";
		_bluefluro = "#00d4ff";
		_redfluro = "#ec7063";
		_LLRtextPVP = "Start LLR PVP";
		 _font = "EtelkaMonospacePro";
		 _fontsize = str 1.3;

		_units = " units";		
		_units2 = " units";		
		_units2 = "";	

		_join = "  〉 ";
		_join2 = "  〉 ";	
		_join = "  〉";
		_join2 = "  〉";
		// _join3 = "｢"; 
		_join3 = "〉"; 
		_join3 = " "; 
		_join3 = "| "; 
		_join3 = ""; 
		_join3 = " 〉"; 

		if (!isNil "actionLifelineID1") then {player removeAction actionLifelineID1};
		if (!isNil "actionLifelineID2") then {player removeAction actionLifelineID2};
		if (!isNil "actionLifelineID3") then {player removeAction actionLifelineID3};
		if (!isNil "actionLifelineID4") then {player removeAction actionLifelineID4};
		if (!isNil "actionLifelineID5") then {player removeAction actionLifelineID5};

		while {Lifeline_MenuLoop} do {

			Lifeline_cancel = false;
			Lifeline_Side = side player;
			publicVariable "Lifeline_Side";
			Lifeline_OPFOR_Sides = Lifeline_Side call BIS_fnc_enemySides;
			publicVariable "Lifeline_OPFOR_Sides"; // THIS IS AN ARRAY OF ENEMY SIDES

			_groupsWPlayers = allGroups select {{isPlayer _x} count (units _x) > 0 }; 

			if (Lifeline_PVPstatus) then {
					// GROUP
					_scope1count = count (allunits select {side (group _x) == Lifeline_Side && (group _x) in _groupsWPlayers && simulationEnabled _x && isDamageAllowed _x && rating _x > -2000});
					_scope1countOPFOR = count (allunits select {side (group _x) in Lifeline_OPFOR_Sides && (group _x) in _groupsWPlayers && simulationEnabled _x && isDamageAllowed _x && rating _x > -2000});
					// ALL PLAYABLE (SLOTS)
					_scope2count = count (allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && isDamageAllowed _x && ((_x in playableUnits) || (_x in switchableUnits)) && rating _x > -2000});
					_scope2countOPFOR = count (allunits select {side (group _x) in Lifeline_OPFOR_Sides && simulationEnabled _x && isDamageAllowed _x && ((_x in playableUnits) || (_x in switchableUnits)) && rating _x > -2000});
					// SIDE	
					_scope3count = count (allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && isDamageAllowed _x && rating _x > -2000});
					_scope3countOPFOR = count (allunits select {side (group _x) in Lifeline_OPFOR_Sides && simulationEnabled _x && isDamageAllowed _x && rating _x > -2000});

					_scope1countOPFORtext = ((if (_scope1countOPFOR < 100) then {"0"} else {""}) + (if (_scope1countOPFOR < 10) then {"0"} else {""}) + str _scope1countOPFOR);
					_scope2countOPFORtext = ((if (_scope2countOPFOR < 100) then {"0"} else {""}) + (if (_scope2countOPFOR < 10) then {"0"} else {""}) + str _scope2countOPFOR);
					_scope3countOPFORtext = ((if (_scope3countOPFOR < 100) then {"0"} else {""}) + (if (_scope3countOPFOR < 10) then {"0"} else {""}) + str _scope3countOPFOR);
			};
			if (!Lifeline_PVPstatus) then {
				if (Lifeline_Include_OPFOR) then {
					// GROUP
					_scope1count = count (allunits select {(group _x) in _groupsWPlayers && side (group _x) == Lifeline_Side && simulationEnabled _x && isDamageAllowed _x && rating _x > -2000});
					// ALL PLAYABLE (SLOTS)
					_scope2count = count (allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && isDamageAllowed _x && ((_x in playableUnits) || (_x in switchableUnits)) && rating _x > -2000});
					// SIDE	
					_scope3count = count (allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && isDamageAllowed _x && rating _x > -2000});

					// OPFOR
					_scopeOPFORcount = count (allunits select {(side (group _x) in Lifeline_OPFOR_Sides && simulationEnabled _x && isDamageAllowed _x)});

					_scopeOPFORcounttext = ((if (_scopeOPFORcount < 100) then {"0"} else {""}) + (if (_scopeOPFORcount < 10) then {"0"} else {""}) + str _scopeOPFORcount);

					_scope1counttotal = _scope1count + _scopeOPFORcount;
					_scope2counttotal = _scope2count + _scopeOPFORcount;
					_scope3counttotal = _scope3count + _scopeOPFORcount;

					_scope1texttotal = ((if (_scope1counttotal < 100) then {"0"} else {""}) + (if (_scope1counttotal < 10) then {"0"} else {""}) + str _scope1counttotal);
					_scope2texttotal = ((if (_scope2counttotal < 100) then {"0"} else {""}) + (if (_scope2counttotal < 10) then {"0"} else {""}) + str _scope2counttotal);
					_scope3texttotal = ((if (_scope3counttotal < 100) then {"0"} else {""}) + (if (_scope3counttotal < 10) then {"0"} else {""}) + str _scope3counttotal);

				};
				if (!Lifeline_Include_OPFOR) then {
					// GROUP
					_scope1count = count (allunits select {side (group _x) == Lifeline_Side && (group _x) in _groupsWPlayers && simulationEnabled _x && isDamageAllowed _x && rating _x > -2000});
					// ALL PLAYABLE (SLOTS)
					_scope2count = count (allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && isDamageAllowed _x && ((_x in playableUnits) || (_x in switchableUnits)) && rating _x > -2000});
					// SIDE	
					_scope3count = count (allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && isDamageAllowed _x && rating _x > -2000});

				};	
			};

			_scope1counttext = ((if (_scope1count < 100) then {"0"} else {""}) + (if (_scope1count < 10) then {"0"} else {""}) + str _scope1count);
			_scope2counttext = ((if (_scope2count < 100) then {"0"} else {""}) + (if (_scope2count < 10) then {"0"} else {""}) + str _scope2count);
			_scope3counttext = ((if (_scope3count < 100) then {"0"} else {""}) + (if (_scope3count < 10) then {"0"} else {""}) + str _scope3count);

			LifelineremoveactionmenuIDs = {		
				if (Lifeline_cancel == false) then {
					"Lifeline_Revive\scripts\Lifeline_Global.sqf" remoteExec ["execVM",0,true];
					"Lifeline_Revive\scripts\Lifeline_ReviveEngine.sqf" remoteExec ["execVM",0,true];

					if (Lifeline_Hotwire) then {
						"Lifeline_Revive\scripts\bonus\hotwire_vehicles.sqf" remoteExec ["execVM",0,true];
					};
				};

				Lifeline_MenuLoop = false;
				if (!isNil "actionLifelineID1") then {player removeAction actionLifelineID1};
				if (!isNil "actionLifelineID2") then {player removeAction actionLifelineID2};
				if (!isNil "actionLifelineID3") then {player removeAction actionLifelineID3};
				if (!isNil "actionLifelineID5") then {player removeAction actionLifelineID5};
				player removeAction actionLifelineID4;

			};

			// Lifeline_PVPstatus = true;

			if !(_firstrun) then {
				if (Lifeline_PVPstatus) then {
						if (Lifeline_Scope == 4 || Lifeline_Scope == 1) then {
							actionLifelineID1 = player addAction ["<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtextPVP+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope1counttext+"</t> BLUFOR</t>"+_join2+"<t color='"+ _colourred+"'><t color='"+_redfluro+"'>"+ _scope1countOPFORtext+"</t> OPFOR</t>"+_join2+"Group   </t></t>", {hint "..initializing";Lifeline_Scope=1;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
						};
						if ((Lifeline_Scope == 4 || Lifeline_Scope == 2)) then {
							actionLifelineID2 = player addAction ["<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtextPVP+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope2counttext+"</t> BLUFOR</t>"+_join2+"<t color='"+ _colourred+"'><t color='"+_redfluro+"'>"+ _scope2countOPFORtext+"</t> OPFOR</t>"+_join2+"Slots   </t></t>", {hint "..initializing";Lifeline_Scope=2;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
						};
						if (Lifeline_Scope == 4 || Lifeline_Scope == 3) then {
							actionLifelineID3 = player addAction ["<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtextPVP+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope3counttext+"</t> BLUFOR</t>"+_join2+"<t color='"+ _colourred+"'><t color='"+_redfluro+"'>"+_scope3countOPFORtext+"</t> OPFOR</t>"+_join2+"Side    </t></t>", {hint "..initializing";Lifeline_Scope=3;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
						};

				};
				if (!Lifeline_PVPstatus) then {
					if (!Lifeline_Include_OPFOR) then {
						if (Lifeline_Scope == 4 || Lifeline_Scope == 1) then {
							actionLifelineID1 = player addAction ["<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtext+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope1counttext+"</t> BLUFOR Group  </t></t></t>", {hint "..initializing";Lifeline_Scope=1;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
						};
						if ((Lifeline_Scope == 4 || Lifeline_Scope == 2)) then {
							actionLifelineID2 = player addAction ["<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtext+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope2counttext+"</t> BLUFOR Slots  </t></t></t>", {hint "..initializing";Lifeline_Scope=2;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
						};
						if (Lifeline_Scope == 4 || Lifeline_Scope == 3) then {
							actionLifelineID3 = player addAction ["<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtext+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope3counttext+"</t> BLUFOR Side   </t></t></t>", {hint "..initializing";Lifeline_Scope=3;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
						};

					};					
					if (Lifeline_Include_OPFOR) then {
						// _scope1texttotal = "080";
						// _scope2texttotal = "106";
						// _scope3texttotal = "345";
						if (Lifeline_Scope == 4 || Lifeline_Scope == 1) then {
							actionLifelineID1 = player addAction ["<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtext+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope1counttext+"</t> BLUFOR Group</t>"+_join2+"<t color='"+ _colourred+"'><t color='"+_redfluro+"'>"+ _scopeOPFORcounttext+"</t> OPFOR Side  </t>"+_join3+"<t color='"+_colour+"'>Total "+_scope1texttotal+"   </t></t></t>", {hint "..initializing";Lifeline_Scope=1;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
						};
						if (Lifeline_Scope == 4 || Lifeline_Scope == 2) then {
							actionLifelineID2 = player addAction ["<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtext+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope2counttext+"</t> BLUFOR Slots</t>"+_join2+"<t color='"+ _colourred+"'><t color='"+_redfluro+"'>"+ _scopeOPFORcounttext+"</t> OPFOR Side  </t>"+_join3+"<t color='"+_colour+"'>Total "+_scope2texttotal+"   </t></t></t>", {hint "..initializing";Lifeline_Scope=2;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
						};
						if ((Lifeline_Scope == 4 || Lifeline_Scope == 3)) then {
							actionLifelineID3 = player addAction ["<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtext+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope3counttext+"</t> BLUFOR Side </t>"+_join2+"<t color='"+ _colourred+"'><t color='"+_redfluro+"'>"+ _scopeOPFORcounttext+"</t> OPFOR Side  </t>"+_join3+"<t color='"+_colour+"'>Total "+_scope3texttotal+"   </t></t></t>", {hint "..initializing";Lifeline_Scope=3;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
						};
					};

				};
				if (Lifeline_Include_OPFOR && !Lifeline_PVPstatus) then {
					actionLifelineID5 = player addAction ["<t size='" + _fontsize + "' font = '" + _font + "' color='"+_colour+"'>Exclude<t color='#FF5733'> OPFOR</t></t>", {
						if (Lifeline_Include_OPFOR) then {Lifeline_Include_OPFOR = false} else {Lifeline_Include_OPFOR = true};
						// [] call Lifeline_StartActionMenuForce;
						terminate Lifeline_MenuScript;
						Lifeline_cancel = true;
						// [] call LifelineremoveactionmenuIDs;
						[] spawn Lifeline_StartActionMenu;
					}];
				};				
				if (!Lifeline_Include_OPFOR && !Lifeline_PVPstatus) then {
					actionLifelineID5 = player addAction ["<t size='" + _fontsize + "' font = '" + _font + "' color='"+_colour+"'>Include<t color='#FF5733'> OPFOR</t></t>", {
						if (Lifeline_Include_OPFOR) then {Lifeline_Include_OPFOR = false} else {Lifeline_Include_OPFOR = true};
						// [] call Lifeline_StartActionMenuForce;
						terminate Lifeline_MenuScript;
						Lifeline_cancel = true;
						// [] call LifelineremoveactionmenuIDs;
						[] spawn Lifeline_StartActionMenu;
					}];
				};

				actionLifelineID4 = player addAction ["<t size='" + _fontsize + "' font = '" + _font + "' color='#FF5733'>CANCEL LLR</t>", {Lifeline_cancel = true;[] call LifelineremoveactionmenuIDs;}];

			} else {

				if (!Lifeline_PVPstatus) then {
					if (!Lifeline_Include_OPFOR) then {
						if ((Lifeline_Scope == 4 || Lifeline_Scope == 1) && _scope1count != _scope1countcompare) then {
							// actionLifelineID1 = player addAction [format ["<t size='1.5' color='#DAF7A6'>Lifeline Revive | </t><t size='1.5' color='#00FF0A'>%1 units</t><t size='1.5' color='#DAF7A6'> | Group</t>",_scope1counttext], {hint "..initializing";Lifeline_Scope=1;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
							player setUserActionText [actionLifelineID1, "<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtext+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope1counttext+"</t> BLUFOR Group  </t></t></t>"];
						};
						if ((Lifeline_Scope == 4 || Lifeline_Scope == 2) && _scope2count != _scope2countcompare) then {
							// actionLifelineID2 = player addAction [format ["<t size='1.5' color='#DAF7A6'>Lifeline Revive | </t><t size='1.5' color='#00FF0A'>%1 units</t><t size='1.5' color='#DAF7A6'> | Side</t>",_scope2counttext], {hint "..initializing";Lifeline_Scope=2;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
							player setUserActionText [actionLifelineID2, "<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtext+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope2counttext+"</t> BLUFOR Slots  </t></t></t>"];
						};
						if ((Lifeline_Scope == 4 || Lifeline_Scope == 3) && _scope3count != _scope3countcompare) then {
							// actionLifelineID3 = player addAction [format ["<t size='1.5' color='#DAF7A6'>Lifeline Revive | </t><t size='1.5' color='#00FF0A'>%1 units</t><t size='1.5' color='#DAF7A6'> | Side Playable Slots</t>",_scope3counttext], {hint "..initializing";Lifeline_Scope=3;publicVariable "Lifeline_Scope";[] call LifelineremoveactionmenuIDs}];
							player setUserActionText [actionLifelineID3, "<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtext+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope3counttext+"</t> BLUFOR Side   </t></t></t>"];
						};
					};
					if (Lifeline_Include_OPFOR) then {
							if ((Lifeline_Scope == 4 || Lifeline_Scope == 1) && (_scope1count != _scope1countcompare || _scopeOPFORcount != _scopeOPFORcountcompare)) then {
								player setUserActionText [actionLifelineID1, "<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtext+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope1counttext+"</t> BLUFOR Group</t>"+_join2+"<t color='"+ _colourred+"'><t color='"+_redfluro+"'>"+ _scopeOPFORcounttext+"</t> OPFOR Side  </t>"+_join3+"<t color='"+_colour+"'>Total "+_scope1texttotal+"   </t></t></t>"];
							};
							if ((Lifeline_Scope == 4 || Lifeline_Scope == 2) && (_scope2count != _scope2countcompare || _scopeOPFORcount != _scopeOPFORcountcompare)) then {
								player setUserActionText [actionLifelineID2, "<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtext+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope2counttext+"</t> BLUFOR Slots</t>"+_join2+"<t color='"+ _colourred+"'><t color='"+_redfluro+"'>"+ _scopeOPFORcounttext+"</t> OPFOR Side  </t>"+_join3+"<t color='"+_colour+"'>Total "+_scope2texttotal+"   </t></t></t>"];
							};
							if ((Lifeline_Scope == 4 || Lifeline_Scope == 3) && (_scope3count != _scope3countcompare || _scopeOPFORcount != _scopeOPFORcountcompare)) then {
								player setUserActionText [actionLifelineID3, "<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtext+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope3counttext+"</t> BLUFOR Side </t>"+_join2+"<t color='"+ _colourred+"'><t color='"+_redfluro+"'>"+ _scopeOPFORcounttext+"</t> OPFOR Side  </t>"+_join3+"<t color='"+_colour+"'>Total "+_scope3texttotal+"   </t></t></t>"];
							};
					};
				};
				if (Lifeline_PVPstatus) then {
						if (Lifeline_Scope == 4 || Lifeline_Scope == 1) then {
							player setUserActionText [actionLifelineID1, "<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtextPVP+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope1counttext+"</t> BLUFOR</t>"+_join2+"<t color='"+ _colourred+"'><t color='"+_redfluro+"'>"+_scope1countOPFORtext+"</t> OPFOR</t>"+_join2+"Group   </t></t>"];
						};
						if (Lifeline_Scope == 4 || Lifeline_Scope == 2) then {
							player setUserActionText [actionLifelineID2, "<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtextPVP+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope2counttext+"</t> BLUFOR</t>"+_join2+"<t color='"+ _colourred+"'><t color='"+_redfluro+"'>"+_scope2countOPFORtext+"</t> OPFOR</t>"+_join2+"Slots   </t></t>"];
						};
						if ((Lifeline_Scope == 4 || Lifeline_Scope == 3)) then {
							player setUserActionText [actionLifelineID3, "<t size='"+_fontsize+"' font = '"+_font+"'><t color='"+_colour+"'>"+_LLRtextPVP+"</t>"+_join+"<t color='"+_colourblue+"'><t color='"+_bluefluro+"'>"+_scope3counttext+"</t> BLUFOR</t>"+_join2+"<t color='"+ _colourred+"'><t color='"+_redfluro+"'>"+_scope3countOPFORtext+"</t> OPFOR</t>"+_join2+"Side    </t></t>"];
						};
				};

			};

			_scope1countcompare = _scope1count;
			_scope2countcompare = _scope2count;
			_scope3countcompare = _scope3count;
			_scope1countOPFORcompare = _scope1countOPFOR;
			_scope2countOPFORcompare = _scope2countOPFOR;
			_scope3countOPFORcompare = _scope3countOPFOR;
			_scopeOPFORcountcompare = _scopeOPFORcount;

			if (scriptDone Lifeline_MenuScript) exitWith {diag_log "============================================================EXIT LOOP"};

			sleep 1;

			_firstrun = true;
		}; // end of loop

	};

	[] spawn Lifeline_StartActionMenu;

}; //if (isServer) then {