-------------------------------------------------------------------------------------
-- Wojbies API 5.0 - Bigfont - functions to write bigger font using drawing sybols --
-------------------------------------------------------------------------------------
--   Copyright (c) 2015-2022 Wojbie (wojbie@wojbie.net)
--   Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
--   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
--   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
--   4. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
--   5. The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
--   NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. YOU ACKNOWLEDGE THAT THIS SOFTWARE IS NOT DESIGNED, LICENSED OR INTENDED FOR USE IN THE DESIGN, CONSTRUCTION, OPERATION OR MAINTENANCE OF ANY NUCLEAR FACILITY.

--Switch to true to replace generic currency sign "\164" with krist symbol.
local krist = true

--### Initializing
local b = shell and {} or (_ENV or getfenv())
b.versionName = "Bigfont By Wojbie"
b.versionNum = 5.003 --2021-07-21
b.doc = {}

local expect, field if require then expect, field = require "cc.expect".expect, require "cc.expect".field else local ok, did = pcall(dofile,"rom/modules/main/cc/expect.lua") if ok then field, expect = did.field, did.expect else field, expect = function() end, function() end end end

--### Font database
local rawFont = {{"\32\32\32\137\156\148\158\159\148\135\135\144\159\139\32\136\157\32\159\139\32\32\143\32\32\143\32\32\32\32\32\32\32\32\147\148\150\131\148\32\32\32\151\140\148\151\140\147", "\32\32\32\149\132\149\136\156\149\144\32\133\139\159\129\143\159\133\143\159\133\138\32\133\138\32\133\32\32\32\32\32\32\150\150\129\137\156\129\32\32\32\133\131\129\133\131\132", "\32\32\32\130\131\32\130\131\32\32\129\32\32\32\32\130\131\32\130\131\32\32\32\32\143\143\143\32\32\32\32\32\32\130\129\32\130\135\32\32\32\32\131\32\32\131\32\131", "\139\144\32\32\143\148\135\130\144\149\32\149\150\151\149\158\140\129\32\32\32\135\130\144\135\130\144\32\149\32\32\139\32\159\148\32\32\32\32\159\32\144\32\148\32\147\131\132", "\159\135\129\131\143\149\143\138\144\138\32\133\130\149\149\137\155\149\159\143\144\147\130\132\32\149\32\147\130\132\131\159\129\139\151\129\148\32\32\139\131\135\133\32\144\130\151\32", "\32\32\32\32\32\32\130\135\32\130\32\129\32\129\129\131\131\32\130\131\129\140\141\132\32\129\32\32\129\32\32\32\32\32\32\32\131\131\129\32\32\32\32\32\32\32\32\32", "\32\32\32\32\149\32\159\154\133\133\133\144\152\141\132\133\151\129\136\153\32\32\154\32\159\134\129\130\137\144\159\32\144\32\148\32\32\32\32\32\32\32\32\32\32\32\151\129", "\32\32\32\32\133\32\32\32\32\145\145\132\141\140\132\151\129\144\150\146\129\32\32\32\138\144\32\32\159\133\136\131\132\131\151\129\32\144\32\131\131\129\32\144\32\151\129\32", "\32\32\32\32\129\32\32\32\32\130\130\32\32\129\32\129\32\129\130\129\129\32\32\32\32\130\129\130\129\32\32\32\32\32\32\32\32\133\32\32\32\32\32\129\32\129\32\32", "\150\156\148\136\149\32\134\131\148\134\131\148\159\134\149\136\140\129\152\131\32\135\131\149\150\131\148\150\131\148\32\148\32\32\148\32\32\152\129\143\143\144\130\155\32\134\131\148", "\157\129\149\32\149\32\152\131\144\144\131\148\141\140\149\144\32\149\151\131\148\32\150\32\150\131\148\130\156\133\32\144\32\32\144\32\130\155\32\143\143\144\32\152\129\32\134\32", "\130\131\32\131\131\129\131\131\129\130\131\32\32\32\129\130\131\32\130\131\32\32\129\32\130\131\32\130\129\32\32\129\32\32\133\32\32\32\129\32\32\32\130\32\32\32\129\32", "\150\140\150\137\140\148\136\140\132\150\131\132\151\131\148\136\147\129\136\147\129\150\156\145\138\143\149\130\151\32\32\32\149\138\152\129\149\32\32\157\152\149\157\144\149\150\131\148", "\149\143\142\149\32\149\149\32\149\149\32\144\149\32\149\149\32\32\149\32\32\149\32\149\149\32\149\32\149\32\144\32\149\149\130\148\149\32\32\149\32\149\149\130\149\149\32\149", "\130\131\129\129\32\129\131\131\32\130\131\32\131\131\32\131\131\129\129\32\32\130\131\32\129\32\129\130\131\32\130\131\32\129\32\129\131\131\129\129\32\129\129\32\129\130\131\32", "\136\140\132\150\131\148\136\140\132\153\140\129\131\151\129\149\32\149\149\32\149\149\32\149\137\152\129\137\152\129\131\156\133\149\131\32\150\32\32\130\148\32\152\137\144\32\32\32", "\149\32\32\149\159\133\149\32\149\144\32\149\32\149\32\149\32\149\150\151\129\138\155\149\150\130\148\32\149\32\152\129\32\149\32\32\32\150\32\32\149\32\32\32\32\32\32\32", "\129\32\32\130\129\129\129\32\129\130\131\32\32\129\32\130\131\32\32\129\32\129\32\129\129\32\129\32\129\32\131\131\129\130\131\32\32\32\129\130\131\32\32\32\32\140\140\132", "\32\154\32\159\143\32\149\143\32\159\143\32\159\144\149\159\143\32\159\137\145\159\143\144\149\143\32\32\145\32\32\32\145\149\32\144\32\149\32\143\159\32\143\143\32\159\143\32", "\32\32\32\152\140\149\151\32\149\149\32\145\149\130\149\157\140\133\32\149\32\154\143\149\151\32\149\32\149\32\144\32\149\149\153\32\32\149\32\149\133\149\149\32\149\149\32\149", "\32\32\32\130\131\129\131\131\32\130\131\32\130\131\129\130\131\129\32\129\32\140\140\129\129\32\129\32\129\32\137\140\129\130\32\129\32\130\32\129\32\129\129\32\129\130\131\32", "\144\143\32\159\144\144\144\143\32\159\143\144\159\138\32\144\32\144\144\32\144\144\32\144\144\32\144\144\32\144\143\143\144\32\150\129\32\149\32\130\150\32\134\137\134\134\131\148", "\136\143\133\154\141\149\151\32\129\137\140\144\32\149\32\149\32\149\154\159\133\149\148\149\157\153\32\154\143\149\159\134\32\130\148\32\32\149\32\32\151\129\32\32\32\32\134\32", "\133\32\32\32\32\133\129\32\32\131\131\32\32\130\32\130\131\129\32\129\32\130\131\129\129\32\129\140\140\129\131\131\129\32\130\129\32\129\32\130\129\32\32\32\32\32\129\32", "\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32", "\32\32\32\32\32\32\32\32\32\32\32\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\32\32\32\32\32\32\32\32\32\32\32", "\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32", "\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32", "\32\32\32\32\32\32\32\32\32\32\32\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\32\32\32\32\32\32\32\32\32\32\32", "\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32", "\32\32\32\32\145\32\159\139\32\151\131\132\155\143\132\134\135\145\32\149\32\158\140\129\130\130\32\152\147\155\157\134\32\32\144\144\32\32\32\32\32\32\152\131\155\131\131\129", "\32\32\32\32\149\32\149\32\145\148\131\32\149\32\149\140\157\132\32\148\32\137\155\149\32\32\32\149\154\149\137\142\32\153\153\32\131\131\149\131\131\129\149\135\145\32\32\32", "\32\32\32\32\129\32\130\135\32\131\131\129\134\131\132\32\129\32\32\129\32\131\131\32\32\32\32\130\131\129\32\32\32\32\129\129\32\32\32\32\32\32\130\131\129\32\32\32", "\150\150\32\32\148\32\134\32\32\132\32\32\134\32\32\144\32\144\150\151\149\32\32\32\32\32\32\145\32\32\152\140\144\144\144\32\133\151\129\133\151\129\132\151\129\32\145\32", "\130\129\32\131\151\129\141\32\32\142\32\32\32\32\32\149\32\149\130\149\149\32\143\32\32\32\32\142\132\32\154\143\133\157\153\132\151\150\148\151\158\132\151\150\148\144\130\148", "\32\32\32\140\140\132\32\32\32\32\32\32\32\32\32\151\131\32\32\129\129\32\32\32\32\134\32\32\32\32\32\32\32\129\129\32\129\32\129\129\130\129\129\32\129\130\131\32", "\156\143\32\159\141\129\153\140\132\153\137\32\157\141\32\159\142\32\150\151\129\150\131\132\140\143\144\143\141\145\137\140\148\141\141\144\157\142\32\159\140\32\151\134\32\157\141\32", "\157\140\149\157\140\149\157\140\149\157\140\149\157\140\149\157\140\149\151\151\32\154\143\132\157\140\32\157\140\32\157\140\32\157\140\32\32\149\32\32\149\32\32\149\32\32\149\32", "\129\32\129\129\32\129\129\32\129\129\32\129\129\32\129\129\32\129\129\131\129\32\134\32\131\131\129\131\131\129\131\131\129\131\131\129\130\131\32\130\131\32\130\131\32\130\131\32", "\151\131\148\152\137\145\155\140\144\152\142\145\153\140\132\153\137\32\154\142\144\155\159\132\150\156\148\147\32\144\144\130\145\136\137\32\146\130\144\144\130\145\130\136\32\151\140\132", "\151\32\149\151\155\149\149\32\149\149\32\149\149\32\149\149\32\149\149\32\149\152\137\144\157\129\149\149\32\149\149\32\149\149\32\149\149\32\149\130\150\32\32\157\129\149\32\149", "\131\131\32\129\32\129\130\131\32\130\131\32\130\131\32\130\131\32\130\131\32\32\32\32\130\131\32\130\131\32\130\131\32\130\131\32\130\131\32\32\129\32\130\131\32\133\131\32", "\156\143\32\159\141\129\153\140\132\153\137\32\157\141\32\159\142\32\159\159\144\152\140\144\156\143\32\159\141\129\153\140\132\157\141\32\130\145\32\32\147\32\136\153\32\130\146\32", "\152\140\149\152\140\149\152\140\149\152\140\149\152\140\149\152\140\149\149\157\134\154\143\132\157\140\133\157\140\133\157\140\133\157\140\133\32\149\32\32\149\32\32\149\32\32\149\32", "\130\131\129\130\131\129\130\131\129\130\131\129\130\131\129\130\131\129\130\130\131\32\134\32\130\131\129\130\131\129\130\131\129\130\131\129\32\129\32\32\129\32\32\129\32\32\129\32", "\159\134\144\137\137\32\156\143\32\159\141\129\153\140\132\153\137\32\157\141\32\32\132\32\159\143\32\147\32\144\144\130\145\136\137\32\146\130\144\144\130\145\130\138\32\146\130\144", "\149\32\149\149\32\149\149\32\149\149\32\149\149\32\149\149\32\149\149\32\149\131\147\129\138\134\149\149\32\149\149\32\149\149\32\149\149\32\149\154\143\149\32\157\129\154\143\149", "\130\131\32\129\32\129\130\131\32\130\131\32\130\131\32\130\131\32\130\131\32\32\32\32\130\131\32\130\131\129\130\131\129\130\131\129\130\131\129\140\140\129\130\131\32\140\140\129" }, {[[000110000110110000110010101000000010000000100101]], [[000000110110000000000010101000000010000000100101]], [[000000000000000000000000000000000000000000000000]], [[100010110100000010000110110000010100000100000110]], [[000000110000000010110110000110000000000000110000]], [[000000000000000000000000000000000000000000000000]], [[000000110110000010000000100000100000000000000010]], [[000000000110110100010000000010000000000000000100]], [[000000000000000000000000000000000000000000000000]], [[010000000000100110000000000000000000000110010000]], [[000000000000000000000000000010000000010110000000]], [[000000000000000000000000000000000000000000000000]], [[011110110000000100100010110000000100000000000000]], [[000000000000000000000000000000000000000000000000]], [[000000000000000000000000000000000000000000000000]], [[110000110110000000000000000000010100100010000000]], [[000010000000000000110110000000000100010010000000]], [[000000000000000000000000000000000000000000000000]], [[010110010110100110110110010000000100000110110110]], [[000000000000000000000110000000000110000000000000]], [[000000000000000000000000000000000000000000000000]], [[010100010110110000000000000000110000000010000000]], [[110110000000000000110000110110100000000010000000]], [[000000000000000000000000000000000000000000000000]], [[000100011111000100011111000100011111000100011111]], [[000000000000100100100100011011011011111111111111]], [[000000000000000000000000000000000000000000000000]], [[000100011111000100011111000100011111000100011111]], [[000000000000100100100100011011011011111111111111]], [[100100100100100100100100100100100100100100100100]], [[000000110100110110000010000011110000000000011000]], [[000000000100000000000010000011000110000000001000]], [[000000000000000000000000000000000000000000000000]], [[010000100100000000000000000100000000010010110000]], [[000000000000000000000000000000110110110110110000]], [[000000000000000000000000000000000000000000000000]], [[110110110110110110000000110110110110110110110110]], [[000000000000000000000110000000000000000000000000]], [[000000000000000000000000000000000000000000000000]], [[000000000000110110000110010000000000000000010010]], [[000010000000000000000000000000000000000000000000]], [[000000000000000000000000000000000000000000000000]], [[110110110110110110110000110110110110000000000000]], [[000000000000000000000110000000000000000000000000]], [[000000000000000000000000000000000000000000000000]], [[110110110110110110110000110000000000000000010000]], [[000000000000000000000000100000000000000110000110]], [[000000000000000000000000000000000000000000000000]] }}

