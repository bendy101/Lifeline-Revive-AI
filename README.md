# Lifeline Revive AI - Arma 3 mod

![lifeline Revive AI Logo](https://images.steamusercontent.com/ugc/15510604576896877362/0CDF5A96D9C25C8C7E53F802FA6FF335C48312D8/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false)

[Here on Steam](https://steamcommunity.com/sharedfiles/filedetails/?id=3343235386)

Lifeline Revive AI enables AI units to heal and revive, offering the most versatile solution in the workshop. It is compatible with ACE Medical or vanilla Arma, designed for maximum workshop mission compatibility, and enhances immersion with voiced AI medics.

## Key Features
- AI units revive players and each other with 600+ audio samples from 15+ voice actors (ElevenLabs), randomized phrasing for natural dialogue.
- Works with or without ACE Medical.
- Supports single-player, multiplayer, and teamswitch.
- Optional HUD feedback: medic distance, injury status, and incapacitated unit list.
- Smoke grenades thrown by medics before reviving (optional).
- MASCAL (mass casualty) warnings when all units are down.
- Auto-disables other revive systems (vanilla, SOG, Psycho, Grimes).
- Scope options ('Group', 'Slots', 'Side') auto-start in missions, with an option for manual start menu.
- Faster load than previous versions.
- PVP: same settings across all sides. PVE: revive is optional for OPFOR.
- Medic blacklist: exclude mounted weapon units, drivers, pilots, or vehicle occupants.
- Unblock blacklist during MASCAL.
- Improved queue handling for faster incapacitated unit processing.
- Works with Lambs and SOG AI.

### With ACE Medical
- Uses ACE medical system; compatible with older ACE versions.
- Tweaks for non-ACE missions: vanilla first aid kits include blood, plasma, and splints; optional faster enemy bleedout to trigger tasks quicker.

### Without ACE
- Custom damage model: body part injuries, bandages, blood IV, morphine, CPR via addaction menu.
- Adjustable difficulty: bandage range sets max bandages needed; optional instant death blocker with 3 difficulty levels.

### Bonus Features *– unrelated to revive but useful*
- Hotwire locked vehicles (requires toolkit, excludes armored vehicles).
- Auto-crouch for AI in 'Aware' behavior for realism.
- Explosive specialist role for all units to defuse bombs (requires toolkit).
- ACE: optional Blufor tracking limited to physical GPS units.

## Recent Updates
- [2025.05.27] Signed. Now mod works on dedi server (non-script version).
- [2025.05.22] Server version link at [GitHub](https://github.com/bendy101/LifeLine_Revive.VR) & option to turn off add units hint.
- [2025.05.20] SOG AI compatibility (experimental).
- [2025.05.16] Limit number of medics for more firepower. Force use of Arma 3 vanilla medic.
- [2025.05.08] New Self Revive options. No self-revive if enemy too close. Return fire prioritized.
- [2025.05.03] Improved start action menu (includes OPFOR); many bug fixes.
- [2025.02.10] ACE: Vanilla first aid kits now include plasma/splints.
- [2025.02.08] ACE: Blufor tracking limited to GPS units; fixed medic captive state.
- [2025.02.06] Patched for ACE 3.19; Antistasi captive state fix; removed startup popup; added option for faster enemy bleedout in ACE missions.

## Known Issues
- Some missions disable start action menu (use Ctrl+Shift+Alt+L workaround).
- AI pathfinding issues; idle stopper partially mitigates.
- Medic direction changes abruptly; voices too calm in combat; occasional glitches (e.g., medic rising into air, reviving through walls).
- Map icons sometimes bugged; collision disabled to aid pathfinding, causing units to clip objects.

## Future Plans
- Language packs (Deutsch, Français, Italiano, Español, Russian).
- ~~Dedicated server version nearing completion.~~ DONE!
- Carrying/dragging without ACE.
- ~~OPFOR inclusion.~~ DONE!

## Run Mod on Dedi Server
Should work on a dedicated server as a mod. Ensure the mod is running on the server and all player machines. The player in the first slot gets the start menu, and their CBA settings determine server options.

## Server Script Version
Should work on dedicated servers and as a mission script. Still in testing; feedback welcome.  
[Server version on GitHub](https://github.com/bendy101/LifeLine_Revive.VR)

## About
Created by composer/sound designer Benedict Harris, emphasizing immersive voiced AI medics.  
[Benedict Music](https://www.benedictmusic.eu)  
Mod is on [GitHub](https://github.com/bendy101/Lifeline-Revive-AI) for community contributions.

## Thanks
Thanks for help: Rick O Shay, pierremgi, and ACE team members: BaerMitUmlaut, GrimIsBall, MiszczuZPolski, prisoner, and Dart.

## Licence
![Arma Public Licence (APL)](https://i.imgur.com/YY0tGLj.png)  
[Arma Public Licence (APL)](https://www.bohemia.net/community/licenses/arma-public-license)  
With this licence, you are free to adapt (i.e., modify, rework, or update) and share (i.e., copy, distribute, or transmit) the material **under the following conditions:**

**• Attribution** – You must attribute the material in the manner specified by the author or licensor (but not in any way that suggests they endorse you or your use of the material).  
**• Noncommercial** – You may not use this material for any commercial purposes.
