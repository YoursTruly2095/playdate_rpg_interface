


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
    from their respective playdate / playdate functions.
    
    To change the setup of the menu, change things in the 'Configuration' section below
    
    You can get the currently selected icon by calling 'get_current_icon()'. 
    
    This code also requires a tiny 'globals' module with provides the screen 
    width and height, and 'Crank' module which contains a virtual representation
    of the playdate crank (to be replaced by the real thing quite soon I hope!)
    
    A useful future extension might be to include a function to call when an
    icon is selected in the icon table, and to consume keypresses for selections.
    
--]]

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
--RightCrankMenu.offset = (playdate.display.getHeight() - RightCrankMenu.Ico_H) / 2
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

function RightCrankMenu.register_selector(selector)
    RightCrankMenu.selector = selector
end

-------------------------------------------------------------------------------------
------- END CONFIGURATION -----------------------------------------------------------
-------------------------------------------------------------------------------------



-- this is internal use
RightCrankMenu.crank_angle = 0

RightCrankMenu.hidden = false

--[[
function RightCrankMenu.load()
    for index,value in ipairs(RightCrankMenu.menu_titles) do
        RightCrankMenu.menu_titles[index]["icon"] = playdate.graphics.image.new(RightCrankMenu.menu_titles[index][2])
        if RightCrankMenu.menu_titles[index][3] ~= "" then
            RightCrankMenu.menu_titles[index]["icon_d"] = playdate.graphics.image.new(RightCrankMenu.menu_titles[index][3])
        end
        RightCrankMenu.menu_titles[index]["enabled"] = true 
    end
end
--]]

local function calculate_animation_x(x)
    local offscreen_x = playdate.display.getWidth()
    local ratio = RightCrankMenu.get_animation_ratio()
    if RightCrankMenu.animation_type == 'hide' then
        x = x + (offscreen_x - x) * (ratio)
    elseif RightCrankMenu.animation_type == 'show' then
        x = x + (offscreen_x - x) * (1-ratio)
    end
    return x
end

function RightCrankMenu.draw()

    if RightCrankMenu.hidden and not RightCrankMenu.animating then return end

    -- Right Crank Menu Box Outlines and Icons
    for index,value in ipairs(RightCrankMenu.menu_titles) do
        local icon = "icon"
        if not RightCrankMenu.menu_titles[index]["enabled"] then icon = "disabled_icon" end
        RightCrankMenu.draw_icon(RightCrankMenu.menu_titles[index][icon],index-1)
    end

    -- "active icon" selector box here
    if RightCrankMenu.active or RightCrankMenu.animating_selector then
        
        local w, h, x, y
        local selector
        local Src_W = playdate.display.getWidth()
        
        if RightCrankMenu.selector then
            selector = RightCrankMenu.selector
            w,h = selector:getSize()
            x = Src_W-RightCrankMenu.Ico_W - (w-RightCrankMenu.Ico_W)/2
            y = RightCrankMenu.offset - (h-RightCrankMenu.Ico_H)/2
        else
            w = RightCrankMenu.Ico_W
            h = RightCrankMenu.Ico_H
            x = Scr_W-RightCrankMenu.Ico_W
            y = RightCrankMenu.offset
        end
        
        if RightCrankMenu.animating_selector then
            x = calculate_animation_x(x)
        end
        
        if RightCrankMenu.selector then
            playdate.graphics.image.draw(selector,x,y)
        else
            playdate.graphics.drawRect(x,y,w,h)
            playdate.graphics.drawRect(x+1,y+1,w-2,h-2)
        end
    end
end

function RightCrankMenu.draw_icon(icon, order)
  
  local angle = RightCrankMenu.angle
  local Scr_W, Scr_H = playdate.display.getSize()

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
  
    if RightCrankMenu.animating then
        x = calculate_animation_x(x)
    end
  
  playdate.graphics.image.draw(icon,x,y)
  
end
    

function RightCrankMenu.set_active(active)
    RightCrankMenu.crank_angle = playdate.getCrankPosition()
    RightCrankMenu.active = active
end

function RightCrankMenu.is_active(active)
    return RightCrankMenu.active
end

local debug_delta = 0

function RightCrankMenu.update(dt)
    
    -- handle the crank input
    if RightCrankMenu.is_active() then
        local last_crank_angle = RightCrankMenu.crank_angle
        RightCrankMenu.crank_angle = playdate.getCrankPosition()
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
    
    -- handle the show / hide animation
    if RightCrankMenu.start_animation then
        RightCrankMenu.animation_elapsed = 0
        RightCrankMenu.start_animation = false
        RightCrankMenu.animating = true
    elseif RightCrankMenu.animating then
        RightCrankMenu.animation_elapsed = RightCrankMenu.animation_elapsed + dt
        if RightCrankMenu.animation_elapsed > RightCrankMenu.animation_time then
            RightCrankMenu.animating = false
            RightCrankMenu.animating_selector = false
        end
    end
    
    RightCrankMenu.draw()
    
end

function RightCrankMenu.get_animation_ratio()
    if not RightCrankMenu.animating then
        return 1
    else
        return RightCrankMenu.animation_elapsed / RightCrankMenu.animation_time
    end
end

    
function RightCrankMenu.debug_print()
    playdate.graphics.drawText("RCM angle: "..RightCrankMenu.angle,125,25)
    playdate.graphics.drawText("FRA: "..RightCrankMenu.full_rotation_angle,125,50)
    playdate.graphics.drawText("delta: "..debug_delta,125,75)
    playdate.graphics.drawText("icon: "..RightCrankMenu.current_icon,125,100)
end

function RightCrankMenu.get_active_icon()
  
    local icon_selection = RightCrankMenu.angle / RightCrankMenu.icon_shift_angle
    icon_selection = math.ceil(icon_selection+0.5)
    
    -- handle wrapping
    if icon_selection > #RightCrankMenu.menu_titles then icon_selection = 1 end
    
    RightCrankMenu.current_icon = icon_selection
    
    return RightCrankMenu.menu_titles[RightCrankMenu.current_icon]
end

function RightCrankMenu.select(args)
    local icon = RightCrankMenu.get_active_icon()
    if icon["enabled"] == true and icon["fn"] ~= nil then
          icon["fn"](args)
    end
end

function RightCrankMenu.is_hidden()
    return RightCrankMenu.hidden
end

function RightCrankMenu.hide(mode)
    RightCrankMenu.hidden = true
    
    RightCrankMenu.animating_selector = RightCrankMenu.is_active()
    
    if mode ~= 'no_deactivate' then
        RightCrankMenu.set_active(false)
    end
    
    RightCrankMenu.animation_time = 0.33       -- seconds
    RightCrankMenu.start_animation = true
    RightCrankMenu.animation_type = 'hide'
end

function RightCrankMenu.show(mode)
    
    if mode ~= 'no_activate' then
        RightCrankMenu.set_active(true)
    end
    
    RightCrankMenu.animating_selector = RightCrankMenu.is_active()

    RightCrankMenu.hidden = false
    
    RightCrankMenu.animation_time = 0.33       -- seconds
    RightCrankMenu.start_animation = true
    RightCrankMenu.animation_type = 'show'
end

return RightCrankMenu
