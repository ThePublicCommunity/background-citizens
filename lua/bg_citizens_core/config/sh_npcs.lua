--[[
	WIKI:
	https://background-npcs.itpony.ru/wiki/Config%20Structure
--]]

--[[
	Actor - the so-called NPCs that are part of this system.

	The name of the table key does not matter. The main thing is the team in which the actor is.
	Teams:
		1. residents - main team for citizens and police. The police will always protect residents.
		2. police - the police are trying to protect everyone. But if the entity is not part of the residents team, they will attack.
		3. player - ignores any player, depending on the config settings may not allow him to inflict damage.
		4. bandits - arbitrary team for troublemakers. At the moment it has no special settings.

	The actions of the actors depend on the settings of the parameters with the prefix at_:
		at_{name}_range - the maximum number parameter for randomizing events (Default - 100)
		at_random - events that are executed randomly if the actor does not have taregts.
		at_damage - events that are performed if the actor takes damage.
		at_protect - events that are performed for other actors, if they see the actor taking damage.

	AT default params:
		ignore - ignores the state change, and leaves the active state.
		idle - the state in which the actor is idle, performing a random animation.
		walk - the state in which the actor moves through the points on the map.
		fear - a state in which the actor tries to escape from the attacker.
		calling_police - a state in which the actor tries to call the police to declare the attacker wanted. After the call, the state will change to "fear"
		defense - a state in which the actor will attack and pursue the attacker.
		impingement - a state in which an actor will try to attack the nearest actor who has no team in common.

	Explanation of other parameters:
		class - NPC class. The class directly affects the playback of animations and the operation of models, use it carefully.
		name - Any NPC name. Displayed in the options menu.
		fullness - the parameter of the world occupancy for each actor (1 to 100)
		limit - alternative for the "fullness" parameter, sets a fixed number of NPCs
		team - the actor's team is used for interaction logic. Explanation above ↑
		weapons - a weapon that an actor can have. If you don't want the actor to have a weapon, leave the list empty or delete the parameter.
		money - the amount of money dropped from the actor after death. The first parameter is the minimum, the second parameter is the maximum (Default used in DarkRP)
		defaultModels - if true, then the actors will spawn with the standard model mixed with the custom ones. If you want to use only custom models, set the parameter to false
		models - custom actor model. Please note that the model is directly dependent on the class used. If the model is incompatible with the selected class, it can - show an error, not be displayed, the actor can be idle.
		at_ - explanation above ↑
		health - the health that the actor spawns with.
			Can be a number: health = 100
			Can be a table with the possibility of randomness: health = { 100, 200 }
		wanted_level - actors who will spawn only if any entity has the required wanted level. After all the actors have lost their targets, they are removed (1 to 5)
		weaponSkill - The level of circulation of NPCs with weapons. (https://wiki.facepunch.com/gmod/Enums/WEAPON_PROFICIENCY)
		randomSkin - enable the creation of random skins for NPCs
		randomBodygroups - enable the creation of random bodygroups for NPCs
		disableStates - disable NPC states switching. Suitable if you need to keep the default logic of the NPC.
		respawn_delay - sets a delay for the appearance of new NPCs after the death of any of the existing
		validator - a function that checks the spawn before the entity is created. Suitable for system checks. For broader checks, use the "BGN_OnValidSpawnActor" or "BGN_PreSpawnActor" hook
--]]

--[[
	Explanation:
	The states that are in the "danger" category are used to determine the state of danger of the NPC when taking damage.
--]]
bgNPC.cfg.npcs_states = {
	['calmly'] = {
		'idle',
		'walk',
		'dialogue',
		'sit_to_chair',
		'dv_vehicle_drive',
		'steal',
		'arrest',
		'retreat'
	},
	['danger'] = {
		'fear',
		'defense',
		'calling_police',
		'impingement',
	}
}

-- NPC classes that fill the streets
bgNPC.cfg.npcs_template = {
	['citizen'] = {
		class = 'npc_citizen',
		name = 'Civilian',
		fullness = 80,
		team = { 'residents' },
		weapons = { 'weapon_pistol', "weapon_shotgun" },
		money = { 0, 100 },
		health = 75,
		weaponSkill = WEAPON_PROFICIENCY_AVERAGE,
		randomSkin = false,
		randomBodygroups = false,
		defaultModels = true,
		at_random_range = 120,
		at_random = {
			['walk'] = 50,
			['idle'] = 25,
			['dialogue'] = 25,
			['sit_to_chair'] = 10,
			['dv_vehicle_drive'] = 10,
		},
		at_damage_range = 100,
		at_damage = {
			['fear'] = 50,
			['defense'] = 50,
		},
		at_protect_range = 100,
		at_protect = {
			['fear'] = 80,
			['defense'] = 20,
		}
	},
	['pilferer'] = {
		class = 'npc_citizen',
		name = 'Pilferer',
		fullness = 20,
		team = { 'bandits' },
		weapons = { 'weapon_pistol', 'weapon_357', "weapon_smg1" },
		money = { 100, 1000 },
		health = 75,
		weaponSkill = WEAPON_PROFICIENCY_GOOD,
		randomSkin = true,
		randomBodygroups = true,
		defaultModels = false,
		models = {
			'models/humans/group02/chef1.mdl',
			'models/humans/group02/chef2.mdl',
			'models/humans/group02/tale_01.mdl',
			'models/humans/group02/tale_03.mdl',
			'models/humans/group02/tale_04.mdl',
			'models/humans/group02/tale_05.mdl',
			'models/humans/group02/tale_06.mdl',
			'models/humans/group02/tale_07.mdl',
			'models/humans/group02/tale_08.mdl',
			'models/humans/group02/tale_09.mdl',
			'models/humans/group02/temale_01.mdl',
			'models/humans/group02/temale_02.mdl',
			'models/humans/group02/temale_07.mdl',
		},
		at_random_range = 121,
		at_random = {
			['walk'] = 50,
			['idle'] = 25,
			['steal'] = 25,
			['impingement'] = 1,
			['sit_to_chair'] = 10,
			['dv_vehicle_drive'] = 10,
		},
		at_damage_range = 100,
		at_damage = {
			['defense'] = 100,
		},
		at_protect_range = 100,
		at_protect = {
			['defense'] = 100,
		}
	},
	['gangster'] = {
		class = 'npc_citizen',
		name = 'Gangster',
		fullness = 0,
		team = { 'bandits' },
		weapons = { 'weapon_pistol', 'weapon_shotgun', 'weapon_ar2', 'weapon_crowbar' },
		money = { 0, 150 },
		health = 50,
		weaponSkill = WEAPON_PROFICIENCY_AVERAGE,
		randomSkin = true,
		randomBodygroups = true,
		defaultModels = false,
		models = {
			'models/survivors/npc/amy.mdl',
			'models/survivors/npc/candace.mdl',
			'models/survivors/npc/carson.mdl',
			'models/survivors/npc/chris.mdl',
			'models/survivors/npc/damian.mdl',
			'models/survivors/npc/gregory.mdl',
			'models/survivors/npc/isa.mdl',
			'models/survivors/npc/john.mdl',
			'models/survivors/npc/lucus.mdl',
			'models/survivors/npc/lyndsay.mdl',
			'models/survivors/npc/margaret.mdl',
			'models/survivors/npc/matt.mdl',
			'models/survivors/npc/rachel.mdl',
			'models/survivors/npc/rufus.mdl',
			'models/survivors/npc/tyler.mdl',
			'models/survivors/npc/wolfgang.mdl',
		},
		at_random_range = 115,
		at_random = {
			['walk'] = 70,
			['idle'] = 10,
			['impingement'] = 5,
			['sit_to_chair'] = 10,
			['dv_vehicle_drive'] = 10,
		},
		at_damage_range = 100,
		at_damage = {
			['defense'] = 100,
		},
		at_protect_range = 200,
		at_protect = {
			['ignore'] = 195,
			['defense'] = 5,
		}
	},
	['police'] = {
		class = 'npc_metropolice',
		name = 'Police',
		fullness = 0,
		team = { 'residents', 'police' },
		weapons = { 'weapon_pistol' },
		money = { 0, 170 },
		health = 70,
		weaponSkill = WEAPON_PROFICIENCY_AVERAGE,
		randomSkin = true,
		randomBodygroups = true,
		at_random_range = 100,
		at_random = {
			['walk'] = 80,
			['idle'] = 10,
			['dialogue'] = 10,
			['dv_vehicle_drive'] = 10,
		},
		at_damage_range = 100,
		at_damage = {
			['defense'] = 20,
			['arrest'] = 80
		},
		at_protect_range = 100,
		at_protect = {
			['defense'] = 20,
			['arrest'] = 80
		}
	},
	['civil_defense'] = {
		class = 'npc_metropolice',
		name = 'Сivil Defense',
		respawn_delay = 5,
		fullness = 0,
		wanted_level = 2,
		team = { 'residents', 'police' },
		weapons = { 'weapon_smg1' },
		health = { 80, 90 },
		weaponSkill = WEAPON_PROFICIENCY_GOOD,
		randomSkin = true,
		randomBodygroups = true,
		defaultModels = false,
		models = {
			'models/armored_police/arpolice_npc.mdl',
		},
		money = { 0, 200 },
		at_damage_range = 100,
		at_damage = { ['defense'] = 100 },
		at_protect_range = 100,
		at_protect = { ['defense'] = 100 },
	},
	['special_forces'] = {
		class = 'npc_combine_s',
		name = 'Special Forces',
		respawn_delay = 15,
		fullness = 0,
		wanted_level = 3,
		team = { 'residents', 'police' },
		weapons = { 'weapon_ar2' },
		health = { 100, 110 },
		weaponSkill = WEAPON_PROFICIENCY_VERY_GOOD,
		randomSkin = true,
		randomBodygroups = true,
		defaultModels = false,
		models = {
			'models/armored_elite/armored_elite_npc.mdl',
		},
		money = { 0, 250 },
		at_damage_range = 100,
		at_damage = { ['defense'] = 100 },
		at_protect_range = 100,
		at_protect = { ['defense'] = 100 },
	},
	['special_forces_2'] = {
		class = 'npc_combine_s',
		name = 'Reinforced Special Forces',
		respawn_delay = 15,
		fullness = 0,
		wanted_level = 4,
		team = { 'residents', 'police' },
		weapons = { 'weapon_shotgun' },
		health = { 110, 120 },
		weaponSkill = WEAPON_PROFICIENCY_PERFECT,
		randomSkin = true,
		randomBodygroups = true,
		defaultModels = false,
		models = {
			'models/armored_elite/armored_elite_npc.mdl',
		},
		money = { 0, 300 },
		at_damage_range = 100,
		at_damage = { ['defense'] = 100 },
		at_protect_range = 100,
		at_protect = { ['defense'] = 100 },
	},
	['police_helicopter'] = {
		class = 'npc_apache_scp_sb',
		name = 'Assault Helicopter',
		disableStates = true,
		respawn_delay = 15,
		limit = 1,
		wanted_level = 5,
		team = { 'residents', 'police' },
		money = { 0, 500 },
		at_damage_range = 100,
		at_damage = { ['defense'] = 100 },
		at_protect_range = 100,
		at_protect = { ['defense'] = 100 },
		validator = function(self, type)
			if list.Get('NPC')[self.class] == nil then
				return false
			end
		end,
	},
}