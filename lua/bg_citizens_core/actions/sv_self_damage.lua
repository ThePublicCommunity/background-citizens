hook.Add('EntityTakeDamage', 'BGN_ActorTakeDamageEvent', function(target, dmginfo)
    if not target:IsPlayer() and not target:IsNPC() then return end

    local attacker = dmginfo:GetAttacker()
    if not attacker:IsPlayer() and not attacker:IsNPC() then return end
    if attacker.bgNPCIgnore then return end

    local ActorTarget = bgNPC:GetActor(target)
    local ActorAttacker = bgNPC:GetActor(attacker)
    local reaction

    if target:IsNPC() then
        if ActorTarget ~= nil then
            if attacker:IsPlayer() then
                if ActorTarget:HasTeam('player') then
                    return true
                end
            elseif attacker:IsNPC() and ActorAttacker ~= nil then
                if ActorTarget:HasTeam(ActorAttacker) then
                    ActorTarget:RemoveTarget(attacker)
                    ActorAttacker:RemoveTarget(target)
                    return true
                end
            end

            reaction = ActorTarget:GetReactionForDamage()
            ActorTarget:SetReaction(reaction)

            local hook_result = hook.Run('BGN_PreReactionTakeDamage', attacker, target, dmginfo, reaction)
            if hook_result ~= nil then
                if isbool(hook_result) and not hook_result then
                    return hook_result
                end

                if isstring(hook_result) then
                    reaction = hook_result
                end
            end
            
            ActorTarget:AddTarget(attacker)

            local state = ActorTarget:GetState()
            if state == 'idle' or state == 'walk' or state == 'arrest' then
                ActorTarget:SetState(ActorTarget:GetLastReaction())
            end
        end

        hook.Run('BGN_PostReactionTakeDamage', attacker, target, dmginfo, reaction)
    elseif target:IsPlayer() then
        if ActorAttacker ~= nil and ActorAttacker:HasTeam('player') then
            return true
        end

        local hook_result = hook.Run('BGN_PreReactionTakeDamage', attacker, target, dmginfo)
        if hook_result ~= nil then
            if isbool(hook_result) then
                return hook_result
            end
        end

        hook.Run('BGN_PostReactionTakeDamage', attacker, target, dmginfo)
    end
end)