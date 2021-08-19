


local Crank = require("crank")

local RightCrankMenu = {}

-- Titles for the icons selected with the Right Crank Menu (RCM)
RightCrankMenu.menu_titles = 
{{"Look",       "look.png"},
  {"Talk",      "talk.png"},
  {"Fight",     "fight.png"},
  {"Magic",     "magic.png"},
  {"Gear",      "equipment.png"},
  {"Inventory", "items.png"},
  {"Quest Log", "quests.png"},
  {"Game Files","files.png"},
  {"Settings",  "settings.png"}}

-- The number of icons in the menu may get larger later, I dunno
--menu_length = table.maxn(menu_titles)


-- the click wheel menu is active by default
RightCrankMenu.active = true
RightCrankMenu.current_icon = RightCrankMenu.menu_titles[1][1]


-- Set the initial icon to number 0 (Look)
RightCrankMenu.offset = 0

-- max value should be height of icon x number of icons
RightCrankMenu.maxval = 60 * #RightCrankMenu.menu_titles

RightCrankMenu.full_rotation_angle = #RightCrankMenu.menu_titles * 12 * 5  -- 5 steps per icon, 8 degrees per step
RightCrankMenu.crank_angle = 0
RightCrankMenu.angle = 0

function RightCrankMenu.load()
    for index,value in ipairs(RightCrankMenu.menu_titles) do
        RightCrankMenu.menu_titles[index][3] = love.graphics.newImage(RightCrankMenu.menu_titles[index][2])
    end
end

function RightCrankMenu.draw()
    -- Crank-selected Menu Main Box Outline
    love.graphics.rectangle("line",2,2,116,236)

    -- Right Crank Menu Box Outlines and Icons
    for index,value in ipairs(RightCrankMenu.menu_titles) do
        RightCrankMenu.draw_icon(RightCrankMenu.menu_titles[index][3],index-1)
    end

    -- Hacky "active icon" selector box here
    if RightCrankMenu.active then
        love.graphics.rectangle("line",360,100,40,40)
        love.graphics.rectangle("line",361,101,39,39)
    end
end

--[[
┌┬┐┬─┐┌─┐┬ ┬    ┬┌─┐┌─┐┌┐┌
 ││├┬┘├─┤│││    ││  │ ││││
─┴┘┴└─┴ ┴└┴┘────┴└─┘└─┘┘└┘
    draw_icon does just that: draws a single icon to the right crank menu.
    There's no reason this shouldn't just iterate through the table of 
    icons, though; I'll change that in the next revision.
]]
function RightCrankMenu.draw_icon(icon, order)
  --[[
  crank_offset ranges between 0 and 239 (really 232), but we add 2
  to that to give the icons a buffer from the top, and add another
  100 to shift our first icon into the centered selection box.
  
    ONLY UPDATES WHEN RCM IS IN FOCUS!
  ]]
  
  -- calculate the offset from the crank angle
  local offset = Crank.get_angle() * (-2/3)
  
  --offset = RightCrankMenu.angle * (-2/3)
  offset = -RightCrankMenu.angle

  local y = ((order*60)+offset+102)%RightCrankMenu.maxval
  local x = 362+((100-y)^2)/1000
  
  if (y >= RightCrankMenu.maxval-40) then
    -- x2 is a temporary variable to keep the icons on the curve
    -- the the top and bottom of the screen
    x2 = 362+((100-(y-RightCrankMenu.maxval))^2)/1000
    love.graphics.rectangle("line",x2,y-RightCrankMenu.maxval,36,36)
    love.graphics.draw(icon,x2+1,y-RightCrankMenu.maxval)
  end

  love.graphics.rectangle("line",x,y%RightCrankMenu.maxval,36,36)
  love.graphics.draw(icon,x+1,y%RightCrankMenu.maxval)
  
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
        
        RightCrankMenu.angle = (RightCrankMenu.angle + angle_delta) % RightCrankMenu.full_rotation_angle
        if angle_delta ~= 0 then
            debug_delta = angle_delta
        end
        
    end        
end

function RightCrankMenu.debug_print()
    love.graphics.print({{255,0,0,255},"RCM angle: ",{255,0,0,255},RightCrankMenu.angle},125,25)
    love.graphics.print({{255,0,0,255},"FRA: ",{255,0,0,255},RightCrankMenu.full_rotation_angle},125,50)
    love.graphics.print({{255,0,0,255},"delta: ",{255,0,0,255},debug_delta },125,75)
end

function RightCrankMenu.get_active_icon()
  
  -- calculate the offset from the crank angle
  local offset = Crank.get_angle() * (-2/3)
    
  --offset = RightCrankMenu.angle * (-2/3) 
  offset = -RightCrankMenu.angle
    
  local icon_selection = ((RightCrankMenu.maxval - offset)/60) % #RightCrankMenu.menu_titles
  
  if icon_selection%1 == 0 then
    RightCrankMenu.current_icon = RightCrankMenu.menu_titles[icon_selection+1]
  end
  
  return RightCrankMenu.current_icon
end

return RightCrankMenu
