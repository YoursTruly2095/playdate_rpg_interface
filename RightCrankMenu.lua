


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

Please credit u/ConfidentFloor6601 and YoursTruly2095 for this work.

--]]

--[[

    Flexible RightCrankMenu

    To use, just 'import' this file in your game code, and call
    RightCrankMenu.update() from playdate.update().
    
    To change the setup of the menu, change things in the 'Configuration' section below
    
    You can get the currently selected icon by calling 'get_current_icon()'. 
    
--]]

local RightCrankMenu = 
{ 
    menu_titles = {}, 
    current_icon = nil, 
    full_rotation_angle = 0,
    active = true,
    crank_angle = 0,
    hidden = false,
}

-------------------------------------------------------------------------------------
------- CONFIGURATION ---------------------------------------------------------------
-------------------------------------------------------------------------------------

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


-- if you change the start icon, you need to set the initial RightCrankMenu.angle to match
RightCrankMenu.angle = 0

-------------------------------------------------------------------------------------
------- END CONFIGURATION -----------------------------------------------------------
-------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------
------- API FUNCTIONS ---------------------------------------------------------------
-------------------------------------------------------------------------------------
--[[

Add an entry to the menu the menu.

    RightCrankMenu.add_icon(icon, after)

    'icon' is a table similar to this:
        
        icon = 
        {
            name='name_of_option',    
            fn=function(x) thing_to_do_when_selected() end,  
            icon=<a preloaded playdate.graphics.image>,
            disabled_icon=<another preloaded playdate.graphics.image>,      -- optional
            enabled = false,                                                -- optional, default true  
            shift_ratio = 0.2,                                              -- optional, default 1              
        },

    where:

        name: a string which is used to refer to the entry. Multiple entries
              can have the same name, and will all then have the same properties.
              
        fn: a callback function which is called when the play selects the menu
            entry. 
            
        icon: the playdate.graphics.image object to display in the menu for this 
              entry. You will lead to load ths before adding the icon.
              
        disabled_icon: (optional) an additional icon for display if the menu
                       option is disabled. You only need this if you plan on
                       actually disabling the menu option.
                       
        enabled: (optional) the initial enabled state of the icon. Defaults to
                 true.
        
        shift_ratio: (optional) This controls how fast the crank moves an icon
                     past the selector. Shift ratios less than 1 will make the 
                     icon move past quickly, and therefore be harder to select.
                     Shift ratios greater than 1 make the icon move past slower
                     and be easier to select. The intention for this option is
                     to bring some gameplay into the menu itself; for example,
                     if the character in a game was drunk, maybe the 'climb
                     ladder' option would be difficult to select? Could also be
                     good in 'game plays player' type games (e.g. Doki Doki
                     Literature Club or Undertale)

    'after' is the name of the icon after which to insert the new entry. You
            can leave this as null for insertion at the end of the menu

Remove an item from the menu

    RightCrankMenu.remove_icon(name)
    
    'name' is the name of the item to remove, as specified when the item was added


Enable / disable menu items
    
    RightCrankMenu.enable_icon(name)
    RightCrankMenu.disable_icon(name)

    'name' is the name of the item to remove, as specified when the item was added


Change the shift ratio of a menu item to make it harder or easier to select

    RightCrankMenu.set_shift_ratio(name, ratio)
    
    'name' is the name of the item to remove, as specified when the item was added
    
    'ratio' is the new shift ratio, below 1 is harder to select, above 1 is easier
    
Check the shift ratio for a menu item
    
    RightCrankMenu.get_shift_ratio(name)
    
    'name' is the name of the item to remove, as specified when the item was added
    
    returns the shift ration of the names menu item
    
Register the image for the menu selector    

    RightCrankMenu.register_selector(selector)
    
    'selector' is the playdate.graphics.image object to use for selection
    
    
Make the menu active or inactive. When the menu is inactive the selector will be
hidden. This is useful if you want to use the crank for other things in your game 
as well as the menu.

    RightCrankMenu.set_active(active)
    
    'active' is true or false
    
    
Query the menu to see if it is active at the moment

    RightCrankMenu.is_active(active)
    
    returns true or false
    
    
Query the menu to see which icon is under the selector. Could be used for menu
effects without the player ever actually selecting an item.

    RightCrankMenu.get_active_icon()
    
    returns the name of the icon under the selector


Trigger a menu selection. Call this from your game to trigger a call to the 
function for the menu option under the selector. This is left up to you to
call from your game so you can choose what input to use, button A, button B,
arrow key, crank left motionless for 200ms, whatever.

    RightCrankMenu.select(args)
    
    'args' is whatever you want, and will get passed to the menu option 
           callback function. It is fine to leave this blank if you don't
           need it.
    

The menu can be hidden, and will slide off and on the screen when hidden and
shown. The following functions control this behaviour.

    RightCrankMenu.is_hidden()
    
    returns true or false
    
   
    RightCrankMenu.hide(mode)
    
    'mode' can be 'no_deactivate' or just leave blank. By default the menu be
           deactivated when it is hidden, but by specifying 'no_deactivate' 
           you can leave the menu active while it is hidden.
           
           
    RightCrankMenu.show(mode)
    
    'mode' can be 'no_activate' or just leave blank. By default the menu is
           activated when it is shown, but by specifying 'no_activate' you can 
           leave the menu deactivated after it is shown.
--]]
function RightCrankMenu.add_icon(icon, after)
    
    -- set up defaults for options
    local shift_angle = RightCrankMenu.default_icon_shift_angle
    
    -- handle options 
    if icon['enabled'] == nil then icon['enabled'] = true end
    
    if icon['shift_ratio'] == nil then icon['shift_ratio'] = 1 end
    
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
    if index > RightCrankMenu.get_active_icon_index() then
        RightCrankMenu.angle = RightCrankMenu.angle + RightCrankMenu.icon_shift_angle
    end
