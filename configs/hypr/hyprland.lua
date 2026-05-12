-------------------------------------------------------------------------
-------- EDIT THIS CONFIG ACCORDING TO THE WIKI INSTRUCTIONS. -----------
-------------------------------------------------------------------------
-- ██╗  ██╗██╗   ██╗██████╗ ██████╗  ██████╗ ██████╗ ███╗   ██╗███████╗
-- ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██╔═══██╗████╗  ██║██╔════╝
-- ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ██║   ██║██╔██╗ ██║█████╗
-- ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██║   ██║██║╚██╗██║██╔══╝
-- ██║  ██║   ██║   ██║     ██║  ██║╚██████╗╚██████╔╝██║ ╚████║██║
-- ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝
--
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can split this configuration into multiple files
-- Create your files separately and then link them to this file like this:
-- require("myColors")

-- For using template colors
require("$HOME/.config/hypr/Configs/hyprcolor.conf")

-- Functionality settings
require("$HOME/.config/hypr/Configs/hyprfunc.conf")

-- Decoration/Animation settings
require("$HOME/.config/hypr/Configs/hyprdeco.conf")

-- Keybinds
require("$HOME/.config/hypr/Configs/hyprbinds.conf")

-- Window and Layerrules
require("$HOME/.config/hypr/Configs/hyprwinlayrules.conf")
