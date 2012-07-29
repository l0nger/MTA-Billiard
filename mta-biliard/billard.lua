
local tables={ 	-- define table positions here
  -- x,y,z, dimension, interior
	{ 2488,-1667,13.34, 0,0},
	-- you can define as many tables, as you wish
 }

I=0
D=0
Z=13.3
local W=1.9
local H=1

local bile_oid={ 3106, 3100, 3101, 3102, 3103, 3104, 3105, 3002, 2995, 2996, 2997, 2998, 2999, 3000, 3001}


--2964

local function utworzBile(oid, x,y, z, d,i)
	local bila=createObject(oid, x,y,z)
	setElementDimension(bila, d)
	setElementInterior(bila,i)
	setElementFrozen(bila, true)
	return bila
end


local function utworzWszystkieBile(stol)
	if (tables[stol].bile) then
		for i,v in ipairs(tables[stol].bile) do
			destroyElement(v.obiekt)
		end
	end

	bile_oid=shuffle(bile_oid)
  tables[stol].bile={}
  local row=1
  local wrzedzie=0
  for i=1,15 do
  	tables[stol].bile[i]={}
----	bile[i].obiekt=utworzBile(bile_oid[i], 936.71+(row/14), 2507.05+(wrzedzie/14)-(row/28))
	tables[stol].bile[i].obiekt=utworzBile(bile_oid[i], tables[stol][1]-W*10/30+((5-row)/14), tables[stol][2]+(wrzedzie/14)-(row/28)+0.035, tables[stol][3], tables[stol][4],tables[stol][5])
	tables[stol].bile[i].movement={0,0}
	wrzedzie=wrzedzie+1
	if (wrzedzie==row) then
		row=row+1
		wrzedzie=0
	end
  end

  tables[stol].bile[16]={}
  tables[stol].bile[16].obiekt=utworzBile(3003, tables[stol][1]+W*7/30, tables[stol][2], tables[stol][3], tables[stol][4],tables[stol][5])

end

local function utworzLuzy(stol)
	tables[stol].luzy={}
	table.insert(tables[stol].luzy, createColSphere(tables[stol][1]+W/2, tables[stol][2]+H/2, tables[stol][3]-0.1,0.15))
	table.insert(tables[stol].luzy, createColSphere(tables[stol][1]-W/2, tables[stol][2]+H/2, tables[stol][3]-0.1, 0.15))
	table.insert(tables[stol].luzy, createColSphere(tables[stol][1]+W/2, tables[stol][2]-H/2, tables[stol][3]-0.1, 0.15))
	table.insert(tables[stol].luzy, createColSphere(tables[stol][1]-W/2, tables[stol][2]-H/2, tables[stol][3]-0.1, 0.15))

	table.insert(tables[stol].luzy, createColSphere(tables[stol][1]    , tables[stol][2]-H/1.8, tables[stol][3]-0.1, 0.15))
	table.insert(tables[stol].luzy, createColSphere(tables[stol][1]    , tables[stol][2]+H/1.8, tables[stol][3]-0.1, 0.15))

	for i,v in ipairs(tables[stol].luzy) do
		setElementDimension(v, tables[stol][4])
		setElementInterior(v,tables[stol][5])
		setElementData(v,"type","luza",false)
		setElementData(v, "stol_id", stol, false)
	end
end

for i,v in ipairs(getElementsByType("player")) do
	takeWeapon(v,7)
end

for i,v in ipairs(tables) do
	v.obiekt=createObject(2964, v[1], v[2], v[3]-1)
	setElementInterior(v.obiekt, v[5])
	setElementDimension(v.obiekt, v[4])
	setElementData(v.obiekt,"customAction",{label="Ułóż bile",resource="lss-billard",funkcja="menu_resetStolu",args={stol=i}})

	v.cs=createColSphere(v[1], v[2], v[3], 3)
	setElementInterior(v.cs, v[5])
	setElementDimension(v.cs, v[4])
	setElementData(v.cs, "stol_id", i, false)

--[[ this should be delayed
	for i,v in ipairs(getElementsWithinColShape(v.cs,"player")) do
		triggerClientEvent(v, "onBillardNamierzanie", resourceRoot)
		giveWeapon(v, 7, 1, true)
	end
]]--

	utworzWszystkieBile(i)
	utworzLuzy(i)
end

local function usunBile(obiekt,stol)
			for i,v in ipairs(tables[stol].bile) do
				if (v.obiekt==obiekt) then
					table.remove(tables[stol].bile, i)
					destroyElement(obiekt)
					return true
				end
			end
		return false
end

addEventHandler("onColShapeHit", resourceRoot, function(el,md)
	if (not md) then return end
	if (getElementInterior(source)~=getElementInterior(el)) then return end
	if (getElementDimension(source)~=getElementDimension(el)) then return end

	local idx=getElementData(source, "stol_id")
	if not idx then return end

	local st=getElementData(source,"type")
	if st and st=="luza" then
		if getElementType(el)~="object" then return end
		local model=getElementModel(el)
		if ballNames[model] and usunBile(el, idx) then
			-- co z nia robimy? po prostu usuwamy!
			triggerEvent("broadcastCaptionedEvent", source, ballNames[model].." hits the pot.", 5, 5, true)
		end
		return
	end

	if (getElementType(el)~="player") then return end

	triggerClientEvent(el, "onBillardNamierzanie", resourceRoot, tables[idx][1], tables[idx][2], tables[idx][3], W, H)
	giveWeapon(el, 7, 1, true)
end)

