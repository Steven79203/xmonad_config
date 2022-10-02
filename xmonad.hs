-- XMonad Configuration File 
-- Date of Creation - 04/06/2021 

-- Main
import XMonad

-- Date Types
import Data.Ratio
import Data.Char

-- Actions
import XMonad.Actions.CycleWS
import XMonad.Actions.CopyWindow
import qualified XMonad.Actions.FlexibleManipulate as Flex
import XMonad.Actions.FloatKeys

-- Hooks
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.WindowSwallowing

-- Utils
import XMonad.Util.EZConfig
import XMonad.Util.Ungrab
import XMonad.Util.SpawnOnce
import XMonad.Util.Image

-- Layouts
import XMonad.Layout
import XMonad.Layout.DecorationMadness
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import XMonad.Layout.Hidden
import qualified XMonad.Layout.Fullscreen as F
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.ResizableTile

import qualified XMonad.StackSet as W

import System.Exit

scripts :: String
scripts = "~/Scripts/x11"

myManageHook :: ManageHook
myManageHook = composeAll 
               [ className =? "mpv"      --> doRectFloat ( W.RationalRect (1 % 15) (1 % 15) (13 % 15) (13 % 15))
               , className =? "Ncmpcpp"  --> doRectFloat ( W.RationalRect (1 % 15) (1 % 15) (13 % 15) (13 % 15))
               , className =? "mpv"  --> doShift "4"
               , className =? "lf"   --> doShift "3" 
               , className =? "Gimp-2.99" --> doShift "5"
               , className =? "Code" --> doShift "6"
               , className =? "Ncmpcpp"     --> doShift "8"
               , className =? "firefox"     --> doShift "1"
               , className =? "Chromium"    --> doShift "1"
               , className =? "librewolf"   --> doShift "2"
               , className =? "Tor Browser" --> doShift "2"
               , className =? "qBittorrent" --> doShift "5"
               , className =? "Pavucontrol" --> doFloat
               , className =? "Blueman-manager"      --> doFloat
               , className =? "Nm-connection-editor" --> doFloat
               ]

-- Themes 
myTabConfig = def { fontName = "xft:monospace:style=Bold:pixelsize=12:antialias=true:hinting=true" 
				  , activeColor         = "#1F1F1F"
				  , inactiveColor       = "#1F1F1F"
				  , activeTextColor     = "#FFFFFF"
				  , inactiveTextColor   = "#505050"
				  , activeBorderColor   = "#FFFFFF"
				  , inactiveBorderColor = "#A0A0A0"
				  , activeBorderWidth   = 2
				  , inactiveBorderWidth = 2
				  , decoHeight          = 22
				   }

-- Layouts 
myLayout =  toggleLayouts 
                 (noBorders Full) $
            spacingRaw False 
                 (Border 0 sp sp sp) 
                 True 
                 (Border sp sp sp sp) 
                 True $  
            hiddenWindows $ avoidStruts $ 
            smartBorders  $ F.fullscreenFull 
            (rezTiled ||| Mirror rezTiled ||| tabbed shrinkText myTabConfig ||| Full)
        where
            -- Espaçamento do gaps em pixels
            sp       = 3
            -- Resizable Tiled
            rezTiled = ResizableTall nmaster delta ratio []
            -- Parâmetros gerais
            nmaster  = 1
            ratio    = 60/100
            delta    = 2/100

-- Autostart
myStartupHook = do
    spawn $ scripts ++ "/start_polybar"

-- Cor da borda em foco e fora de foco
myNormalBorderColor  = "#999999" 
myFocusedBorderColor = "#ff0a2f"

-- Terminal, modkey e espessura da borda
myTerminal    = "alacritty"
myModMask     = mod4Mask 
myBorderWidth = 2

