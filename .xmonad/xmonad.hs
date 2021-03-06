-- xmonad config used by Vic Fryzel
-- Author: Vic Fryzel
-- http://github.com/vicfryzel/xmonad-config

module Main (main) where

import Control.Monad (liftM2)
import System.IO
import System.Exit
import XMonad
import XMonad.Actions.CopyWindow --check
import XMonad.Actions.CycleWS --check
import XMonad.Actions.UpdatePointer
import XMonad.Actions.Warp
import XMonad.Config.Desktop
import Graphics.X11.ExtraTypes.XF86
import XMonad.Hooks.DynamicLog --check
import XMonad.Hooks.EwmhDesktops --check
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers --check
import XMonad.Hooks.Script
import XMonad.Hooks.SetWMName
import XMonad.Layout.BinarySpacePartition (emptyBSP)
import XMonad.Layout.Fullscreen --check
import XMonad.Layout.NoBorders --check
import XMonad.Layout.ResizableTile (ResizableTall(..))
import XMonad.Layout.Spiral --check
import XMonad.Layout.Tabbed --check
import XMonad.Layout.ThreeColumns --check
import XMonad.Layout.ToggleLayouts (ToggleLayout(..), toggleLayouts)
import XMonad.Layout.Spacing --check
import XMonad.Prompt
import XMonad.Prompt.ConfirmPrompt
import XMonad.Prompt.RunOrRaise
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import qualified XMonad.StackSet as W
import qualified Data.Map        as M


-- Terminal
myTerminal = "gnome-terminal"


scratchpads = [
	NS "term" "gnome-terminal --role irc -- weechat" (role =? "irc") (customFloating $ W.RationalRect (1/12) (1/12) (5/6) (5/6)),
	NS "irc" "xfce4-terminal --role=irc" (role =? "irc") (customFloating $ W.RationalRect (1/12) (1/12) (5/6) (5/6)),
	NS "applaunch" "xfce4-appfinder -c" (title =? "Application Finder") defaultFloating ,
	NS "notes" "gvim --role notes ~/Dropbox/notes/notes.otl" (role =? "notes") (customFloating $ W.RationalRect (0) (1/20) (2/4) (9/10))]
		where role = stringProperty "WM_WINDOW_ROLE"

myXPConfig = def
  { position          = Top
  , alwaysHighlight   = True
  , promptBorderWidth = 0
  , font              = "xft:monospace:size=9"
  }

------------------------------------------------------------------------
-- Workspaces
-- The default number of workspaces (virtual screens) and their names.
--
-- workspaceNames = ["!","@", "#", "$", "%", "^", "&", "*","(", "β", "Δ", "Π", "Ω"]
workspaceNames = ["&","[", "{", "}", "(", "=", "*", ")","+", "]", "!", "β", "Π", "Δ",  "Ω", "λ", "√", "Γ"]
myWorkspaces = [ format x a | (x,a) <- zip [1..] workspaceNames]
		where super a 
			| a < 10 = "super+" ++ show a
			| a == 10 = "super+" ++ show "m"
			| a == 11 = "super+" ++ show "w"
			| a == 12 = "super+" ++ show "v"
			| a == 13 = "super+" ++ show "z"
			| otherwise = ""
		      format x a = a
------------------------------------------------------------------------
-- Window rules
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    ([ 
    -- className =? "Chromium"       --> doShift (browser)
    className =? "Dwb"  	    --> doShift (browser)
    , resource  =? "desktop_window" --> doIgnore
    -- , className =? "Vlc"     	    --> doShift (media)
    -- , className =? "Vlc"     	    --> viewShift (media)
    -- , className =? "MPlayer"        --> doShift (media)
    -- , className =? "mpv"     	    --> doShift (media)
    -- , className =? "mpv"     	    --> viewShift (media)
    -- , className =? "MPlayer"        --> viewShift (media)
    -- , className =? "MPlayer"        --> doFloat
    , className =? "Deluge"        --> doShift (myWorkspaces!!4)
    -- , resource  =? "gpicview"       --> doFloat
    , className =? "Vlc"            --> doFloat
    , className =? "mpv"            --> doFloat
    , className =? "Xfce4-appfinder"--> doFloat
    , className =? "VirtualBox"     --> doShift (myWorkspaces!!7)
    , className =? "Thunderbird"     --> doShift (myWorkspaces!!6)
    , className =? "Gnucash"     --> doShift (myWorkspaces!!5)
    , className =? "Thunar"     --> doShift (files)
    , className =? "ROX-Filer"     --> doShift (files)
    , className =? "ROX-Filer"     --> viewShift (files)
    , className =? "MuPDF"     --> doShift (pdfview)
    , className =? "MuPDF"     --> viewShift (pdfview)
    , className =? "Xchat"          --> doShift "5:media"
    , className =? "stalonetray"    --> doIgnore
    , className =? "trayer"    --> doIgnore
    , className =? "Orage"    --> doFloat
    , className =? "copyq"    --> doFloat
    , className =? "Xfce4-notifyd" --> doF W.focusDown <+> doF copyToAll
    , stringProperty "WM_NAME" =? "File Operation Progress" --> doFloat
    , stringProperty "WM_NAME" =? "LastPass Site Search" --> doFloat
    , isFullscreen --> (doF W.focusDown <+> doFullFloat)]) 
	where
	  viewShift = doF . liftM2 (.) W.greedyView W.shift
	  browser = myWorkspaces!!1
	  pdfview = myWorkspaces!!2
	  media = myWorkspaces!!12
	  files = myWorkspaces!!9


