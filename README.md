# playdate_rpg_interface

A basic crank-centric menu template for Playdate console RPGs. 

Based on ConfidentFloor6601/playdate_rpg_interface

UPDATE! Now runs on an actual Playdate (and Playdate Simulator).

NOTE! If you just run the code you'll see the menu behaves a bit strangely.
This is because it is set up to test all the options below. In particular,
the twitchiness of the magic icon will be reduced as you repeatedly cast
magic.

Some configuration options are available 
1) Size of icons
2) Vertical location of the selection box
3) Angle through which to turn the crank to select next icon

Graphics loading is the responsibility of the caller. Check out main.lua
for an example of how to set this up easily.

Add icons with the menu using 
```
  RightCrankMenu.add_icon(icon, after)
```  
'icon' is a table with the following entries:
```
{
    name='talk',    
    fn=function(x) talk() end,  
    icon=<a-playdate-image>,
    disabled_icon=<another-playdate-image>, --optional
    enabled=true,                           --optional
    shift_ratio=2,                          --optional
},
```

'name' is a string (strictly speaking, anything, actually) that you use to refer to the icon in your program

'fn' is a function that gets called when RightCrankMenu.select() is called when this icon is active

'icon' is a love2d image that is displayed in the menu

'disabled_icon' is a love2d image that is displayed when the icon is disabled, defaults to nil

'enabled' determines whether the icon can be selected and which graphic is displayed, defaults to true

'shift_ratio' is the ratio of angle required to move past this icon, compared with normal

'after' is an argument with the name of the icon after which to insert the new icon. This can be left
        null to insert the new icon at the end of the menu.
  
Other API functions are
```
  RightCrankMenu.remove_icon(name)            -- removes icon(s) with the given name
  
  RightCrankMenu.enable_icon(name)            -- enable the named icon
  RightCrankMenu.disable_icon(name)           -- disable the named icon
  
  RightCrankMenu.set_shift_ratio(name, ratio) -- set the shift ratio for the named icon
  RightCrankMenu.get_shift_ratio(name)        -- get the shift ratio for the named icon
  
  RightCrankMenu.set_active(active)           -- active is true or false, controls whether the crank operates the menu
  RightCrankMenu.is_active()                  -- return true or false
  
  RightCrankMenu.get_active_icon()            -- returns the icon table for the icon currently under the selection box
  RightCrankMenu.select(args)                 -- calls 'fn' for the icon currently selected, passing 'args' to fn()
```  
You must also call
```
  RightCrankMenu.update(dt)
```
from playdate.update(). Note that unlike love2d, playdate.update() isn't called with a dt (delta time) from the system,
but in order to animate the hide/show of the menu, RightCrankMenu.update(dt) needs a dt. You can leave this null, and 
RightCrankMenu will assume the playdate default framerate of 30fps. Or you can pass a value if you have adjusted the
framerate.

This version includes placeholder graphics so it runs OTB in the Playdate Simulator (or an actual Playdate).
You can use the graphics in your game if you want to. But you won't want to :-)