-- Função principal
main :: IO()
main = xmonad $ docks $ ewmhFullscreen . ewmh $ myConfig
myConfig = def 
   {
   ------------------ Paramethers -----------------------
	  terminal                  = myTerminal
--  , focusFollowsMouse         = myFocusFollowMouse
    , modMask                   = myModMask
    , borderWidth               = myBorderWidth
--  , workspaces                = myWorkspaces
    , XMonad.normalBorderColor  = myNormalBorderColor
    , XMonad.focusedBorderColor = myFocusedBorderColor
    
   ------------------ Key Bindings ----------------------
--  , keys                 = myKeys
--  , mouseBindings        = myMouseBindings
    
    ----------------- Hooks, Layouts --------------------
    , layoutHook             = myLayout

    , manageHook             = manageHook def         <+> 
                               F.fullscreenManageHook <+> 
                               myManageHook 

    , handleEventHook        = handleEventHook def    <+> 
    						   F.fullscreenEventHook  <+> 
                               swallowEventHook 
                            	  (className =? "Alacritty") 
                            	  (return True)
--  , logHook                = dynamicLogWithPP $ myPP
    , startupHook            = myStartupHook
    }
    `additionalKeysP` 
    [ ("M-<Return>", spawn myTerminal)
	
	-- Focus Window
    , ("M-<Left>"  , windows W.focusUp)
    , ("M-<Right>" , windows W.focusDown)

	-- Shring or Expand Individual Windows
	,("M-i", sendMessage MirrorShrink)
	,("M-o", sendMessage MirrorExpand)

	-- Move windows in the stack
    , ("M-S-<Left>"  , windows W.swapUp)
    , ("M-S-<Right>" , windows W.swapDown)
    , ("M-a"         , windows W.swapMaster)

	-- Restart XMonad 
	, ("M-S-r", spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi")

    -- Kill Window
    , ("M-S-q", kill)

	-- Volume/Brightness Up/Down/Mute
	,("<XF86MonBrightnessUp>"   , spawn "polybar-msg action '#backlight-acpi.inc'" )
	,("<XF86MonBrightnessDown>" , spawn "polybar-msg action '#backlight-acpi.dec'" )
	,("<XF86AudioRaiseVolume>"  , spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%" )
	,("<XF86AudioLowerVolume>"  , spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%" )
	,("<XF86AudioMute>"         , spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")

	-- Sticky Windows
	,("M-g"   , windows copyToAll)
	,("M-S-g" , killAllOtherCopies)

	-- Cycle/Shift between WS
	,("M-C-<Left>"    , moveTo Prev $ Not emptyWS)
	,("M-C-<Right>"   , moveTo Next $ Not emptyWS)
	,("M-S-C-<Left>"  , shiftToPrev >> prevWS)
	,("M-S-C-<Right>" , shiftToNext >> nextWS)
	
	-- Cycle/Shift Between WS (alternative)
	,("M-C-k"  , moveTo Prev $ Not emptyWS)
	,("M-C-j"  , moveTo Next $ Not emptyWS)
	,("M-S-C-j", shiftToPrev >> prevWS)
	,("M-S-C-k", shiftToNext >> nextWS)
	
	-- Hidden or Reveal Windows
	,("M-S--", withFocused hideWindow)
	,("M-S-=", popNewestHiddenWindow)

	-- Fullscreen
	,("M-f",     sendMessage ToggleLayout)

	-- Custom Scripts 
	,("M-S-C-w" , spawn $ scripts ++ "/../get_dw_url"  )  -- Get URLs
	,("M-S-C-c" , spawn $ scripts ++ "/../set_dw_url"  )  -- Set new URLS
	,("M-y"     , spawn $ scripts ++ "/xmonad-keybinds")  -- List XMonad Keybinds
	,("M-S-n"   , spawn $ scripts ++ "/edit_config"    )  -- Edit configuration files
	,("M-S-x"   , spawn $ scripts ++ "/rotate"         )  -- Rotate screen
	,("M-S-z"   , spawn $ scripts ++ "/setresolution"  )  -- Set screen resolution
	,("M-S-l"   , spawn $ scripts ++ "/toggle-rshf"    )  -- Toggle Redshift
	,("M-S-p"   , spawn $ scripts ++ "/shutdown"       )  -- Shutdown Prompt 
	,("M-b"     , spawn $ scripts ++ "/i3lock"         )  -- i3lock wrapper
	,("M-S-u"   , spawn $ scripts ++ "/urltompv"       )  -- Download or Play video on MPV
	,("M-c"     , spawn $ scripts ++ "/../clicker"     )  -- Clicker

	-- System commands
	,("<Print>" , spawn "gnome-screenshot --interactive"                    )
    ,("M-d"     , spawn "rofi -cache-dir /tmp/rofi -show drun -show-icons"  )
    ,("M-<Tab>" , spawn "rofi -cache-dir /tmp/rofi -show window -show-icons")
    ,("M-m"     , spawn "alacritty --title 'Ncmpcpp' --class 'Ncmpcpp' -e ncmpcpp")
	,("M-r"     , spawn "alacritty --title 'FileManager' --class 'lf' -e lfub; rm -r /tmp/lf")
    ]
    `additionalMouseBindings`
    [ -- Flex Resize/Movimentation
      ((mod4Mask, button3), (\w -> focus w >> Flex.mouseWindow Flex.resize w))
    ]
    `removeKeys`
    [
    (mod4Mask,xK_q)
    ,(mod4Mask,xK_c)]
