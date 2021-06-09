-- XMonad Configuration File 
-- Date of Creation - 04/06/2021 

-- Main
import XMonad

-- Date Types
import Data.Ratio

-- Prompt 
import XMonad.Prompt
import XMonad.Prompt.ConfirmPrompt

import XMonad.Config.Desktop

-- Actions
import XMonad.Actions.CycleWS
import XMonad.Actions.CopyWindow
import qualified XMonad.Actions.FlexibleManipulate as Flex

-- Hooks
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers

-- Utils
import XMonad.Util.EZConfig
import XMonad.Util.Ungrab
import XMonad.Util.SpawnOnce

-- Layouts
import XMonad.Layout
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import XMonad.Layout.Grid
import XMonad.Layout.Hidden
import XMonad.Layout.Magnifier
import qualified XMonad.Layout.Fullscreen as F
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.CenteredMaster

import qualified XMonad.StackSet as W

import System.Exit


myManageHook :: ManageHook
myManageHook = composeAll 
               [ className =? "mpv" --> doRectFloat ( W.RationalRect (1 % 8) (1 % 8) (6 % 8) (6 % 8))
               , className =? "Thunar" --> doShift "3" 
               , className =? "Pavucontrol" --> doFloat
               , className =? "Blueman-manager" --> doFloat ]

-- Layouts 
            -- Toggle to Fullscreen
myLayout =  toggleLayouts (noBorders Full) $

 			-- Gaps
            spacingRaw False (Border 0 sp sp sp) 
            True (Border sp sp sp sp) True $ 
            
            -- Misc
            hiddenWindows $ avoidStruts $ 
            smartBorders $ F.fullscreenFull
           
            -- Main Layouts
            (tiled ||| Grid ||| Mirror tiled ||| Full)
		where
			-- Espaçamento do gaps em pixels
			sp      = 4
			-- Tiling Layout 
			tiled   = Tall nmaster delta ratio
			-- Parâmetros gerais
			nmaster = 1
			ratio   = 2/3
			delta   = 2/100

-- Rotina de autoinicialização
myStartupHook = do
    spawnOnce "xsetroot -cursor_name left_ptr"
    spawnOnce "~/scripts/autostart"
--  spawn     "~/scripts/start/polybar"

-- Cor da borda em foco e fora de foco
myNormalBorderColor  = "#333333"
myFocusedBorderColor = "#6E6290"

-- Variáveis básicas
myTerminal    = "alacritty"
myModMask     = mod4Mask 
myBorderWidth = 2

myBar = "xmobar"
myPP = xmobarPP {ppCurrent = xmobarColor "#FF73EC" "" . wrap "|" "|"
				,ppTitle   = xmobarColor "#FF73EC" "" . shorten 60}

toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_c)

-- Função principal
main :: IO()
main = do
	xmonad . docks . ewmh . F.fullscreenSupport =<< statusBar myBar myPP toggleStrutsKey myConfig

myConfig = def 
	{
   ------------------ Paramethers -----------------------
	  terminal                  = myTerminal
   -- , focusFollowsMouse       = myFocusFollowMouse
    , modMask                   = myModMask
    , borderWidth               = myBorderWidth
   -- , workspaces              = myWorkspaces
    , XMonad.normalBorderColor  = myNormalBorderColor
    , XMonad.focusedBorderColor = myFocusedBorderColor
    
   ------------------ Key Bindings ----------------------
   -- , keys                 = myKeys
   -- , mouseBindings        = myMouseBindings
    
    ----------------- Hooks, Layouts --------------------
    , layoutHook             = myLayout
    , manageHook             = manageHook def <+> 
                               F.fullscreenManageHook <+> 
                               myManageHook 
    , handleEventHook        = handleEventHook def <+> 
                               F.fullscreenEventHook  <+> 
                               ewmhDesktopsEventHook
    , logHook                = dynamicLogWithPP $ myPP
    , startupHook            = myStartupHook
    }
    `additionalKeysP` 
    [ ("M-<Return>", spawn myTerminal)

    -- Mover o foco entre as janela
    , ("M-<Left>"  , windows W.focusUp)
    , ("M-<Right>" , windows W.focusDown)

    -- Mover as janelas na stack
    , ("M-S-<Left>"  , windows W.swapUp)
    , ("M-S-<Right>" , windows W.swapDown)
    , ("M-a"         , windows W.swapMaster)

    -- Sair do XMonad
    , ("M-S-e", confirmPrompt defaultXPConfig "exit" $ io exitSuccess)
    , ("M-S-r", spawn "if type xmonad; then pkill xmobar; xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi")
    , ("M-S-q", kill)

	-- Desligar/Reiniciar/Sair
	, ("M-S-k", spawn "~/scripts/shutdown" )
	-- Bloquear a tela
	, ("M-b", spawn "~/scripts/i3lock")

    -- Dmenu/Rofi
    , ("M-d", spawn "rofi -show drun -show-icons")

	-- Volume/Brightness
	,("<XF86MonBrightnessUp>"   , spawn "xbacklight -inc 5" )
	,("<XF86MonBrightnessDown>" , spawn "xbacklight -dec 5" )
	,("<XF86AudioRaiseVolume>"  , spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%")
	,("<XF86AudioLowerVolume>"  , spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%")

	-- Sticky Windows
	,("M-g", windows copyToAll)
	,("M-S-g", killAllOtherCopies)

	-- Cycle/Shift Through the WS
	,("M-C-<Left>"  , prevWS)
	,("M-C-<Right>" , nextWS )
	,("M-S-C-<Left>", shiftToPrev >> prevWS)
	,("M-S-C-<Right>", shiftToNext >> nextWS)

	-- Firefox
	,("M-S-n", spawn "firefox")
	,("M-S-m", spawn "firefox --private-window")
	
	-- Editor
	,("M-v", spawn "alacritty -e nvim")

	-- Thunar
	,("M-S-t", spawn "pcmanfm")

	-- Rotate Screen
	,("M-S-x", spawn "~/scripts/rotate")

	-- Resolution
	,("M-S-z", spawn "~/scripts/setresolution")

	-- Toggle Redshift
	,("M-S-l", spawn "~/scripts/toggle-rshf")
	
	-- PrintScreen
	,("<Print>", spawn "gnome-screenshot --interactive")
    
	-- Hide/Show Windows
	,("M-S--", withFocused hideWindow)
	,("M-S-=", popOldestHiddenWindow)

	-- Toggle Fullscreen Layout
	,("M-S-f", sendMessage ToggleLayout)
    ]
    `additionalMouseBindings`
    [ -- Flex Resize/Movimentation
      ((mod4Mask, button3), (\w -> focus w >> Flex.mouseWindow Flex.resize w))
    ]
