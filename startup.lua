local heading = 0
local dir
local x, y, z = 0, 0, 0
local gotoSave

local function getDir()
    if heading == 0 then
        dir = "North"
    end
    if heading == 1 then
        dir = "East"
    end    
    if heading == 2 then
        dir = "South"
    end
    if heading == 3 then
        dir = "West"
    end
    return dir
end

local function saveData()
    local saveTable = {
        x,
        y,
        z,
        heading,
        gotoSave
    }

    if not fs.exists('/data') then
        fs.makeDir('/data')
    end

    local f = fs.open('/data/save', 'w')
    f.write(textutils.serialize(saveTable))
    f.close()
end

local function loadData()
    local saveTable
    if fs.exists('/data/started') then
        if fs.exists('/data/save') then
            local f = fs.open('/data/save', 'r')
            saveTable = textutils.unserialize(f.readAll())
            f.close()
        end

        x = saveTable[1]
        y = saveTable[2]
        z = saveTable[3]
        heading = saveTable[4]
        gotoSave = saveTable[5]
    end
end

local function printData()
    print(getDir())
    print("x" .. x)
    print("y" .. y)
    print("z" .. z)
end

local function left()
    --sleep(2)
    heading = heading - 1    
    if heading < 0 then
        heading = heading + 4
    end
    turtle.turnLeft()
    saveData()
end

local function right()
    --sleep(2)
    heading = heading + 1
    if heading > 3 then
        heading = heading - 4
    end
    turtle.turnRight()
    saveData()
end

local function forward()
    --sleep(2)
    if(turtle.forward()) then
        if heading == 0 then
            z = z + 1
        end

        if heading == 1 then
            x = x + 1
        end

        if heading == 2 then
            z = z - 1
        end

        if heading == 3 then
            x = x - 1
        end
        saveData()
    end
end

local function back()
    --sleep(2)
    if(turtle.back()) then
        if heading == 0 then
            z = z - 1
        end

        if heading == 1 then
            x = x - 1
        end

        if heading == 2 then
            z = z + 1
        end

        if heading == 3 then
            x = x + 1
        end
        saveData()
    end
end

local function up()
    if(turtle.up()) then
        y = y + 1
        saveData()
    end
end

local function down()
    if(turtle.down()) then
        y = y - 1
        saveData()
    end
end

local function dirRound(dir)
    local tempDir = dir
    if dir < 0 then
        tempDir = dir + 4
    end
    if dir > 3 then
        tempDir = dir - 4
    end
    return tempDir
end

local function faceDir(dir)
    if(dir == heading) then return end

    if(dirRound(heading + 1) == dir or dirRound(heading - 1) == dir) then
        if(dirRound(heading + 1) == dir) then
            right()
            return
        end

        if(dirRound(heading - 1) == dir) then
            left()
            return
        end
    else
        right()
        right()
        return
    end
end

local function goto(xGo, yGo, zGo)
    local dirGo
    gotoSave = {
        xGo,
        yGo,
        zGo
    }

    if(yGo ~= y) then
        if(yGo > y) then
            while true do
                if(yGo == y) then break end
                up()
            end
        end
        if(yGo < y) then
            while true do
                if(yGo == y) then break end
                down()
            end
        end
    end

    if(zGo ~= z) then
        if(zGo > z) then
            faceDir(0)
            while true do
                if(zGo == z) then break end
                forward()
            end
        end

        if(zGo < z) then
            faceDir(2)
            while true do
                if(zGo == z) then break end
                forward()
            end
        end
    end

    if(xGo ~= x) then
        if(xGo > x) then
            faceDir(1)
            while true do
                if(xGo == x) then break end
                forward()
            end
        end

        if(xGo < x) then
            faceDir(3)
            while true do
                if(xGo == x) then break end
                forward()
            end
        end
    end
end

loadData()
if not fs.exists('/data/started') then
    local f = fs.open('/data/started', 'w')
    f.write('1')
    f.close()
end
goto(10, 1, 10)