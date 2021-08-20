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
ways to implement any of these functions, I'd love to hear about it, but 
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


require("globals")

RightCrankMenu = require("RightCrankMenu")
Crank = require("crank")


-- Initial value for icon_name
--icon_name = "Look"
-- Using the default font until I find something better
love.graphics.setNewFont(18)



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
space. I believe love.load() is run before love.draw(), but if any of
the functions run before love.draw there are no guarantees.
]]

function love.load()
  print(_VERSION)
  
  -- Final version will be 1-bit color, but red == unfinished
  love.graphics.setBackgroundColor(0,0,0,255)
  
  -- Playdate screen should be 400x240. 
  -- Might add magnification factor for pixel doubling on PC
  love.window.setMode(Scr_W,Scr_H,{resizable=false})
  love.window.setTitle("Your Game Title Here")

  -- load the menu stuff
  RightCrankMenu.load()
  

end


function love.update(dt)
    RightCrankMenu.update(dt)
end


--[[
┬  ┌─┐┬  ┬┌─┐ ┌┬┐┬─┐┌─┐┬ ┬
│  │ │└┐┌┘├┤   ││├┬┘├─┤│││
┴─┘└─┘ └┘ └─┘o─┴┘┴└─┴ ┴└┴┘
]]
function love.draw()
  
  RightCrankMenu.draw()
  

  -- Crank-selected Menu Main Box Outline
  love.graphics.rectangle("line",2,2,116,236)
    
    
  -- Any text goes down here
  print_selected_icon()
  
  --[[
    Debuggery here
  ]]
  Crank.debug_print()
  RightCrankMenu.debug_print()
  
end


--[[
┌─┐┬─┐┬┌┐┌┌┬┐   ┌─┐┌─┐┬  ┌─┐┌─┐┌┬┐┌─┐┌┬┐    ┬┌─┐┌─┐┌┐┌
├─┘├┬┘││││ │    └─┐├┤ │  ├┤ │   │ ├┤  ││    ││  │ ││││
┴  ┴└─┴┘└┘ ┴────└─┘└─┘┴─┘└─┘└─┘ ┴ └─┘─┴┘────┴└─┘└─┘┘└┘

    print_selected_icon grabs the name of each icon from the RCM, and
    prints it to the box located at the top of the LCM. This doesn't
    activate that selection in the LCM, just displays it. To activate
    the LCM (or give it focus) the user will have to press left.
]]
function print_selected_icon()
  
  local icon_data = RightCrankMenu.get_active_icon()
  love.graphics.printf(icon_data[1],0,3,120,"center")

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
function love.keypressed(key)
  
  local consumed = Crank.keypressed(key)
  if not consumed then
    --handle other keypresses
    if RightCrankMenu.is_active() then
      if key == "a" or key == "left" then
        RightCrankMenu.set_active(false)
      end
    else
      if key == "d" or key == "right" then
        RightCrankMenu.set_active(true)
      end
    end  
  end

end


