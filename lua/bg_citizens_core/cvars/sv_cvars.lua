bgNPC:RegisterGlobalCvar('bgn_enable', bgNPC.cvar.bgn_enable, 
FCVAR_ARCHIVE, 'Toggles the modification activity. 1 - enabled, 0 - disabled.')

bgNPC:RegisterGlobalCvar('bgn_enable_wanted_mode', bgNPC.cvar.bgn_enable_wanted_mode,
FCVAR_ARCHIVE, 'Enables or disables wanted mode.')

bgNPC:RegisterGlobalCvar('bgn_wanted_time', bgNPC.cvar.bgn_wanted_time, 
FCVAR_ARCHIVE, 'The time you need to go through to remove the wanted level.')

bgNPC:RegisterGlobalCvar('bgn_max_npc', bgNPC.cvar.bgn_max_npc, 
FCVAR_ARCHIVE, 'The maximum number of background NPCs on the map.')

bgNPC:RegisterGlobalCvar('bgn_spawn_radius', bgNPC.cvar.bgn_spawn_radius, 
FCVAR_ARCHIVE, 'NPC spawn radius relative to the player.')

bgNPC:RegisterGlobalCvar('bgn_spawn_radius_visibility', bgNPC.cvar.bgn_spawn_radius_visibility, 
FCVAR_ARCHIVE, 'Triggers an NPC visibility check within this radius to avoid spawning entities in front of the player.')

bgNPC:RegisterGlobalCvar('bgn_spawn_radius_raytracing', bgNPC.cvar.bgn_spawn_radius_raytracing, 
FCVAR_ARCHIVE, 'Checks the spawn points of NPCs using ray tracing in a given radius. This parameter must not be more than - bgn_spawn_radius_visibility. 0 - Disable checker')

bgNPC:RegisterGlobalCvar('bgn_spawn_block_radius', bgNPC.cvar.bgn_spawn_block_radius, 
FCVAR_ARCHIVE, 'Prohibits spawning NPCs within a given radius. Must not be more than the parameter - bgn_spawn_radius_ray_tracing. 0 - Disable checker')

bgNPC:RegisterGlobalCvar('bgn_spawn_period', bgNPC.cvar.bgn_spawn_period, 
FCVAR_ARCHIVE, 'The period between the spawn of the NPC. Changes require a server restart.')

bgNPC:RegisterGlobalCvar('bgn_ptp_distance_limit', bgNPC.cvar.bgn_ptp_distance_limit, 
FCVAR_ARCHIVE, 'You can change the point-to-point limit for the instrument if you have a navigation mesh on your map.')

bgNPC:RegisterGlobalCvar('bgn_point_z_limit', bgNPC.cvar.bgn_point_z_limit, 
FCVAR_ARCHIVE, 'Height limit between points. Used to correctly define child points.')

bgNPC:RegisterGlobalCvar('bgn_arrest_mode', bgNPC.cvar.bgn_arrest_mode, 
FCVAR_ARCHIVE, 'Includes a player arrest module. Attention! It won\'t do anything in the sandbox. By default, there is only a DarkRP compatible hook. If you activate this module in an unsupported gamemode, then after the arrest the NPCs will exclude you from the list of targets.')

bgNPC:RegisterGlobalCvar('bgn_arrest_time', bgNPC.cvar.bgn_arrest_time, 
FCVAR_ARCHIVE, 'Sets the time allotted for your detention.')

bgNPC:RegisterGlobalCvar('bgn_arrest_time_limit', bgNPC.cvar.bgn_arrest_time_limit, 
FCVAR_ARCHIVE, 'Sets how long the police will ignore you during your arrest. If you refuse to obey after the lapse of time, they will start shooting at you.')

bgNPC:RegisterGlobalCvar('bgn_ignore_another_npc', bgNPC.cvar.bgn_ignore_another_npc, 
FCVAR_ARCHIVE, 'If this parameter is active, then NPCs will ignore any other spawned NPCs.')

local exists_types = {}
for npcType, v in pairs(bgNPC.npc_classes) do
    if not table.HasValue(exists_types, npcType) then
        bgNPC:RegisterGlobalCvar('bgn_npc_type_' .. npcType, 1, FCVAR_ARCHIVE)
        table.insert(exists_types, npcType)
    end
end