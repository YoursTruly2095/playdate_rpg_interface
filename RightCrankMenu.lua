


--[[

This is based on 'playdate_rpg_interface' by u/ConfidentFloor6601, 
which can be found at https://github.com/ConfidentFloor6601/playdate_rpg_interface

 * ------------------------------------------------------------------------------
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source distribution.
 * -----------------------------------------------------------------------------
 * (This is the zlib License)

--]]

--[[

    Flexible RightCrankMenu

    To use, just 'require' this file in your game code, and call
    RightCrankMenu.load(), RightCrankMenu.draw(), and RightCrankMenu.update()
    from their respective love / playdate functions.
    
    To change the setup of the menu, change things in the 'Configuration' section below
    
    You can get the currently selected icon by calling 'get_current_icon()'. 
    
    This code also requires a tiny 'globals' module with provides the screen 
    width and height, and 'Crank' module which contains a virtual representation
    of the playdate crank (to be replaced by the real thing quite soon I hope!)
    
    A useful future extension might be to include a function to call when an
    icon is selected in the icon table, and to consume keypresses for selections.
    
--]]

require("globals")
local Crank = require("crank")

local RightCrankMenu = {}

-------------------------------------------------------------------------------------
------- CONFIGURATION ---------------------------------------------------------------
-------------------------------------------------------------------------------------

-- Titles for the icons selected with the Right Crank Menu (RCM).
-- You can add or take away from here, although your menu will start to 
-- misbehave if you have too few to fill the screen. But in that case, you 
-- can make them bigger below.
RightCrankMenu.menu_titles = {}

-- Crank icon dimensions (including borders)
-- You can set these freely (within reason).
-- Rectangles are okay.
RightCrankMenu.Ico_W = 40
RightCrankMenu.Ico_H = 40

-- This is the offset of the selection box from the top of the screen.
-- Can be set as a fraction of the screen size, or an absolute value.
-- You could even adjust it in real time to make the icons harder to 
-- select in game, if you wanted :-)
--RightCrankMenu.offset = (Scr_H - RightCrankMenu.Ico_H) / 2
RightCrankMenu.offset = 100

-- The angle through which to move the crank to select the next icon
-- Adjust in real-time if your player character quaffs too many potions of beer
RightCrankMenu.icon_shift_angle = 60  

-- the click wheel menu is active by default
RightCrankMenu.active = true

-- if you change the start icon, you need to set the initial RightCrankMenu.angle to match
RightCrankMenu.angle = 0

RightCrankMenu.current_icon = nil 
RightCrankMenu.full_rotation_angle = 0

function RightCrankMenu.register_icon(icon)
    
    -- set up defaults for options
    local after = nil     -- default to end of table
    local shift_angle = RightCrankMenu.default_icon_shift_angle
    
    -- handle options 
    if icon['enabled'] == nil then icon['enabled'] = true end
    
    if icon['after'] ~= nil then 
        after = icon['after']
        icon['after'] = nil
    end
    
    if icon['shift_ratio'] == nil then icon['shift_ratio'] = 1 end
    
    -- if this is the first option added, set it to the 'current' option
    if #RightCrankMenu.menu_titles == 0 then 
        RightCrankMenu.current_icon = 1
    end
    
    -- default to insert at the end of the menu
    local index = #RightCrankMenu.menu_titles+1
    local insert_angle = RightCrankMenu.full_rotation_angle
    
    -- if 'after' is specified, find the correct insertion index
    if after ~= nil then 
        for i,v in ipairs(RightCrankMenu.menu_titles) do
            if v['name'] == after then
                index = i+1
                insert_angle = RightCrankMenu.icon_shift_angle*i
            end
        end
    end
    
    table.insert(RightCrankMenu.menu_titles, index, icon)
    
    RightCrankMenu.full_rotation_angle = RightCrankMenu.full_rotation_angle + RightCrankMenu.icon_shift_angle
    
    -- correct for an icon inserted before our current selection in the menu
    if RightCrankMenu.angle >= insert_angle then
        RightCrankMenu.angle = RightCrankMenu.angle + RightCrankMenu.icon_shift_angle
    end
end

function RightCrankMenu.remove_icon(name)
    local menu = RightCrankMenu.menu_titles
    for i=#menu, 1, -1 do
        if menu[i]['name'] == name then
            table.remove(menu, i)
            if RightCrankMenu.angle >= i*RightCrankMenu.icon_shift_angle then
                RightCrankMenu.angle = RightCrankMenu.angle - RightCrankMenu.icon_shift_angle
            end
            RightCrankMenu.full_rotation_angle = RightCrankMenu.full_rotation_angle - RightCrankMenu.icon_shift_angle
        end
    end
end

function RightCrankMenu.enable_icon(name)
    for index,value in ipairs(RightCrankMenu.menu_titles) do
        if value['name'] == name then
            value['enabled'] = true
        end
    end
end

function RightCrankMenu.disable_icon(name)
    for index,value in ipairs(RightCrankMenu.menu_titles) do
        if value['name'] == name then
            value['enabled'] = false
        end
    end
end

function RightCrankMenu.set_shift_ratio(name, ratio)
    for index,value in ipairs(RightCrankMenu.menu_titles) do
        if value['name'] == name then
            value['shift_ratio'] = ratio
        end
    end
end
-------------------------------------------------------------------------------------
------- END CONFIGURATION -----------------------------------------------------------
-------------------------------------------------------------------------------------



-- this is internal use
RightCrankMenu.crank_angle = 0

