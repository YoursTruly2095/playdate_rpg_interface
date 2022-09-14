
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

This file is included to provide an example of how to use the features of
RightCrankMenu.lua.

--]]



RCM = import("RightCrankMenu")

-- a flag to demonstrate icons being enabled and disabled
local can_talk = false
local menu_message = ""

--[[ 
    Menu Definition
--]]

local menu_options = 
{
    {
        {
            name='look',
            fn=function(x) look() end,   
            icon="menu_graphics/look_t.png",
            shift_ratio = 0.2,                  -- this will make the menu seem to skip past this option very quickly - use this to mess with your players!
                                                -- you can also set the shift ration to greater than 1 to make an option 'sticky', and alter the shift ratio at runtime
        },
    },
    {
        {
            name='talk',    
            fn=function(x) talk() end,  
            icon="menu_graphics/talk_t.png",
            disabled_icon="menu_graphics/talk_d.png",
            enabled = false,
        },
    },
    {
        {
            name='magic',       
            fn=function(x) magic() end,      
            icon="menu_graphics/magic_t.png",
        },
    },
    {
        {
            name='items',        
            fn=function(x) print_message("You rifle through your belongings") end,       
            icon="menu_graphics/items_t.png",
        }
    },
    {
        {
            name='gear',        
            fn=function(x) equipment() end,      
            icon="menu_graphics/gear_t.png",
        }
    },
    {
        {
            name='options',       
            fn=function(x) print_message("You access a meta-physical menu in another world") end,     
            icon="menu_graphics/settings_t.png",
        }
    },
    {
        {
            name='game',       
            fn=function(x) print_message("Monika already got your files") end,   
            icon="menu_graphics/game_t.png",
        }
    },
}
    
-- this option won't be in the menu at startup, but gets added dynamically later
local fight_option = 
{
    name='fight',   
    fn=function(x) print_message("You attack! Viciously!!") end, 
    icon="menu_graphics/fight_t.png",
}

local background



function myload()
    
    playdate.graphics.setBackgroundColor(1,1,1,255)

    -- load the menu icons
    -- this replaces the file names in the data structure in the code, with the actual loaded icons
    for index,value in ipairs(menu_options) do
        value[1]['icon']=playdate.graphics.image.new(value[1]['icon'])
        if value[1]['disabled_icon'] then
            value[1]['disabled_icon']=playdate.graphics.image.new(value[1]['disabled_icon'])
        end
    end
    
    -- load the icon for the fight option too
    fight_option['icon']=playdate.graphics.image.new(fight_option['icon'])
    
    -- load the selector
    local selector = playdate.graphics.image.new("menu_graphics/selector.png")
    RCM.register_selector(selector)
    
    -- register the icons with the menu
    print("Registering anything?")
    for _,value in ipairs(menu_options) do
        print("Registering "..value[1].name)
        RCM.register_icon(value[1])             
    end
    
    -- load the background image
    background = playdate.graphics.image.new("menu_graphics/background.png")
    
end

myload()

function playdate.update(dt)
    -- set the time for the next call to update
    --next_update_time = next_update_time + min_dt
    
    RCM.update(dt)
    draw()
end


--[[
┬  ┌─┐┬  ┬┌─┐ ┌┬┐┬─┐┌─┐┬ ┬
│  │ │└┐┌┘├┤   ││├┬┘├─┤│││
┴─┘└─┘ └┘ └─┘o─┴┘┴└─┴ ┴└┴┘
]]
function draw()
  
  --playdate.graphics.draw(background,0,0)
  
  

  -- Crank-selected Menu Main Box Outline
  playdate.graphics.setColor(0,0,0,255)
  playdate.graphics.drawRect(2,2,116,192)
  playdate.graphics.setColor(1,1,1,255)
    
    
  -- Any text goes down here
  local icon_data = RCM.get_active_icon()
--  playdate.graphics.printf({{0,0,0,255},icon_data['name']},0,3,120,"center")
  playdate.graphics.drawText(icon_data['name'],3,120)
  
    -- print a message from the menu
--  playdate.graphics.print({{128,0,0,255},menu_message},0,200)
  playdate.graphics.drawText(menu_message,0,200)

  --[[
    Debuggery here
  ]]
--  Crank.debug_print()
  RCM.debug_print()
  
    -- frame rate limiter
    --local current_time = playdate.timer.getTime()
    --if next_update_time <= current_time then
--        next_update_time = current_time
    --else
        --playdate.timer.sleep(next_update_time - current_time)  
    --end
end



function print_message(message)
  
  menu_message=message

end

function look()
    print_message("You looked, so now you can talk") 
    can_talk = true    
    RCM.enable_icon("talk")
end

function talk()
    print_message("You talk, so now you must look") 
    can_talk = false    
    RCM.disable_icon("talk")
end

function magic()
    print_message("You magic up a sword - now fight!")    
    -- insert the fight option into the menu after 'talk'
    fight_option['after'] = 'talk'
    fight_option['shift_ratio'] = 2
    RCM.register_icon(fight_option)   -- insert 'fight' after talk, and require 120 degrees crank to move past it

    -- set ratio for 'look' back to 1 
    RCM.set_shift_ratio('look', 1)
    
end

function equipment()
    print_message("You clumsily drop your sword(s)!!")
    -- remove any 'fight' icons from the list    
    RCM.remove_icon('fight')
end

--[[
┬  ┌─┐┬  ┬┌─┐ ┬┌─┌─┐┬ ┬┌─┐┬─┐┌─┐┌─┐┌─┐┌─┐┌┬┐
│  │ │└┐┌┘├┤  ├┴┐├┤ └┬┘├─┘├┬┘├┤ └─┐└─┐├┤  ││
┴─┘└─┘ └┘ └─┘o┴ ┴└─┘ ┴ ┴  ┴└─└─┘└─┘└─┘└─┘─┴┘
  Buttons will function differently depending on which menu or screen is
  currently in focus, so our keyparser needs to be aware of which state 
  it is in.
  
  ABSOLUTE ANGLE (knob_angle) must be updated with every click, however.
  Each click is 12' +/- previous value
]]
function playdate.keypressed(key)
  
--    local consumed = Crank.keypressed(key)

    if not consumed then
        --handle other keypresses
        if RCM.is_active() then
            if key == "a" or key == "left" then
                RCM.set_active(false)
            end
            if key == "space" then
                RCM.select(nil)
            end
        else
            if key == "d" or key == "right" then
                RCM.set_active(true)
            end
        end  
        if key == "s" then
            if RCM.is_hidden() then
                RCM.show()
            else
                RCM.hide()
            end
        end
    end

end

function playdate.wheelmoved(dx,dy)
--    Crank.moved(dy)
end