if krist then
    rawFont[1][31] = "\32\32\32\32\145\32\159\139\32\151\131\132\133\135\145\134\135\145\32\149\32\158\140\129\130\130\32\152\147\155\157\134\32\32\144\144\32\32\32\32\32\32\152\131\155\131\131\129"
    rawFont[1][32] = "\32\32\32\32\149\32\149\32\145\148\131\32\145\146\132\140\157\132\32\148\32\137\155\149\32\32\32\149\154\149\137\142\32\153\153\32\131\131\149\131\131\129\149\135\145\32\32\32"
    rawFont[1][33] = "\32\32\32\32\129\32\130\135\32\131\131\129\130\128\129\32\129\32\32\129\32\131\131\32\32\32\32\130\131\129\32\32\32\32\129\129\32\32\32\32\32\32\130\131\129\32\32\32"
    rawFont[2][32] = [[000000000100110000000010000011000110000000001000]]
end
--### Genarate fonts using 3x3 chars per a character. (1 character is 6x9 pixels)
local fonts = {}
local firstFont = {}
do
    local char = 0
    local height = #rawFont[1]
    local length = #rawFont[1][1]
    for i = 1, height, 3 do
        for j = 1, length, 3 do
            local thisChar = string.char(char)

            local temp = {}
            temp[1] = rawFont[1][i]:sub(j, j + 2)
            temp[2] = rawFont[1][i + 1]:sub(j, j + 2)
            temp[3] = rawFont[1][i + 2]:sub(j, j + 2)

            local temp2 = {}
            temp2[1] = rawFont[2][i]:sub(j, j + 2)
            temp2[2] = rawFont[2][i + 1]:sub(j, j + 2)
            temp2[3] = rawFont[2][i + 2]:sub(j, j + 2)

            firstFont[thisChar] = {temp, temp2}
            char = char + 1
        end
    end
    fonts[1] = firstFont