--[[
function RightCrankMenu.load()
    for index,value in ipairs(RightCrankMenu.menu_titles) do
        RightCrankMenu.menu_titles[index]["icon"] = love.graphics.newImage(RightCrankMenu.menu_titles[index][2])
        if RightCrankMenu.menu_titles[index][3] ~= "" then
            RightCrankMenu.menu_titles[index]["icon_d"] = love.graphics.newImage(RightCrankMenu.menu_titles[index][3])
        end
        RightCrankMenu.menu_titles[index]["enabled"] = true 
    end
end
--]]


function RightCrankMenu.draw()

    -- Right Crank Menu Box Outlines and Icons
    for index,value in ipairs(RightCrankMenu.menu_titles) do
        local icon = "icon"
        if not RightCrankMenu.menu_titles[index]["enabled"] then icon = "disabled_icon" end
        RightCrankMenu.draw_icon(RightCrankMenu.menu_titles[index][icon],index-1)
    end

    -- "active icon" selector box here
    if RightCrankMenu.active then
        love.graphics.rectangle("line",Scr_W-RightCrankMenu.Ico_W,RightCrankMenu.offset,RightCrankMenu.Ico_W,RightCrankMenu.Ico_H)
        love.graphics.rectangle("line",Scr_W-RightCrankMenu.Ico_W+1,RightCrankMenu.offset+1,RightCrankMenu.Ico_W-2,RightCrankMenu.Ico_H-2)
    end
end

function RightCrankMenu.draw_icon(icon, order)
  
  local angle = RightCrankMenu.angle
  
  angle = -angle -- invert controls

  local function get_y_from_angle(angle, order)
    local y = (order + (angle/RightCrankMenu.icon_shift_angle)) * RightCrankMenu.Ico_H
    y = y + RightCrankMenu.offset
    return y
  end
  
  local y = get_y_from_angle(angle, order)
  
  if y > Scr_H then
    -- if y is right off the bottom of the screen, we should recalculate it in case it is at the top
    angle = angle - RightCrankMenu.full_rotation_angle
    y = get_y_from_angle(angle, order)
  elseif y+RightCrankMenu.Ico_H < 0 then
    -- if y is right off the top of the screen, we should recalculate it in case it is at the bottom
    angle = angle + RightCrankMenu.full_rotation_angle
    y = get_y_from_angle(angle, order)
  end
  
  local x = Scr_W - RightCrankMenu.Ico_W + ((RightCrankMenu.offset-y)^2)/1000
  
  love.graphics.draw(icon,x,y)
  love.graphics.rectangle("line",x,y,RightCrankMenu.Ico_W,RightCrankMenu.Ico_H)
  
end
    

function RightCrankMenu.set_active(active)
    RightCrankMenu.active = active
    RightCrankMenu.crank_angle = Crank.get_angle()    -- get the baseline angle for the next update
end

function RightCrankMenu.is_active(active)
    return RightCrankMenu.active
end

local debug_delta = 0

function RightCrankMenu.update(dt)
    if RightCrankMenu.is_active() then
        local last_crank_angle = RightCrankMenu.crank_angle
        RightCrankMenu.crank_angle = Crank.get_angle()
        local angle_delta = (RightCrankMenu.crank_angle - last_crank_angle)
        
        if math.abs(angle_delta) > 180 then
            -- assume overflow and the crank went the short way to this new angle
            if angle_delta > 0 then angle_delta = angle_delta - 360 else angle_delta = angle_delta + 360 end
        end
        
        -- adjust delta based on the angle ratio for the current icon
        local current = RightCrankMenu.get_active_icon()
        if current then
            angle_delta = angle_delta / current['shift_ratio']
        end
        
        RightCrankMenu.angle = (RightCrankMenu.angle + angle_delta) % RightCrankMenu.full_rotation_angle
        if angle_delta ~= 0 then
            debug_delta = angle_delta
        end
    end        
end

local debug_icon = 0

function RightCrankMenu.debug_print()
    love.graphics.print({{255,0,0,255},"RCM angle: ",{255,0,0,255},RightCrankMenu.angle},125,25)
    love.graphics.print({{255,0,0,255},"FRA: ",{255,0,0,255},RightCrankMenu.full_rotation_angle},125,50)
    love.graphics.print({{255,0,0,255},"delta: ",{255,0,0,255},debug_delta },125,75)
    love.graphics.print({{255,0,0,255},"icon: ",{255,0,0,255},debug_icon },125,100)
end

function RightCrankMenu.get_active_icon()
  
  local icon_selection = RightCrankMenu.angle / RightCrankMenu.icon_shift_angle
  
  -- This is going to be trouble with an actual crank, because currently it is relying on lining the
  -- icons up exactly in order to allow the selection to happen. That's okay with keys or with a 
  -- clicky USB knob with a set number of clicks per rotation, but it's not going to work with
  -- the playdate crank. Some effort required here.
  if icon_selection%1 == 0 then
    RightCrankMenu.current_icon = icon_selection+1
  end
  
  -- this is one possible approach - but this selects the nearest icon, not 
  -- the last icon to have occupied the selection box
  --[[
  icon_selection = math.floor(icon_selection+0.5)
  RightCrankMenu.current_icon = icon_selection+1
  --]]
  
  
  debug_icon = icon_selection
  
  return RightCrankMenu.menu_titles[RightCrankMenu.current_icon]
end

function RightCrankMenu.select(args)
    
    local icon = RightCrankMenu.get_active_icon()
    if icon["enabled"] == true and icon["fn"] ~= nil then
          icon["fn"](args)
    end
end


return RightCrankMenu
