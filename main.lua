--[[

ORIGINAL FILE NOTICE

╦  ┌─┐┌─┐┌─┐┬    ╔╗ ┬┌┬┐┌─┐ 
║  ├┤ │ ┬├─┤│    ╠╩╗│ │ └─┐ 0
╩═╝└─┘└─┘┴ ┴┴─┘  ╚═╝┴ ┴ └─┘ 0

None of this code is optimized or guaranteed to work, but you're welcome
to use any of it in your own programs. The only thing I ask is if you use
or modify the "Right Crank Menu" context-sensitive scrolling icon selector,
that you credit u/ConfidentFloor6601 for the original implementation in 
your source code.

You're on your own for icons and stuff -- pixel art is actual effort at 
these scales, so I'm going to hang onto any copyrights for artwork I've
shared on Reddit and elsewhere. (The icons aren't that great anyway.)

╔═╗┌─┐┌┬┐┌┬┐┬┌┐┌┌─┐  ╔═╗┌┬┐┌─┐┬─┐┌┬┐┌─┐┌┬┐
║ ╦├┤  │  │ │││││ ┬  ╚═╗ │ ├─┤├┬┘ │ ├┤  ││ 0
╚═╝└─┘ ┴  ┴ ┴┘└┘└─┘  ╚═╝ ┴ ┴ ┴┴└─ ┴ └─┘─┴┘ 0

This code is written in Lua. If you don't know Lua, fighting with my
terrible code may be a good learning experience, but even if not, you
will need to install a compiler or an IDE for compiling all of this
into something resembling a functional program. I'm using ZeroBrane 
Studio on Windows 10; it seems to work fine, but I can't assume any
responsibility if it's actually riddled with malware or otherwise
nukes your system. With that glowing endorsement in place, you can
find it here: https://studio.zerobrane.com


This code requires LÖVE; there are instructions for downloading and
installing LÖVE at love2d.org. I'll let you figure that part out for
your own system, if you don't already have it running.

Icons that fit the current RCM are 36x36, with a two-pixel border for each
drawn by the RCM. The RCM occupies 40x240 pixels. The Left Context Menu (LCM)
occupies 100x240, leaving 240x240 in the middle for actual game content.
All of that can be changed in the code, so don't feel stuck with it.

For my pixel art, I've been using the offline version of Piskel on my
PC (https://www.piskelapp.com), and Pixel Studio on my android phone
(https://play.google.com/store/apps/details?id=com.PixelStudio)
Once again, I take absolutely no responsibility for either app, but
from my experience, Piskel is more intuitive, so I've done all of my
icons there, but Pixel Studio looks more powerful, is cross-platform,
and has more tools -- It just annoys me because I can never remember
where the save button is hidden.

I'm still teaching myself Lua, coming from C/C++ and Python, so a lot of 
this code feels really ugly to me, and it probably is. If you find better
ways to implement any of these functions, I'd playdate to hear about it, but 
don't waste your time dunking on me because I already know it's bad rn.

If you have any questions, feel free to DM me on Reddit. When I have some-
thing that more closely resembles a game, I'll probably start a Twitter or
something for it, but I'll announce that in r/playdate anyway.

Cheers and Happy Coding,
the Door Demon
]]


-- Banners from: https://manytools.org/hacker-tools/ascii-banner/
-- Font: Calvin S
-- Reason: I have a hard time finding functions in Lua, lol



--[[

NEW FILE NOTICE

This file is very much cut down from the original, and is included 
only to provide an example of how to use RightCrankMenu.lua and crank.lua,
and to make a program that runs for testing the menu.

Just as a note, I would also recommend ZeroBrane Studio to anyone
wanting to code in lua. 

--]]


import("globals")

RCM = import("RightCrankMenu")
--Crank = import("crank")


-- Initial value for icon_name
--icon_name = "Look"
-- Using the default font until I find something better
--playdate.graphics.setNewFont(18)

-- frame rate limiter
--local min_dt
--local next_update_time


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
            shift_ratio = 0.2,
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
    
local fight_option = 
{
    name='fight',   
    fn=function(x) print_message("You attack! Viciously!!") end, 
    icon="menu_graphics/fight_t.png",
}

local background

--[[
╔═╗╦ ╦╔╗╔╔═╗╔╦╗╦╔═╗╔╗╔╔═╗
╠╣ ║ ║║║║║   ║ ║║ ║║║║╚═╗
╚  ╚═╝╝╚╝╚═╝ ╩ ╩╚═╝╝╚╝╚═╝
]]



--[[
┬  ┌─┐┬  ┬┌─┐ ┬  ┌─┐┌─┐┌┬┐
│  │ │└┐┌┘├┤  │  │ │├─┤ ││
┴─┘└─┘ └┘ └─┘o┴─┘└─┘┴ ┴─┴┘

Should load any external assets in this function instead of in global
space. I believe playdate.load() is run before playdate.draw(), but if any of
the functions run before playdate.draw there are no guarantees.
]]

function myload()
    
    -- stuff for debugging in zerobrane
    -- comment this stuff out if you don't need it
    --if arg[#arg] == "-debug" then require("mobdebug").start() end
    --io.stdout:setvbuf("no")
    
    
    --print(_VERSION)

    -- Final version will be 1-bit color, but red == unfinished
    playdate.graphics.setBackgroundColor(1,1,1,255)

    -- Playdate screen should be 400x240. 
    -- Might add magnification factor for pixel doubling on PC
    --playdate.window.setMode(Scr_W,Scr_H,{resizable=false})
    --playdate.window.setTitle("Your Game Title Here")

    -- load the menu icons
    -- this repaces the file names in the data structure in the code, with the actual loaded icons
    for index,value in ipairs(menu_options) do
        value[1]['icon']=playdate.graphics.image.new(value[1]['icon'])
        if value[1]['disabled_icon'] then
            value[1]['disabled_icon']=playdate.graphics.image.new(value[1]['disabled_icon'])
        end
    end
    
    -- load the icon for the fight option too
    fight_option['icon']=playdate.graphics.image.new(fight_option['icon'])
    
    -- load the selctor
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
    
    
    -- frame rate limiter
    --min_dt = 1/30   -- fps
    --next_update_time = playdate.timer.getTime()     -- next update is immediate
    
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
  
  RCM.draw()
  

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