end

local function generateFontSize(size,yeld)
    local inverter = {["0"] = "1", ["1"] = "0"} --:gsub("[01]",inverter)
    if size<= #fonts then return true end
    for f = #fonts+1, size do
        --automagicly make bigger fonts using firstFont and fonts[f-1].
        local nextFont = {}
        local lastFont = fonts[f - 1]
        for char = 0, 255 do
            local thisChar = string.char(char)
            --sleep(0) print(f,thisChar)

            local temp = {}
            local temp2 = {}

            local templateChar = lastFont[thisChar][1]
            local templateBack = lastFont[thisChar][2]
            for i = 1, #templateChar do
                local line1, line2, line3, back1, back2, back3 = {}, {}, {}, {}, {}, {}
                for j = 1, #templateChar[1] do
                    local currentChar = firstFont[templateChar[i]:sub(j, j)][1]
                    table.insert(line1, currentChar[1])
                    table.insert(line2, currentChar[2])
                    table.insert(line3, currentChar[3])

                    local currentBack = firstFont[templateChar[i]:sub(j, j)][2]
                    if templateBack[i]:sub(j, j) == "1" then
                        table.insert(back1, (currentBack[1]:gsub("[01]", inverter)))
                        table.insert(back2, (currentBack[2]:gsub("[01]", inverter)))
                        table.insert(back3, (currentBack[3]:gsub("[01]", inverter)))
                    else
                        table.insert(back1, currentBack[1])
                        table.insert(back2, currentBack[2])
                        table.insert(back3, currentBack[3])
                    end
                end
                table.insert(temp, table.concat(line1))
                table.insert(temp, table.concat(line2))
                table.insert(temp, table.concat(line3))
                table.insert(temp2, table.concat(back1))
                table.insert(temp2, table.concat(back2))
                table.insert(temp2, table.concat(back3))
            end

            nextFont[thisChar] = {temp, temp2}
            if yeld then yeld = "Font"..f.."Yeld"..char os.queueEvent(yeld) os.pullEvent(yeld) end
        end
        fonts[f] = nextFont
    end
    return true