addEventHandler("onColShapeLeave", resourceRoot, function(el,md)
	if (not md) then return end
	if (getElementType(el)~="player") then return end
	triggerClientEvent(el, "onBillardNamierzanie", resourceRoot, nil)
	takeWeapon(el,7)
end)

local function przyKtorymStole(gracz)
	for i,v in ipairs(tables) do
		if isElementWithinColShape(gracz,v.cs) then return i end
	end                                                       
	return nil
end


-- triggerServerEvent("doPoolShot", resourceRoot, localPlayer, x,y,x2,y2)
addEvent("doPoolShot", true)
addEventHandler("doPoolShot", resourceRoot, function(plr, x,y, x2,y2, bila)
--	outputDebugString("PoolShot")
	if not bila then return end
	if getPedWeapon(plr)~=7 then return end	-- nie ma kija w dloni

	local stol=przyKtorymStole(plr)
	if not stol then return end

	-- odnajdujemy tą bilę
	for i,v in ipairs(tables[stol].bile) do
			if v.obiekt==bila then
				local bx,by=getElementPosition(v.obiekt)
				local force=(getDistanceBetweenPoints2D(x,y,bx,by)*2)
				
				v.movement={(bx-x)/force,(by-y)/force}
--				outputDebugString(tostring((x-x2)/))
				billardProcess(stol)
				if (not tables[stol].timer) then
					tables[stol].timer=setTimer(billardProcess, 75, 0, stol)
				end
				return
			end
	end
end)


function billardProcess(stol)
	if (getTickCount()-(tables[stol].lastTick or 0)<25) then return end
	tables[stol].lastTick=getTickCount()

	local totalMovement=0

	for i,v in ipairs(tables[stol].bile) do
		if v.movement then -- and (v.movement[1]~=0 or v.movement[2]~=0) then
			-- przesuniecie bili
			local x,y,z=getElementPosition(v.obiekt)
			local nx=x+(v.movement[1]/10)
			local ny=y+(v.movement[2]/10)
--			local rotx,roty,rotz=getElementRotation(v.obiekt)
--			setElementRotation(v.obiekt, rotx-v.movement[1]*60, roty, rotz)

			if (nx<tables[stol][1]-W/2 or nx>tables[stol][1]+W/2)  then

				v.movement[1]=-v.movement[1]
--				v.movement[2]=-v.movement[2]
--				setElementPosition(v.obiekt,x,y,z)
			elseif (ny<tables[stol][2]-H/2 or ny>tables[stol][2]+H/2)  then

--				v.movement[1]=-v.movement[1]
				v.movement[2]=-v.movement[2]
--				setElementPosition(v.obiekt,x,y,z)
			else
--				moveObject(v.obiekt, 75, nx,ny,z)
				setElementPosition(v.obiekt,nx,ny,z)
				v.movement[1]=v.movement[1]/1.02
				v.movement[2]=v.movement[2]/1.02
				if (math.abs(v.movement[1])<0.05) then v.movement[1]=0 end
				if (math.abs(v.movement[2])<0.05) then v.movement[2]=0 end
			end
			-- kolizja z innymi bilami
			local force=math.abs(v.movement[1])+math.abs(v.movement[2])+0.001
			local kolizji=0
			for i2,v2 in ipairs(tables[stol].bile) do
				if (i2~=i and v2.movement and v.obiekt and isElement(v.obiekt)) then
					local x,y=getElementPosition(v.obiekt)
					local x2,y2=getElementPosition(v2.obiekt)
					if (getDistanceBetweenPoints2D(x,y,x2,y2)<0.08) then
						kolizji=kolizji+1
						local rx=x-x2
						local ry=y-y2
						v2.movement[1]=v2.movement[1]-(force*10*rx)
						v2.movement[2]=v2.movement[2]-(force*10*ry)
					end
				end
			end
			if (kolizji>0) then
--				v.movement[1]=v.movement[1]/(1+math.sqrt(kolizji)
--				v.movement[2]=v.movement[2]/(1+math.sqrt(kolizji)
				v.movement[1]=v.movement[1]/(1+kolizji)
				v.movement[2]=v.movement[2]/(1+kolizji)


			end
			totalMovement=totalMovement+math.abs(v.movement[1])+math.abs(v.movement[2])
		end
		
--		if (v.movement and type(v.movement)=="table") then

--		end
	end
	-- sprawdzamy czy bile nie sa w luzach
--	for i,v in ipairs(tables[stol].luzy) do
--		outputDebugString("luza " ..i .. "-" .. #getElementsWithinColShape(v))
--	end

	if totalMovement==0 and tables[stol].timer and isTimer(tables[stol].timer) then
		killTimer(tables[stol].timer)
		tables[stol].timer=nil
	end
end


-- triggerServerEvent("doResetTable", resourceRoot, argumenty.stol)
addEvent("doResetTable", true)
addEventHandler("doResetTable", resourceRoot, function(plr,stol)
	if not tables[stol] then return end
--[[
	if (tables[stol].bile) then
		if (#tables[stol].bile>1) then
			outputChatBox("(( All balls must be in pots. ))", plr)
			return
		end
	end
]]--
	utworzWszystkieBile(stol)
	triggerEvent("broadcastCaptionedEvent", plr, getPlayerName(plr) .. " repositions balls on table.", 5, 5, true)
end)                                                                   