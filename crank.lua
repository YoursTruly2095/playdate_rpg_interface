

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

    Crank - a virtual representation of the playdate crank

    To use, just 'require' this file in your game code, and call
    Crank.keypress() from their respective love.keypress(). On an
    actual playdate this will need to be rewritten to take input from 
    the actual crank, or hopefully just removed completely.
    
    To get the current crank angle, calle 'Crank.get_angle()'
    
--]]

local Crank = {}

-- My usb knob does 30 clicks per rotation, so 12' per click
-- No way to track absolute angle between runs so assume 0'
Crank.knob_angle = 0
-- Set to 0 means no recent clicks
Crank.click_time = 0


-- The most recent direction the crank was turned. +=cw, -=ccw
Crank.direction = 0




function Crank.keypressed(key)
    
    local consumed = false
    
    if key == "kp+" or key == "up" then
      Crank.knob_angle = (Crank.knob_angle - 12)%360
      Crank.crank_direction = -1
      consumed = true
    elseif key == "kp-" or key == "down" then
      Crank.knob_angle = (Crank.knob_angle + 12)%360
      Crank.direction = 1
      consumed = true
    end
    
    return consumed
end


--[[
┌─┐┌─┐┌┬┐   ┌─┐┬─┐┌─┐┌┐┌┬┌─   ┬  ┬┌─┐┬  ┌─┐┌─┐┬┌┬┐┬ ┬
│ ┬├┤  │    │  ├┬┘├─┤│││├┴┐   └┐┌┘├┤ │  │ ││  │ │ └┬┘
└─┘└─┘ ┴────└─┘┴└─┴ ┴┘└┘┴ ┴────└┘ └─┘┴─┘└─┘└─┘┴ ┴  ┴ 
]]
--[[

I removed this for now, because the actual menu isn't using it.

I think if the velocity is required, the correct way to implement would
be to call a function Crank.update(dt)from love.update(dt), and in that
function, measure the delta of the crank angle, and combine with the 
delta of time (dt) passed in from love.update().

But I suspect it might be tricky to get it right if you want to monitor
for stuff like short sharp twists on the crank or that sort of thing.
Probably really need an actual crank to test it out with too!

function Crank.get_velocity()
  
  local prev_click_time = Crank.click_time
  Crank.click_time = love.timer.getTime()
  
  if prev_click_time == 0 then
    return 0 -- Magic Number, don't care.
  else
    return (12 * Crank.direction) / (Crank.click_time - prev_click_time)
  end
end
--]]

function Crank.debug_print()
  love.graphics.print({{255,0,0,255},"Angle: ",{255,0,0,255},Crank.knob_angle},125,5)
  --love.graphics.print({{255,0,0,255},"°/sec: ",{255,0,0,255},Crank.get_velocity()},125,25)
end

function Crank.get_angle()
    return Crank.knob_angle
end


return Crank