end

generateFontSize(3,false)

--## Use pre-generated fonts instead of old code above.

--local fonts = {}

local tHex = {[ colors.white ] = "0", [ colors.orange ] = "1", [ colors.magenta ] = "2", [ colors.lightBlue ] = "3", [ colors.yellow ] = "4", [ colors.lime ] = "5", [ colors.pink ] = "6", [ colors.gray ] = "7", [ colors.lightGray ] = "8", [ colors.cyan ] = "9", [ colors.purple ] = "a", [ colors.blue ] = "b", [ colors.brown ] = "c", [ colors.green ] = "d", [ colors.red ] = "e", [ colors.black ] = "f"}

--# Write data on terminal in specified location. Can scroll.
local function stamp(tTerminal, tData, nX, nY)

    local oX, oY = tTerminal.getSize()
    local cX, cY = #tData[1][1], #tData[1]
    nX = nX or math.floor((oX - cX) / 2) + 1
    nY = nY or math.floor((oY - cY) / 2) + 1

    for i = 1, cY do
        if i > 1 and nY + i - 1 > oY then term.scroll(1) nY = nY - 1 end
        tTerminal.setCursorPos(nX, nY + i - 1)
        tTerminal.blit(tData[1][i], tData[2][i], tData[3][i])
    end
end

