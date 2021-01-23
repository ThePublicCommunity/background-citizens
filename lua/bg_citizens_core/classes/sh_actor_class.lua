BGN_ACTOR = {}

function BGN_ACTOR:Instance(npc, type, data)
    local obj = {}
    obj.npc = npc
    obj.class = npc:GetClass()
    obj.data = data
    obj.type = type
    obj.reaction = ''

    obj.state_data = {
        state = 'none',
        data = {}
    }

    if SERVER then
        obj.next_anim = nil
        obj.sync_animation_delay = 0
    end

    obj.anim_time = 0
    obj.anim_time_normal = 0
    obj.loop_time = 0
    obj.loop_time_normal = 0
    obj.anim_is_loop = false
    obj.anim_name = ''
    obj.is_animated = false
    obj.old_state = nil
    obj.state_lock = false

    obj.isBgnActor = true
    obj.targets = {}

    obj.npc_schedule = -1
    obj.npc_state = -1

    function obj:SyncData()
        if CLIENT then return end

        local npc = self:GetNPC()
        if not IsValid(npc) then return end

        net.InvokeAll('bgn_actor_sync_data_client', npc, {
            anim_name = self.anim_name,
            reaction = self.reaction,
            anim_time = self.anim_time,
            loop_time = self.loop_time,
            anim_is_loop = self.anim_is_loop,
            is_animated = self.is_animated,
            old_state = self.old_state,
            state_lock = self.state_lock,
            targets = self.targets,
            state_data = self.state_data,
            npc_schedule = self.npc_schedule,
            npc_state = self.npc_state,
            anim_time_normal = self.anim_time_normal,
            loop_time_normal = self.loop_time_normal,
        })
    end

    function obj:SyncReaction()
        if CLIENT then return end

        local npc = self:GetNPC()
        if not IsValid(npc) then return end

        net.InvokeAll('bgn_actor_sync_data_reaction_client', npc, {
            reaction = self.reaction,
        })
    end

    function obj:SyncSchedule()
        if CLIENT then return end

        local npc = self:GetNPC()
        if not IsValid(npc) then return end

        net.InvokeAll('bgn_actor_sync_data_schedule_client', npc, {
            npc_schedule = self.npc_schedule,
            npc_state = self.npc_state,
        })
    end

    function obj:SyncTargets()
        if CLIENT then return end

        local npc = self:GetNPC()
        if not IsValid(npc) then return end

        net.InvokeAll('bgn_actor_sync_data_targets_client', npc, {
            targets = self.targets,
        })
    end

    function obj:SyncState()
        if CLIENT then return end

        local npc = self:GetNPC()
        if not IsValid(npc) then return end

        net.InvokeAll('bgn_actor_sync_data_state_client', npc, {
            old_state = self.old_state,
            state_lock = self.state_lock,
            state_data = self.state_data,
        })
    end

    function obj:SyncAnimation()
        if CLIENT then return end

        local npc = self:GetNPC()
        if not IsValid(npc) then return end

        net.InvokeAll('bgn_actor_sync_data_animation_client', npc, {
            anim_name = self.anim_name,
            anim_time = self.anim_time,
            loop_time = self.loop_time,
            anim_is_loop = self.anim_is_loop,
            is_animated = self.is_animated,
            anim_time_normal = self.anim_time_normal,
            loop_time_normal = self.loop_time_normal,
        })
    end

    function obj:IsAlive()
        if IsValid(self.npc) and self.npc:Health() > 0 then
            return true
        end
        return false
    end

    function obj:SetReaction(reaction)
        self.reaction = reaction
        self:SyncReaction()
    end

    function obj:GetLastReaction()
        return self.reaction
    end

    function obj:GetNPC()
        return self.npc
    end

    function obj:GetData()
        return self.data
    end

    function obj:GetClass()
        return self.class
    end

    function obj:GetType()
        return self.type
    end

    function obj:IsValid()
        return IsValid(self.npc)
    end

    function obj:ClearSchedule()
        if not IsValid(self.npc) then return end
        
        self.npc:SetNPCState(NPC_STATE_IDLE)
        self.npc:ClearSchedule()

        self.npc_schedule = self.npc:GetCurrentSchedule()
        self.npc_state = self.npc:GetNPCState()

        self:SyncSchedule()
    end

    function obj:AddTarget(ent)
        if self:GetNPC() ~= ent and not table.HasValue(self.targets, ent) then            
            table.insert(self.targets, ent)

            self:SyncTargets()
        end
    end

    function obj:RemoveTarget(ent, index)
        local count = #self.targets

        if IsValid(ent) and IsValid(self.npc) and ent:IsPlayer() then
            self.npc:AddEntityRelationship(ent, D_NU, 99)
        end

        if index ~= nil and isnumber(index) then
            table.remove(self.targets, index)
        else
            table.RemoveByValue(self.targets, ent)
        end

        if count > 0 and #self.targets <= 0 then
            hook.Run('BGN_ResetTargetsForActor', self)
        end

        self:SyncTargets()
    end

    function obj:RemoveAllTargets()
        for _, t in ipairs(self.targets) do
            self:RemoveTarget(t)
        end
    end

    function obj:HasTarget(ent)
        return table.HasValue(self.targets, ent)
    end

    function obj:TargetsCount()
        return table.Count(self.targets)
    end

    function obj:GetNearTarget()
        local target = NULL
        local dist = 0
        local self_npc = self:GetNPC()

        for _, npc in ipairs(self.targets) do
            if IsValid(npc) then
                if not IsValid(target) then
                    target = npc
                    dist = npc:GetPos():DistToSqr(self_npc:GetPos())
                elseif npc:GetPos():DistToSqr(self_npc:GetPos()) < dist then
                    target = npc
                    dist = npc:GetPos():DistToSqr(self_npc:GetPos())
                end
            end
        end

        return target
    end

    function obj:RecalculationTargets()
        for i = #self.targets, 1, -1 do
            local target = self.targets[i]
            if not IsValid(target) then
                self:RemoveTarget(nil, i)
            elseif target:IsPlayer() and target:Health() <= 0 then
                self:RemoveTarget(nil, i)
            end
        end

        return self.targets
    end

    function obj:StateLock(lock)
        lock = lock or false
        self.state_lock = lock

        self:SyncState()
    end

    function obj:IsStateLock()
        return self.state_lock
    end

    function obj:SetOldState()
        if self:GetData().disableStates then return end
        if self.state_lock then return end
        
        if self.old_state ~= nil then
            self.state_data = self.old_state
            self.old_state = nil

            if IsValid(self.npc) then
                hook.Run('BGN_SetNPCState', self, 
                    self.state_data.state, self.state_data.data)
            end
        end
    end

    function obj:SetState(state, data)
        if self:GetData().disableStates then return end
        if self.state_lock then return end

        local hook_result = hook.Run('BGN_PreSetNPCState', self, state, data)
        if hook_result ~= nil then
            if isbool(hook_result) and not hook_result then
                return
            end
            
            if istable(hook_result) and hook_result.state ~= nil then
                state = hook_result.state
                data = hook_result.data
            end
        end

        if SERVER and self.state_data.state ~= state and math.random(0, 10) <= 1 then
            local target = self:GetNearTarget()
            if IsValid(target) and target:GetPos():DistToSqr(self.npc:GetPos()) < 250000 then
                if state == 'fear' then
                    local male_scream = {
                        'ambient/voices/m_scream1.wav',
                        'vo/coast/bugbait/sandy_help.wav',
                        'vo/npc/male01/help01.wav',
                        'vo/Streetwar/sniper/male01/c17_09_help01.wav',
                        'vo/Streetwar/sniper/male01/c17_09_help02.wav'
                    }

                    local female_scream = {
                        'ambient/voices/f_scream1.wav',
                        'vo/canals/arrest_helpme.wav',
                        'vo/npc/female01/help01.wav',
                        'vo/npc/male01/help01.wav',
                    }

                    local npc_model = self.npc:GetModel()
                    local scream_sound = nil
                    if tobool(string.find(npc_model, 'male_*')) then
                        scream_sound = table.Random(male_scream)
                    elseif tobool(string.find(npc_model, 'female_*')) then
                        scream_sound = table.Random(female_scream)
                    else
                        scream_sound = table.Random(table.Merge(male_scream, female_scream))
                    end

                    self.npc:EmitSound(scream_sound, 450, 100, 1, CHAN_AUTO)
                elseif state == 'defense' and self.type == 'police' then
                    self.npc:EmitSound('npc/metropolice/vo/defender.wav', 300, 100, 1, CHAN_AUTO)
                elseif state == 'arrest' and self.type == 'police' then
                    self.npc:EmitSound('npc/metropolice/vo/movetoarrestpositions.wav', 300, 100, 1, CHAN_AUTO)
                end
            end
        end

        self.old_state = self.state_data
        self.state_data = { state = state, data = (data or {}) }

        if SERVER then
            net.InvokeAll('bgn_actor_set_state_client', self:GetNPC(), 
                self.state_data.state, self.state_data.data)

            self:ResetSequence()
        end

        if IsValid(self.npc) then
            hook.Run('BGN_SetNPCState', self, 
                self.state_data.state, self.state_data.data)
        end
        
        return self.state_data
    end

    function obj:Walk()
        self:SetState('walk', {
            schedule = SCHED_FORCED_GO,
            runReset = 0
        })
    end

    function obj:Idle(idle_time)
        idle_time = idle_time or 10
        self:SetState('idle', {
            delay = CurTime() + idle_time
        })
    end

    function obj:Fear()
        self:SetState('fear', {
            delay = 0
        })
    end

    function obj:Defense()
        self:SetState('defense', {
            delay = 0
        })
    end

    function obj:HasTeam(team_value)
        if self.data.team ~= nil and team_value ~= nil then
            if istable(team_value) then
                if team_value.isBgnActor then
                    team_value = team_value:GetData().team
                end

                for _, team_1 in ipairs(self.data.team) do
                    for _, team_2 in ipairs(team_value) do
                        if team_1 == team_2 then
                            return true
                        end
                    end
                end
            elseif isstring(team_value) then
                return table.HasValue(self.data.team, team_value)
            end
        end
        return false
    end

    function obj:UpdateStateData(data)
        self.state_data.data = data
    end

    function obj:HasState(state)
        return (self:GetState() == state)
    end

    function obj:GetOldState()
        if self.old_state == nil then
            return 'none'
        end
        return self.old_state.state
    end

    function obj:GetOldStateData()
        if self.old_state == nil then
            return {}
        end
        return self.old_state.data
    end

    function obj:GetState()
        if self.state_data == nil then
            return 'none'
        end
        return self.state_data.state
    end

    function obj:GetStateData()
        if self.state_data == nil then
            return {}
        end
        return self.state_data.data
    end

    function obj:GetDistantPointInRadius(pos, radius)
        radius = radius or 500
        
        local point = nil
        local dist = 0
        local npc = self:GetNPC()
        local points = bgNPC:GetAllPointsInRadius(npc:GetPos(), radius)

        for _, value in ipairs(points) do
            if point == nil then
                point = value.pos
                dist = point:DistToSqr(pos)
            elseif value.pos:DistToSqr(pos) > dist then
                point = value.pos
                dist = point:DistToSqr(pos)
            end
        end

        return point 
    end

    function obj:GetClosestPointToPosition(pos, radius)
        radius = radius or 500
        
        local point = nil
        local dist = 0
        local npc = self:GetNPC()
        local points = bgNPC:GetAllPointsInRadius(npc:GetPos(), radius)

        for _, value in ipairs(points) do
            if point == nil then
                point = value.pos
                dist = point:DistToSqr(pos)
            elseif value.pos:DistToSqr(pos) < dist then
                point = value.pos
                dist = point:DistToSqr(pos)
            end
        end

        return point 
    end

    function obj:GetReactionForDamage()
        local probability = math.random(1, 100)
        local percent, reaction = table.Random(self.data.at_damage)

        if probability > percent then
            local last_percent = 0
            
            for _reaction, _percent in pairs(self.data.at_damage) do
                if _percent > last_percent then
                    percent = _percent
                    reaction = _reaction
                    last_percent = percent
                end
            end
        end

        reaction = reaction or 'ignore'

        return reaction
    end

    function obj:GetReactionForProtect()
        local probability = math.random(1, 100)
        local percent, reaction = table.Random(self.data.at_protect)

        if probability > percent then
            local last_percent = 0
            
            for _reaction, _percent in pairs(self.data.at_protect) do
                if _percent > last_percent then
                    percent = _percent
                    reaction = _reaction
                    last_percent = percent
                end
            end
        end

        reaction = reaction or 'ignore'

        return reaction
    end

    function obj:SetSchedule(schedule)
        if self:IsSequenceFinished() then
            self.npc:SetSchedule(schedule)
            
            self.npc_schedule = self.npc:GetCurrentSchedule()
            self.npc_state = self.npc:GetNPCState()

            self:SyncSchedule()
        end
    end

    function obj:IsValidSequence(sequence_name)
        if self.npc:LookupSequence(sequence_name) == -1 then return false end
        return true
    end

    function obj:PlayStaticSequence(sequence_name, loop, loop_time)
        if self:IsValidSequence(sequence_name) then
            if self:HasSequence(sequence_name) and not self:IsSequenceFinished() then
                return true
            end

            local hook_result = hook.Run('BGN_PreNPCStartAnimation', 
                self, sequence_name, loop, loop_time)

            if hook_result ~= nil and isbool(hook_result) and not hook_result then
                return
            end

            self.anim_is_loop = loop or false
            self.anim_name = sequence_name
            if loop_time ~= nil and loop_time ~= 0 then
                self.loop_time = RealTime() + loop_time
                self.loop_time_normal = self.loop_time - RealTime()
            else
                self.loop_time = 0
            end
            local sequence = self.npc:LookupSequence(sequence_name)
            self.anim_time = RealTime() + self.npc:SequenceDuration(sequence)
            self.anim_time_normal = self.anim_time - RealTime()
            self.is_animated = true

            self.npc_schedule = SCHED_SLEEP
            self.npc_state = NPC_STATE_SCRIPT
            
            self.npc:SetNPCState(NPC_STATE_SCRIPT)
            self.npc:SetSchedule(SCHED_SLEEP)
            self.npc:ResetSequenceInfo()
            self.npc:ResetSequence(sequence)

            self.npc_schedule = self.npc:GetCurrentSchedule()
            self.npc_state = self.npc:GetNPCState()

            hook.Run('BGN_StartedNPCAnimation', self, sequence_name, loop, loop_time)

            self:SyncAnimation()

            return true
        end

        return false
    end

    function obj:SetNextSequence(sequence_name, loop, loop_time, action)
        self.next_anim = {
            sequence_name = sequence_name,
            loop = loop,
            loop_time = loop_time,
            action = action,
        }
    end

    function obj:HasSequence(sequence_name)
        return self.anim_name == sequence_name
    end

    function obj:IsAnimationPlayed()
        return self.is_animated
    end

    function obj:IsSequenceLoopFinished()
        if self:IsLoopSequence() then
            if self.loop_time == 0 then return false end
            
            if self.loop_time_normal > 0 then
                self.loop_time_normal = self.loop_time - RealTime()
                if bgNPC.cfg.syncUpdateAnimationForClient and self.sync_animation_delay < CurTime() then
                    self:SyncAnimation()
                    self.sync_animation_delay = CurTime() + 0.5
                end
            end

            return self.loop_time < RealTime()
        end
        return true
    end

    function obj:IsLoopSequence()
        return self.anim_is_loop
    end

    function obj:IsSequenceFinished()
        if self.anim_time_normal > 0 then
            self.anim_time_normal = self.anim_time - RealTime()
            if bgNPC.cfg.syncUpdateAnimationForClient and self.sync_animation_delay < CurTime() then
                self:SyncAnimation()
                self.sync_animation_delay = CurTime() + 0.5
            end
        end

        return self.anim_time <= RealTime()
    end

    function obj:PlayNextStaticSequence()
        if self.next_anim ~= nil and self.next_anim.sequence_name ~= self.anim_name then

            self:PlayStaticSequence(self.next_anim.sequence_name,
                self.next_anim.loop, self.next_anim.loop_time)

            if self.next_anim.action ~= nil then
                self.next_anim.action(self)
            end

            self.next_anim = nil
            return true
        end

        return false
    end

    function obj:ResetSequence()
        -- self.anim_name = ''
        -- self.anim_time = 0
        -- self.anim_is_loop = false

        self.is_animated = false
        self.next_anim = nil
        
        self:SyncAnimation()
        self:ClearSchedule()
    end

    function npc:GetActor()
        return obj
    end

    npc.isActor = true

    return obj
end