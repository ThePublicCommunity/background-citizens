function bgNPC:GetActor(npc)
	if IsValid(npc) and npc.isBgnActor then
		return npc:GetActor()
	end
	return nil
end

function bgNPC:GetAllPointsInRadius(center, radius, linkType)
	local radius_positions = {}
	local radius = radius or 500
	radius = radius ^ 2

	for _, v in ipairs(BGN_NODE:GetMap()) do
		if v.position:DistToSqr(center) <= radius then
			if linkType then
				if not v.links[linkType] or #v.links[linkType] == 0 then
					goto skip
				end
			end
			
			table.insert(radius_positions, v)
		end

		::skip::
	end

	return radius_positions
end

function bgNPC:GetAllIndexPointsInRadius(center, radius, linkType)
	local radius_positions = {}
	local radius = radius or 500
	radius = radius ^ 2

	for index, v in ipairs(BGN_NODE:GetMap()) do
		if linkType then
			if not v.links[linkType] or #v.links[linkType] == 0 then
				goto skip
			end
		end
		
		if v.position:DistToSqr(center) <= radius then
			table.insert(radius_positions, index)
		end

		::skip::
	end

	return radius_positions
end

function bgNPC:GetClosestPointInRadius(center, radius, linkType)
	local point = nil
	local dist = nil
	local radius = radius or 500

	for _, v in ipairs(self:GetAllPointsInRadius(center, radius)) do
		if linkType then
			if not v.links[linkType] or #v.links[linkType] == 0 then
				goto skip
			end
		end

		if point == nil then
			point = v
			dist = center:DistToSqr(v.position)
      else
         local checkDist = center:DistToSqr(v.position)
         if checkDist < dist then
            point = v
            dist = checkDist
         end
      end

		::skip::
	end

	return point
end

function bgNPC:GetDistantPointInRadius(center, radius, linkType)
	local point = nil
	local dist = nil
	local radius = radius or 500

	for _, v in ipairs(self:GetAllPointsInRadius(center, radius)) do
		if linkType then
			if not v.links[linkType] or #v.links[linkType] == 0 then
				goto skip
			end
		end

		if point == nil then
			point = v
			dist = center:DistToSqr(v.position)
      else
         local checkDist = center:DistToSqr(v.position)
         if checkDist > dist then
            point = v
            dist = checkDist
         end
      end

		::skip::
	end

	return point
end

function bgNPC:GetClosestPointInChunk(center, linkType)
	local point = nil
	local dist = nil
	local nodes = BGN_NODE:GetChunkNodes(center)

	for _, v in ipairs(nodes) do
		if linkType then
			if not v.links[linkType] or #v.links[linkType] == 0 then
				goto skip
			end
		end

		if point == nil then
			point = v
			dist = center:DistToSqr(v.position)
      else
         local checkDist = center:DistToSqr(v.position)
         if checkDist < dist then
            point = v
            dist = checkDist
         end
      end

		::skip::
	end

	return point
end

function bgNPC:GetDistantPointInChunk(center, linkType)
	local point = nil
	local dist = nil
	local nodes = BGN_NODE:GetChunkNodes(center)

	for _, v in ipairs(nodes) do
		if linkType then
			if not v.links[linkType] or #v.links[linkType] == 0 then
				goto skip
			end
		end

		if point == nil then
			point = v
			dist = center:DistToSqr(v.position)
      else
         local checkDist = center:DistToSqr(v.position)
         if checkDist > dist then
            point = v
            dist = checkDist
         end
      end

		::skip::
	end

	return point
end

function bgNPC:GetClosestPointToPointInChunk(center, pos, linkType)
	local point = nil
	local dist = nil
	local nodes = BGN_NODE:GetChunkNodes(center)

	for _, v in ipairs(nodes) do
		if linkType then
			if not v.links[linkType] or #v.links[linkType] == 0 then
				goto skip
			end
		end

		if point == nil then
			point = v
			dist = pos:DistToSqr(v.position)
      else
         local checkDist = pos:DistToSqr(v.position)
         if checkDist < dist then
            point = v
            dist = checkDist
         end
      end

		::skip::
	end

	return point
end

function bgNPC:GetDistantPointToPointInChunk(center, pos, linkType)
	local point = nil
	local dist = nil
	local nodes = BGN_NODE:GetChunkNodes(center)

	for _, v in ipairs(nodes) do
		if linkType then
			if not v.links[linkType] or #v.links[linkType] == 0 then
				goto skip
			end
		end

		if point == nil then
			point = v
			dist = pos:DistToSqr(v.position)
      else
         local checkDist = pos:DistToSqr(v.position)
         if checkDist > dist then
            point = v
            dist = checkDist
         end
      end

		::skip::
	end

	return point
end

function bgNPC:GetAll()
	return self.actors
end

function bgNPC:GetAllByType(type)
	return self.factors[type] or {}
end

function bgNPC:GetAllByTeam(team_data)
	local actors = {}

	for _, actor in ipairs(self.actors) do
		if actor:HasTeam(team_data) then
			table.insert(actors, actor)
		end
	end

	return actors
end

function bgNPC:GetAllByState(state_name)
	local actors = {}

	for _, actor in ipairs(self.actors) do
		if actor:HasState(state_name) then
			table.insert(actors, actor)
		end
	end

	return actors
end

function bgNPC:GetAllNPCs()
	return self.npcs
end

function bgNPC:GetAllNPCsByType(type)
	return self.fnpcs[type] or {}
end

function bgNPC:GetNear(center)
	local near_actor = nil
	local dist = nil
	
	for _, actor in ipairs(self:GetAll()) do
		local npc = actor:GetNPC()
		if IsValid(npc) then
			if dist == nil then
				dist = npc:GetPos():DistToSqr(center)
				near_actor = actor
			else
				local new_dist = npc:GetPos():DistToSqr(center)
				if new_dist < dist then
					dist = new_dist
					near_actor = actor
				end
			end
		end
	end

	return near_actor
end


function bgNPC:GetNearByType(center, type)
	local near_actor = nil
	local dist = nil
	
	for _, actor in ipairs(self:GetAll()) do
		local npc = actor:GetNPC()
		if actor:GetType() == type and IsValid(npc) then
			if dist == nil then
				dist = npc:GetPos():DistToSqr(center)
				near_actor = actor
			else
				local new_dist = npc:GetPos():DistToSqr(center)
				if new_dist < dist then
					dist = new_dist
					near_actor = actor
				end
			end
		end
	end

	return near_actor
end

function bgNPC:GetAllByRadius(center, radius)
	local npcs = {}
	radius = radius ^ 2
	
	for _, actor in ipairs(self:GetAll()) do
		local npc = actor:GetNPC()
		if IsValid(npc) and npc:GetPos():DistToSqr(center) <= radius then
			table.insert(npcs, actor)
		end
	end

	return npcs
end

function bgNPC:HasNPC(npc)
	return table.HasValue(bgNPC:GetAllNPCs(), npc)
end

function bgNPC:IsTeamOnce(npc1, npc2)
	local actor1 = self:GetActor(npc1)
	local actor2 = self:GetActor(npc2)
	if actor1 ~= nil and actor2 ~= nil then
		local data1 = actor1:GetData()
		local data2 = actor2:GetData()

		if data1.team ~= nil and data2.team ~= nil then
			for _, team_1 in ipairs(data1.team) do
				for _, team_2 in ipairs(data2.team) do
					if team_1 == team_2 then
						return true
					end
				end
			end
		end
	end

	return false
end