--# Write data on terminal in specified location. No scroll.
local function press(tTerminal, tData, nX, nY)
    local oX, oY = tTerminal.getSize()
    local cX, cY = #tData[1][1], #tData[1]
    nX = nX or math.floor((oX - cX) / 2) + 1
    nY = nY or math.floor((oY - cY) / 2) + 1

    for i = 1, cY do
        tTerminal.setCursorPos(nX, nY + i - 1)
        tTerminal.blit(tData[1][i], tData[2][i], tData[3][i])
    end
end

--# Generate data from strings for data and colors.
local function makeText(nSize, sString, nFC, nBC, bBlit)
    if not type(sString) == "string" then error("Not a String",3) end --this should never happend with expects in place.
    local cFC = type(nFC) == "string" and nFC:sub(1, 1) or tHex[nFC] or error("Wrong Front Color",3)
    local cBC = type(nBC) == "string" and nBC:sub(1, 1) or tHex[nBC] or error("Wrong Back Color",3)
    local font = fonts[nSize] or error("Wrong font size selected",3)
    if sString == "" then return {{""}, {""}, {""}} end

    local input = {}
    for i in sString:gmatch('.') do table.insert(input, i) end

    local tText = {}
    local height = #font[input[1]][1]


    for nLine = 1, height do
        local outLine = {}
        for i = 1, #input do
            outLine[i] = font[input[i]] and font[input[i]][1][nLine] or ""
        end
        tText[nLine] = table.concat(outLine)
    end

    local tFront = {}
    local tBack = {}
    local tFrontSub = {["0"] = cFC, ["1"] = cBC}
    local tBackSub = {["0"] = cBC, ["1"] = cFC}

    for nLine = 1, height do
        local front = {}
        local back = {}
        for i = 1, #input do
            local template = font[input[i]] and font[input[i]][2][nLine] or ""
            front[i] = template:gsub("[01]", bBlit and {["0"] = nFC:sub(i, i), ["1"] = nBC:sub(i, i)} or tFrontSub)
            back[i] = template:gsub("[01]", bBlit and {["0"] = nBC:sub(i, i), ["1"] = nFC:sub(i, i)} or tBackSub)
        end
        tFront[nLine] = table.concat(front)
        tBack[nLine] = table.concat(back)
    end

    return {tText, tFront, tBack}
end

--# Writing in big font using current terminal settings.
b.bigWrite = function(sString)
    expect(1, sString, "string")
    stamp(term, makeText(1, sString, term.getTextColor(), term.getBackgroundColor()), term.getCursorPos())
    local x, y = term.getCursorPos()
    term.setCursorPos(x, y - 2)
end

b.bigBlit = function(sString, sFront, sBack)
    expect(1, sString, "string")
    expect(2, sFront, "string")
    expect(3, sBack, "string")
    if #sString ~= #sFront then error("Invalid length of text color string",2) end
    if #sString ~= #sBack then error("Invalid length of background color string",2) end
    stamp(term, makeText(1, sString, sFront, sBack, true), term.getCursorPos())
    local x, y = term.getCursorPos()
    term.setCursorPos(x, y - 2)