end

function RightCrankMenu.remove_icon(name)
    local menu = RightCrankMenu.menu_titles
    for i=#menu, 1, -1 do
        if menu[i]['name'] == name then
            table.remove(menu, i)
            if i >= RightCrankMenu.get_active_icon_index() then
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

function RightCrankMenu.get_shift_ratio(name)
    for index,value in ipairs(RightCrankMenu.menu_titles) do
        if value['name'] == name then
            return value['shift_ratio']
        end
    end
end

function RightCrankMenu.register_selector(selector)
    RightCrankMenu.selector = selector
end


function RightCrankMenu.set_active(active)
    RightCrankMenu.crank_angle = playdate.getCrankPosition()
    RightCrankMenu.active = active
end

function RightCrankMenu.is_active(active)
    return RightCrankMenu.active
end

function RightCrankMenu.get_active_icon_index()
    local icon_selection = RightCrankMenu.angle / RightCrankMenu.icon_shift_angle
    icon_selection = math.ceil(icon_selection+0.5)
    
    -- handle wrapping
    if icon_selection > #RightCrankMenu.menu_titles then icon_selection = 1 end
    
    return icon_selection
end
    
function RightCrankMenu.get_active_icon()
    return RightCrankMenu.menu_titles[RightCrankMenu.get_active_icon_index()]
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

-------------------------------------------------------------------------------------
------- END API FUNCTIONS -----------------------------------------------------------
-------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------
------- UPDATE ----------------------------------------------------------------------
-------------------------------------------------------------------------------------
--[[

Call this from playdate.update().

'dt' is 'delta time'. This is really a hang-over from Love2d, which passes you the 
amount of time since the last update in the call to love.update().

Playdate handles things slightly differently, by attempting to call update absolutley 
regularly, at the specified frame rate. This defaults to 30fps, so for a game that
isn't stretching the hardware, you can just pass 1/30 for the 'dt' argument and all
should be well. If you decide to alter the playedate frame rate, adjust accordingly.
If you find yourself with a variable framerate, you can apparently calculate the real 
delta time using playdate.getCurrentTimeMilliseconds(), and RightCrankMenu should
work happily.

--]]

