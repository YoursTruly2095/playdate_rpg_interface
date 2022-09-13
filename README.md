# playdate_rpg_interface

A basic crank-centric menu template for Playdate console RPGs. 

Based on ConfidentFloor6601/playdate_rpg_interface

UPDATE! Now runs on an actual Playdate (and Playdate Simulator).

NOTE! If you just run the code you'll see the menu behaves a bit strangely.
This is because it is set up to test all the options below! In particular,
the twitchiness of the look icon will be resolved when you cast magic 
(among other things...)

Some configuration options are available 
1) Number of icons in the menu
2) Size of icons
3) Vertical location of the selection box
4) Angle through which to turn the crank to select next icon

Graphics loading is the responsibility of the caller. Check out main.lua
for an example of how to set this up easily.

Register icons with the menu using 
```
  RightCrankMenu.register_icon(icon)
```  
'icon' is a table with the following entries:
```
{
    name='talk',    
    fn=function(x) talk() end,  
    icon=<a-love-image>,
    disabled_icon=<another-love-image>,   --optional
    enabled=true,                         --optional
    after='look',                         --optional
    shift_ratio=2,                        --optional
},
```

'name' is a string (strictly speaking, anything, actually) that you use to refer to the icon in your program

'fn' is a function that gets called when RightCrankMenu.select() is called when this icon is active

'icon' is a love2d image that is displayed in the menu

'disabled_icon' is a love2d image that is displayed when the icon is disabled, defaults to nil

'enabled' determines whether the icon can be selected and which graphic is displayed, defaults to true

'after' is the name of the icon to insert this icon after in the menu. If not present the ison is inserted at the end

'shift_ratio' is the ratio of angle required to move past this icon, compared with normal

  
Other API functions are
```
  RightCrankMenu.remove_icon(name)            -- removes icon(s) with the given name
  RightCrankMenu.enable_icon(name)            -- enable the named icon
  RightCrankMenu.disable_icon(name)           -- disable the named icon
  RightCrankMenu.set_shift_ratio(name, ratio) -- set the shift ratio for the named icon
  
  RightCrankMenu.set_active(active)           -- active is true or false, controls whether the crank operates the menu
  RightCrankMenu.is_active()                  -- return true or false
  
  RightCrankMenu.get_active_icon()            -- returns the icon table for the icon currently under the selection box
  RightCrankMenu.select(args)                 -- calls 'fn' for the icon currently selected, passing 'args' to fn()
```  
You must also call
```
  RightCrankMenu.update(dt)
  RightCrankMenu.draw()
```
from their respective love2d functions
  

This version includes placeholder graphics so it runs OTB in the Playdate Simulator (or an actual Playdate).
You can use the graphics in your game if you want to. But you won't want to :-)