end

b.bigPrint = function(sString)
    expect(1, sString, "string")
    stamp(term, makeText(1, sString, term.getTextColor(), term.getBackgroundColor()), term.getCursorPos())
    print()
end

--# Writing in huge font using current terminal settings.
b.hugeWrite = function(sString)
    expect(1, sString, "string")
    stamp(term, makeText(2, sString, term.getTextColor(), term.getBackgroundColor()), term.getCursorPos())
    local x, y = term.getCursorPos()
    term.setCursorPos(x, y - 8)
end

b.hugeBlit = function(sString, sFront, sBack)
    expect(1, sString, "string")
    expect(2, sFront, "string")
    expect(3, sBack, "string")
    if #sString ~= #sFront then error("Invalid length of text color string",2) end
    if #sString ~= #sBack then error("Invalid length of background color string",2) end
    stamp(term, makeText(2, sString, sFront, sBack, true), term.getCursorPos())
    local x, y = term.getCursorPos()
    term.setCursorPos(x, y - 8)
end

b.hugePrint = function(sString)
    expect(1, sString, "string")
    stamp(term, makeText(2, sString, term.getTextColor(), term.getBackgroundColor()), term.getCursorPos())
    print()
end

--# Write/blit string on terminal in specified location
b.doc.writeOn = [[writeOn(tTerminal, nSize, sString, [nX], [nY]) - Writes sString on tTerminal using current tTerminal colours. nX, nY are coordinates. If any of them are nil then text is centered in that axis using tTerminal size.]]
b.writeOn = function(tTerminal, nSize, sString, nX, nY)
    expect(1, tTerminal, "table")
    field(tTerminal, "getSize", "function")
    field(tTerminal, "scroll", "function")
    field(tTerminal, "setCursorPos", "function")
    field(tTerminal, "blit", "function")
    field(tTerminal, "getTextColor", "function")
    field(tTerminal, "getBackgroundColor", "function")
    expect(2, nSize, "number")
    expect(3, sString, "string")
    expect(4, nX, "number", "nil")
    expect(5, nY, "number", "nil")
    press(tTerminal, makeText(nSize, sString, tTerminal.getTextColor(), tTerminal.getBackgroundColor()), nX, nY)
end

b.doc.blitOn = [[writeOn(tTerminal, nSize, sString, sFront, sBack, [nX], [nY]) - Blits sString on tTerminal with sFront and sBack colors . nX, nY are coordinates. If any of them are nil then text is centered in that axis using tTerminal size.]]
b.blitOn = function(tTerminal, nSize, sString, sFront, sBack, nX, nY)
    expect(1, tTerminal, "table")
    field(tTerminal, "getSize", "function")
    field(tTerminal, "scroll", "function")
    field(tTerminal, "setCursorPos", "function")
    field(tTerminal, "blit", "function")
    expect(2, nSize, "number")
    expect(3, sString, "string")
    expect(4, sFront, "string")
    expect(5, sBack, "string")
    if #sString ~= #sFront then error("Invalid length of text color string",2) end
    if #sString ~= #sBack then error("Invalid length of background color string",2) end
    expect(6, nX, "number", "nil")
    expect(7, nY, "number", "nil")
    press(tTerminal, makeText(nSize, sString, sFront, sBack, true), nX, nY)
end

--#
b.doc.makeBlittleText = [[makeBlittleText(nSize, sString, nFC, nBC) - Generate blittle object in size nSize with text sString in blittle format for printing with that api. nFC and nBC are colors to generate the object with.]]
b.makeBlittleText = function(nSize, sString, nFC, nBC)
    expect(1, nSize, "number")
    expect(2, sString, "string")
    expect(3, nFC, "number")
    expect(4, nBC, "number")
    local out = makeText(nSize, sString, nFC, nBC)
    out.height = #out[1]
    out.width = #out[1][1]
    return out
end

b.doc.generateFontSize = [[generateFontSize(size) - Generates bigger font sizes and enables then on other functions that accept size argument. By default bigfont loads sizes 1-3 as those can be generated without yielding. Using this user can generate sizes 4-6. Warning: This function will internally yield.]]
b.generateFontSize = function(size)
    expect(1, size, "number")
    if type(size) ~= "number" then error("Size needs to be a number",2) end
    if size > 6 then return false end
    return generateFontSize(math.floor(size),true)
end

--### Finalizing
return b