function RightCrankMenu.update(dt)
    
    if dt == null then dt = 1/30 end
    
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


-------------------------------------------------------------------------------------
------- DRAW ------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--[[ 

As far as playdate is concerned, draw() is an internal function, and to fit with the
playdate design this function is called from RightCrankMenu.update() (above). If you're 
happy with this or don't know what I'm on about, stop reading, it's fine :-)

However, if you have code that is structured as per Love2d and you were suprised to find
that there was no playdate.draw() callback, you might benefit from being able to do the
update and the draw of the menu separately. In that case, just comment out the call to 
RightCrankMenu.draw() at the bottom of RightCrankMenu.update(), and call 
RightCrankMenu.draw() directly from your code as appropriate.

--]]

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
            x = RightCrankMenu.calculate_animation_x(x)
        end
        
        if RightCrankMenu.selector then
            playdate.graphics.image.draw(selector,x,y)
        else
            playdate.graphics.drawRect(x,y,w,h)
            playdate.graphics.drawRect(x+1,y+1,w-2,h-2)
        end
    end
end

-------------------------------------------------------------------------------------
------- INTERNALS -------------------------------------------------------------------
-------------------------------------------------------------------------------------

function RightCrankMenu.calculate_animation_x(x)
    local offscreen_x = playdate.display.getWidth()
    local ratio = RightCrankMenu.get_animation_ratio()
    if RightCrankMenu.animation_type == 'hide' then
        x = x + (offscreen_x - x) * (ratio)
    elseif RightCrankMenu.animation_type == 'show' then
        x = x + (offscreen_x - x) * (1-ratio)
    end
    return x
end


function RightCrankMenu.draw_icon(icon, order)
  
  local angle = RightCrankMenu.angle
  local Scr_W, Scr_H = playdate.display.getSize()

  angle = -angle -- invert controls

  local function get_functional_icon_height()
    local h = RightCrankMenu.Ico_H
    if (#RightCrankMenu.menu_titles * RightCrankMenu.Ico_H) < Scr_H then
        h = Scr_H / #RightCrankMenu.menu_titles
    end
    return h
  end

  local function get_y_from_angle(angle, order)
    local y = (order + (angle/RightCrankMenu.icon_shift_angle)) * get_functional_icon_height()
    y = y + RightCrankMenu.offset
    return y
  end
  
  local y={}
  y[1] = get_y_from_angle(angle, order)
  y[2] = get_y_from_angle(angle - RightCrankMenu.full_rotation_angle, order)
  y[3] = get_y_from_angle(angle + RightCrankMenu.full_rotation_angle, order)
  
  local x={}
  x[1] = Scr_W - RightCrankMenu.Ico_W + ((RightCrankMenu.offset-y[1])^2)/1000
  x[2] = Scr_W - RightCrankMenu.Ico_W + ((RightCrankMenu.offset-y[2])^2)/1000
  x[3] = Scr_W - RightCrankMenu.Ico_W + ((RightCrankMenu.offset-y[3])^2)/1000
  
    if RightCrankMenu.animating then
        x[1] = RightCrankMenu.calculate_animation_x(x[1])
        x[2] = RightCrankMenu.calculate_animation_x(x[2])
        x[3] = RightCrankMenu.calculate_animation_x(x[3])
    end
  
  local fh = get_functional_icon_height()
  for c = 1,3 do
    if y[c] > -fh and y[c] < Scr_H + fh then
        playdate.graphics.image.draw(icon,x[c],y[c])
    end
  end
  
end
    
local debug_delta = 0


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
    playdate.graphics.drawText("icon: "..RightCrankMenu.get_active_icon_index(),125,100)
end

return RightCrankMenu
