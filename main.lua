
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

-- a string to display a message when a menu item is selected
local menu_message = ""

-- an image which represents the rest of your game
local rest_of_game


--[[ 
    Menu Definition
    
    This is an array of menu items definitions that will appear in the menu
    
    These get registered with the menu one at a time, you don;t need to 
    structure them in an array like this if a different structure is more
    convenient.
    
    Each entry has:
    
    name: a string which is used to refer to the entry. Multiple entries
          can have the same name, and will all then have the same properties.
          
    fn: a callback function which is called when the play selects the menu
        entry. 
        
    icon: the playdate.graphics.image object to display in the menu for this 
          entry. In the table below, this is set to the filename for the
          image, which is then replaced with the actual image in myload()
          (see below).
          
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
--]]

local menu_options = 
{
    {
        name='look',
        fn=function(x) look() end,   
        icon="menu_graphics/look_t.png",
        shift_ratio = 0.2,                  
    },
    {
        name='talk',    
        fn=function(x) talk() end,  
        icon="menu_graphics/talk_t.png",
        disabled_icon="menu_graphics/talk_d.png",
        enabled = false,
    },
    {
        name='magic',       
        fn=function(x) magic() end,      
        icon="menu_graphics/magic_t.png",
    },
    {
        name='items',        
        fn=function(x) print_message("You rifle through your belongings") end,       
        icon="menu_graphics/items_t.png",
    },
    {
        name='gear',        
        fn=function(x) equipment() end,      
        icon="menu_graphics/gear_t.png",
    },
    {
        name='options',       
        fn=function(x) print_message("You access a meta-physical menu in another world") end,     
        icon="menu_graphics/settings_t.png",
    },
    {
        name='game',       
        fn=function(x) print_message("Monika already got your files") end,   
        icon="menu_graphics/game_t.png",
    },
}
    
-- this option won't be in the menu at startup, but gets added dynamically later
local fight_option = 
{
    name='fight',   
    fn=function(x) print_message("You attack! Viciously!!") end, 
    icon="menu_graphics/fight_t.png",
}


--[[

Callback functions for various menu options

Each one sets a message to be printed, and also tinkers with the
menu, just to show how it can be altered during your game.

look() and talk() show how an option which is already in the
menu can be enabled and disabled.

magic() shows how a new menu option can be added to the menu,
including how to control where in the menu it appears. magic()
also shows how to tinker with the shift ratio of an item in 
menu at runtime.

equipment() shows how to remove an item from the menu.

--]]
function look()
    print_message("You looked, so now you can talk") 
    RCM.enable_icon("talk")
end

function talk()
    print_message("You talk, so now you must look") 
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


-- a function that loads the graphics for the menu
function load_game()
    
    -- load the menu icons
    -- this replaces the file names in the data structure in the code, with the actual loaded icons
    for index,value in ipairs(menu_options) do
        value['icon']=playdate.graphics.image.new(value['icon'])
        if value['disabled_icon'] then
            value['disabled_icon']=playdate.graphics.image.new(value['disabled_icon'])
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
        print("Registering "..value.name)
        RCM.register_icon(value)             
    end
    
    -- load the rest of your game
    rest_of_game = playdate.graphics.image.new("menu_graphics/background.png")
    
end

-- actuall call the load function
load_game()

--[[

playdate.update() 

This is the callback which the playdate will call every frame (default 30 times 
a second). Unlike Love2d, there is no separate 'draw()' callback, so you need
to do the drawing in your update function also. RightCrankMenu requires that
playdate.graphics.clear() is called each frame (I guess any animation using
images does).

TODO: try out Playdate sprites, and see if the menu can work without clearing
      each frame if sprites are used.
      
If you are structuring your code with separate update() and draw() functions
(as per Love2d), then you can separate out the RightCrankMenu update and draw
just by commenting out one line in RightCrankMenu.lua. Right at the bottom of
RightCrankMenu.update() is a call to RightCrankMenu.draw(), remove that if 
you would prefer to call them separately.
--]]
function playdate.update()
    
    -- playdate update is locked to framerate
    local dt = 1/30
    
    playdate.graphics.clear()
    update_rest_of_game(dt)
    RCM.update(dt)
    
end


-- do all your game stuff outside of the RightCrankMenu
-- in this example, we just draw a background and some
-- text
function update_rest_of_game(dt)
  
  -- draw an image which represents the rest of the game
  -- this is currently just a gray background 
  playdate.graphics.image.draw(rest_of_game,0,0)
  
  -- print the icon name currently under the selector
  local icon_data = RCM.get_active_icon()
  playdate.graphics.drawText(icon_data['name'],5,185)
  
    -- print the message from the menu
  playdate.graphics.drawText(menu_message,5,205)
  
end

-- Set the menu text that which will be printed each frame.
-- We can't just print here, because we need to print every
-- frame, because we are clearing and redrawing the screen
-- every frame.
function print_message(message)
  
  menu_message=message

end


--[[

Handle Playdate UI

In this example, the menu item is selected on release of the A
button. You might want it on press, or on hold, or on a different
button, or even just on the crank stopping rotating, or whatever.

--]]

function playdate.AButtonUp()    
    if RCM.is_active() then
        RCM.select()
    end
end

function playdate.leftButtonDown()
    if RCM.is_hidden() then
        RCM.show('no_activate')
    end
end

function playdate.rightButtonDown()
    if not RCM.is_hidden() then
        RCM.hide('no_deactivate')
    end
end

function playdate.BButtonUp()    
    if RCM.is_active() then
        RCM.set_active(false)
    else
        RCM.set_active(true)
    end  
end