------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
-- myLayout = avoidStruts
    -- myTiled |||
    -- Tall 1 (3/100) (3/10) |||
    -- Tall 1 (100/100) (1/2) |||
    -- Mirror (Tall 1 (3/100) (1/2)) |||
    -- noBorders (fullscreenFull Full)

-- myTiled = Tall 1 (3/100) (3/5) -- (6/7)
myLayout = toggleLayouts (noBorders Full) others
  where
    others = avoidStruts $ ResizableTall 1 (1.5/100) (3/5) [] ||| (avoidStruts $ emptyBSP)

------------------------------------------------------------------------
-- Colors and borders
-- Currently based on the ir_black theme.
--
myNormalBorderColor  = "#141314"
myFocusedBorderColor = "#ccc2a6"

-- Colors for text and backgrounds of each tab when in "Tabbed" layout.
tabConfig = defaultTheme {
    activeBorderColor = "#7C7C7C",
    activeTextColor = "#CEFFAC",
    activeColor = "#000000",
    inactiveBorderColor = "#7C7C7C",
    inactiveTextColor = "#EEEEEE",
    inactiveColor = "#000000"
}

-- Color of current window title in xmobar.
xmobarTitleColor = "#8e8774"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#CEFFAC"

-- Width of the window border in pixels.
myBorderWidth = 1


