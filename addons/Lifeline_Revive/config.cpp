class CfgPatches
{
	class Lifeline_revive
	{
		name="Lifeline Revive";
		units[]={};
		weapons[]={};
		requiredVersion=1.0;
		requiredAddons[]=
		{
			"cba_xeh",
			"cba_settings",
		};
		author="Lifeline";
		url="";
		version="1.0.4";
	};
};

ReviveMode = 0;

class Extended_PreInit_EventHandlers {
    class My_pre_init_LifeLine {
        init = "call compile preprocessFileLineNumbers '\Lifeline_Revive\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
	class My_post_init_LifeLine
	{
		init = "call compile preProcessFileLineNumbers '\Lifeline_Revive\XEH_postInit.sqf'";
	};
};

class cfgMods
{
	author="Bendy";
	timepacked="1505183013";
};

class CfgSounds {
	sounds[] = {};
	sound = [];

	#include "\Lifeline_Revive\sound\Lifeline_Sound.hpp"
    // #include "sound\Lifeline_Sound.hpp"

};

