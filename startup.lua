local heading = 0
local dir
local x, y, z = 0, 0, 0
local tempX, tempY, tempZ = 0, 0, 0
local gotoSave = {}
local excavateSave = {}
local dia = 3
local mineLocX = 0
local mineLocZ = 0

local xMine = 0
local yMine = 0
local zMine = 0
local dirMine = 0
local returnBase = false
local startedMine = false
local flop = false

local gotoFlag = false
local quarryList = {
    {0, 0},
    {0, 5},
    {0, 10},
    {0, 15},
    {0, 20},
    {5, 0},
    {5, 5},
    {5, 10},
    {5, 15},
    {5, 20},
    {10, 0},
    {10, 5},
    {10, 10},
    {10, 15},
    {10, 20},
    {15, 0},
    {15, 5},
    {15, 10},
    {15, 15},
    {15, 20},
    {20, 0},
    {20, 5},
    {20, 10},
    {20, 15},
    {20, 20}
}

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

local function saveMine()
    print(startedMine)
    excavateSave = {
    xMine,
    yMine,
    zMine,
    startedMine
    }
end

local function saveData()
    saveMine()

    local saveTable = {
        x,
        y,
        z,
        heading,
        gotoSave,
        excavateSave
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
        gotoFlag = gotoSave[4]
        excavateSave = saveTable[6]
        xMine, yMine, zMine = excavateSave[1], excavateSave[2], excavateSave[3]
        startedMine = excavateSave[4]
        print(xMine, yMine, zMine, startedMine)
    end
end

local function printData()
    print(getDir())
    print("x" .. x)
    print("y" .. y)
    print("z" .. z)
end

local function moveForward()
    local loop = true
    local bool, string = turtle.forward()
    if(bool == false) then
        while loop do    
            local bool2, table2 = turtle.inspect()
            if(table["name"] ~= "computercraft:turtle_expanded") then
                bool, string = turtle.forward()
                turtle.attack()
                turtle.dig()
                sleep(1)
                if(bool == false) then loop = true else loop = false end
            end
        end
    end
    return true
end

local function moveUp()
    local loop = true
    local bool, string = turtle.up()
    if(bool == false) then
        while loop do    
            bool, string = turtle.up()
            turtle.attackUp()
            turtle.digUp()
            sleep(1)
            if(bool == false) then loop = true else loop = false end
        end
    end
    return true
end

local function moveDown()
    local loop = true
    local bool, string = turtle.down()
    if(bool == false) then
        while loop do    
            bool, string = turtle.down()
            turtle.attackDown()
            turtle.digDown()
            sleep(1)
            if(bool == false) then loop = true else loop = false end
        end
    end
    return true
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
    if(moveForward()) then
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
    if(moveUp()) then
        y = y + 1
        saveData()
    end
end

local function down()
    if(moveDown()) then
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

    gotoFlag = true

    gotoSave = {
        xGo,
        yGo,
        zGo,
        gotoFlag
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

    gotoFlag = false

end

local function checkFull()
    local count = 0
    for i = 1, 16 do
        if(turtle.getItemDetail(i) ~= nil) then
            count = count + 1
        end
    end
    if(count == 16) then
        return true
    else
        return false
    end
end

local function excavate(mineDia)
    print(xMine, yMine, zMine)
    local dia = mineDia
    local finished = false
    print(startedMine)
    if(startedMine == false) then
        tempX, tempY, tempZ = x, y, z

        for i = 1, 2 do
            down()
            yMine = yMine - 1
        end
        turtle.digDown()
    end
    while true do
        --if(zMine ~= mineDia) then
        --    zMine = mineDia
        --end
        startedMine = true
        if(finished or returnBase) then
            break
        end
        while true do
            if(zMine == 0) then
                zMine = mineDia - 1
            end
            print (zMine)
            for i = 1, zMine do
                print("1")
                if(checkFull()) then
                    returnBase = true
                    tempX, tempY, tempZ = x, y, z
                    dirMine = heading
                    break
                end
                turtle.dig()
                forward()
                turtle.digUp()
                turtle.digDown()
                zMine = zMine - 1
            end
            if(checkFull()) then
                returnBase = true 
                break
            end
            if(xMine == mineDia - 1) then
                xMine = 0
                break
            end
            if(flop == false) then
                right()
            else
                left()
            end
            turtle.dig()
            forward()
            xMine = xMine + 1
            turtle.digUp()
            turtle.digDown()
            if(flop == false) then
                right()
            else
                left()
            end
            flop = not flop
        end
        if(checkFull()) then
            returnBase = true 
            break
        end
        if(flop == true) then
            right()
        else
            left()
        end
        flop = not flop
        for i = 1, 3 do
            local boolIns, tableIns = turtle.inspectDown()
            print(tableIns["name"])
            if(tableIns["name"] == "minecraft:bedrock") then
                for p = 1, i do
                    up()
                    yMine = yMine + 1
                end
                finished = true
                break
            else
                down()
                yMine = yMine - 1
                turtle.digDown()
            end
        end
    end
    if(finished) then
        xMine, yMine, zMine = 0, 0, 0
        startedMine = false
    end
    --goto(tempX, tempY, tempZ)
end

loadData()
if(gotoFlag) then
    
end
if(startedMine) then
    excavate(5)
end
if not fs.exists('/data/started') then
    local f = fs.open('/data/started', 'w')
    f.write('1')
    f.close()
end


if (gotoFlag == true) then
    goto(gotoSave[1], gotoSave[2], gotoSave[3])
else
    for i, v in ipairs(quarryList) do
        while returnBase do
            goto(0, 0, 0)
            faceDir(2)
            for i = 1, 16 do
                turtle.select(i)
                turtle.drop(64)
            end
            turtle.select(1)
            print(tempX, tempY, tempZ)
            goto(tempX, y, tempZ)
            goto(tempX, tempY, tempZ)
            faceDir(dirMine)
            returnBase = false
            excavate(5)
            if(startedMine == false) then
                break
            end
        end
        goto(v[1], 0, v[2])
        faceDir(0)
        excavate(5)
    end
    goto(0, 0, 0)
end
faceDir(0)
fs.delete('/data/started')
