
local Crank = {}

-- My usb knob does 30 clicks per rotation, so 12' per click
-- No way to track absolute angle between runs so assume 0'
Crank.knob_angle = 0
-- Set to 0 means no recent clicks
Crank.click_time = 0


-- The most recent direction the crank was turned. +=cw, -=ccw
Crank.direction = 0




function Crank.keypressed(key)
    if key == "kp+" or key == "up" then
      Crank.knob_angle = (Crank.knob_angle - 12)%360
--      Crank.offset = (Crank.offset + 8)%Crank.maxval
      Crank.crank_direction = -1
    elseif key == "kp-" or key == "down" then
      Crank.knob_angle = (Crank.knob_angle + 12)%360
--      Crank.offset = (Crank.offset - 8)%Crank.maxval
      Crank.direction = 1
    end
end


--[[
┌─┐┌─┐┌┬┐   ┌─┐┬─┐┌─┐┌┐┌┬┌─   ┬  ┬┌─┐┬  ┌─┐┌─┐┬┌┬┐┬ ┬
│ ┬├┤  │    │  ├┬┘├─┤│││├┴┐   └┐┌┘├┤ │  │ ││  │ │ └┬┘
└─┘└─┘ ┴────└─┘┴└─┴ ┴┘└┘┴ ┴────└┘ └─┘┴─┘└─┘└─┘┴ ┴  ┴ 
]]
--[[
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