------------------------------------------------------------------------
-- Key bindings
--
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
  ----------------------------------------------------------------------
  -- Custom key bindings
  --

  -- Start a terminal.  Terminal to start is specified by myTerminal variable.
  [ ((modm .|. shiftMask, xK_Return),	 spawn $ XMonad.terminal conf)

  -- Lock the screen using xscreensaver.
  , ((modm .|. controlMask, xK_l), spawn "xautolock -locknow")

  -- Launch dmenu via yeganesh.
  -- Use this to launch programs without a key binding.
  -- , ((modm, xK_p),
     -- spawn "dmenu-with-yeganesh")
  , ((modm, xK_g), windows copyToAll) -- make focused window visible on all workspaces
  , ((modm .|. shiftMask, xK_g), killAllOtherCopies) -- make focused window only visible on current workspace

  -- Take a screenshot in select mode.
  -- After pressing this key binding, click a window, or draw a rectangle with
  -- the mouse.
  , ((modm , xK_quoteright), spawn "mpc next")

  -- Take full screenshot in multi-head mode.
  -- That is, take a screenshot of everything you see.
  , ((modm .|. controlMask .|. shiftMask, xK_p), spawn "screenshot")

  -- Play/Pause mpd
  -- , ((modm , xK_a), spawn "mpc toggle")

  , ((0 , xK_F1), namedScratchpadAction scratchpads "term")

  -- , ((0 , xK_F2), scratchPad)

  , ((controlMask , xK_dollar), namedScratchpadAction scratchpads "irc")

  -- , ((0 , xK_F4), namedScratchpadAction scratchpads "notes")

  -- , ((modm , xK_semicolon), warpToWindow (1/2) (1/2))

  -- Eject CD tray.
  , ((0, 0x1008FF2C), spawn "eject -T")
  --------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  --

  -- Close focused window.
  , ((modm .|. shiftMask, xK_c), kill1)
 
  -- launch xkill
  , ((modm .|. shiftMask, xK_x     ), spawn "xkill")

  -- Cycle through the available layout algorithms.
  , ((modm, xK_space), sendMessage NextLayout)

  --  Reset the layouts on the current workspace to default.
  , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

  -- Resize viewed windows to the correct size.
  -- , ((modm, xK_n), refresh)

  -- Move focus to the next window.
  , ((modm, xK_Tab), windows W.focusDown)

  -- Move focus to the previous window.
  , ((modm, xK_h), windows W.focusUp  )
  
  -- Move focus to the next window.
  , ((modm, xK_t), windows W.focusDown)

  -- Move focus to the master window.
  , ((modm, xK_m), windows W.focusMaster  )

  -- Swap the focused window and the master window.
  , ((modm, xK_Return), windows W.swapMaster)

  -- Swap the focused window with the next window.
  , ((modm .|. shiftMask, xK_t), windows W.swapDown  )

  -- Swap the focused window with the previous window.
  , ((modm .|. shiftMask, xK_h), windows W.swapUp    )

  -- Shrink the master area.
  , ((modm, xK_d), sendMessage Shrink)

  -- Expand the master area.
  , ((modm, xK_n), sendMessage Expand)

  -- Push window back into tiling.
  , ((modm .|. shiftMask, xK_r), withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((modm, xK_comma), sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((modm, xK_period), sendMessage (IncMasterN (-1)))

  -- Open Dmenu
  , ((modm, xK_p), spawn "rofi -combi-modi window,drun,run -show combi -modi combi")

  -- , ((modm .|. shiftMask, xK_q), io (exitWith ExitSuccess)) -- Quit xmonad.
  , ((modm .|. shiftMask, xK_q), confirmPrompt myXPConfig "exit" (io exitSuccess)) -- Quit xmonad.

  -- Restart xmonad.
  , ((modm, xK_q), restart "xmonad" True)

  -- , ((modm , xK_a), sendMessage ToggleStruts)
  , ((modm, xK_a), sendMessage (Toggle "Full"))
  ]
  ++

  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  -- & [ {  } ( = *  ) +  ] !
  [((m .|. isMod k, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) ([xK_1..xK_9] ++ [xK_b, xK_m, xK_w , xK_v, xK_z, xK_F7, xK_F8])
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
  ++
  [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_apostrophe, xK_l] [0..]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
	where
	  isMod a | a `elem` [xK_F7, xK_F8] =  0 
	          | otherwise = modm



------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modm, button1), (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w))

    -- left scroll to kill the program the mouse is over
    , ((0, 11), (\w -> focus w >> kill))

    -- middle click to raise stack
    , ((modm, button2), (\w -> focus w >> mouseResizeWindow w
                                            >> windows W.shiftMaster))
    
  ]


------------------------------------------------------------------------
-- Status bars and logging
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--


------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
--TODO get startup hook working
myStartupHook = spawn "bash /home/hamhut/bin/startup"
-- stop pointer being moved on certain windows
pointerIgnore = [ className =? "Xfce4-notifyd" 
    , stringProperty "WM_NAME" =? "File Operation Progress"
    ]
-- myUpdatePointer = updatePointer (Relative 0.95 0.95)
-- myTrayer = "trayer --edge top --height 14.5 --width 8 --align right --transparent true --alpha 0 --tint '0x141314' --monitor 1"

------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--
main = do
  -- conf <- dzen defaultConfig
  -- status <- spawnPipe "killall conky; conky -c ~/.xmonad/menu_conky.conf | dzen2 -ta r -fn 'Terminus:size=8' -h 12 -x 700 -e 'button1=menuexec'; killall conky"
  -- xmproc <- spawnPipe "dzen2 -ta l -fn 'Terminus:size=8' -h 12 -e 'button1=menuexec'"  -- "xmobar ~/.xmonad/xmobar.hs"
  xmproc <- spawnPipe "xmobar --dock ~/.xmonad/xmobar.hs"
  -- trayer <- spawnPipe myTrayer
  xmonad $ ewmh defaults {
      logHook = myLogHook xmproc -- >> myUpdatePointer -- <+>
                -- myLogHook status
      , manageHook = manageDocks <+> myManageHook <+> namedScratchpadManageHook scratchpads
      , startupHook = setWMName "LG3D" -- <+> spawn myTrayer
  }

-- myLogHook' xmproc = dynamicLogWithPP $ defaultPP { ppOutput = hPutStrLn xmproc }

myLogHook xmproc = do
    copies <- wsContainingCopies
    -- add checking to see if any other windows are on the workspace TODO
    let check ws | ws `elem` copies = xmobarColor "#514d42" "" $ ws
                 | otherwise = ws
    dynamicLogWithPP $ xmobarPP {
        ppOutput = hPutStrLn xmproc
        , ppTitle = xmobarColor xmobarTitleColor "" . shorten 100
        , ppCurrent = xmobarColor "#ccc2a6" ""
        , ppHidden = xmobarColor "#514d42" "" . check . noScratchPad
        , ppOrder = \(ws:_:t:_) -> [ws,t]
        , ppSep = "   "
}
	where
	  noScratchPad ws = if ws == "NSP" then "" else ws -- stop NSP from showing
------------------------------------------------------------------------
-- Combine it all together
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = desktopConfig {
    -- simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,

    -- key bindings
    keys               = myKeys,
    mouseBindings      = myMouseBindings,

    -- hooks, layouts
    layoutHook         = smartBorders $ myLayout,
    manageHook         = myManageHook,
    startupHook        = myStartupHook
}
