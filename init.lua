---------------------------------------------------------------------------------------------------
-- metrosigns mod for minetest by A S Lewis
--      https://github.com/axcore/metrosigns
--      Licence: GNU Affero GPL
---------------------------------------------------------------------------------------------------
-- Includes code/textures from advtrains_subwayblocks by gpcf/orwell
--      https://git.gpcf.eu/?p=advtrains_subwayblocks.git
--      Licence: GNU Affero GPL
--
-- Includes code/textures from trainblocks by Maxx
--      https://github.com/maxhipp/trainblocks_bc
--      https://forum.minetest.net/viewtopic.php?t=19743
--      Licence: GNU Affero GPL
--
-- Includes code/textures from roads by cheapie
--      https://cheapiesystems.com/git/roads/
--      https://forum.minetest.net/viewtopic.php?t=13904
--      Licence: CC-BY-SA 3.0 Unported
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Create namespaces
---------------------------------------------------------------------------------------------------

metrosigns = {}
metrosigns.name = "metrosigns"
metrosigns.ver_max = 1
metrosigns.ver_min = 6
metrosigns.ver_rev = 0

metrosigns.writer = {}

---------------------------------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------------------------------

metrosigns.path_mod = minetest.get_modpath(minetest.get_current_modname())

-- If default and basic_materials are loaded, the sign writer and cartridges are craftable
if minetest.get_modpath("default") then
    HAVE_DEFAULT_FLAG = true
else
    HAVE_DEFAULT_FLAG = false
end

if minetest.get_modpath("basic_materials") then
    HAVE_BASIC_MATERIALS_FLAG = true
else
    HAVE_BASIC_MATERIALS_FLAG = false
end

-- If signs_api from display_modpack is loaded, create signs with customisable text
if minetest.get_modpath("signs_api") then
    HAVE_SIGNS_API_FLAG = true
else
    HAVE_SIGNS_API_FLAG = false
end

-- If advtrains_subwayblocks is loaded, we don't create duplicate blocks
if minetest.get_modpath("advtrains_subwayblocks") then
    HAVE_SUBWAYBLOCKS_FLAG = true
else
    HAVE_SUBWAYBLOCKS_FLAG = false
end

-- If trainblocks is loaded, we don't create duplicate blocks
if minetest.get_modpath("trainblocks") then
    HAVE_TRAINBLOCKS_FLAG = true
else
    HAVE_TRAINBLOCKS_FLAG = false
end

-- Cartridge ink levels are implemented using wear
-- Ink capacity of a cartridge
metrosigns.writer.cartridge_max = 60000
-- Amount of ink used for one unit
metrosigns.writer.cartridge_min = 1000
-- Number of units used for printing various kinds of sign
metrosigns.writer.box_units = 30
metrosigns.writer.sign_units = 6
metrosigns.writer.map_units = 12
metrosigns.writer.text_units = 12

-- Used in material copied from advtrains_subwayblocks and trainblocks
box_groups = {cracky = 3}
box_light_source = 10

---------------------------------------------------------------------------------------------------
-- Variables
---------------------------------------------------------------------------------------------------

-- Signs are divided into categories. A category's name is the same as the city description (i.e.
--  "London Underground" rather than "London"
-- Ordered list of categories, as displayed in the sign-writing
--  machine's dropdrown box, e.g. categories[1] = "London Underground",
--  categories[2] = "Paris Metro"
metrosigns.writer.categories = {}
-- The current category; one of the values in metrosigns.writer.categories. Only signs in this
--  category are visible in the sign-writing machine's list
metrosigns.writer.current_category = nil
-- Ordered list of signs in each category and their properties. The properties are arranged in a
--  table:
--      category - one of the values in metrosigns.writer.current_category
--      name - the name of the sign's node, e.g. "metrosigns:map_london_bakerloo_line"
--      ink_needed - the amount of ink removed from each cartridge when printing the sign, e.g. 10
-- Thus we have, e.g. signtypes["London Underground"][1] = property_table,
--      signtypes["London Underground"][2] = property_table, etc
metrosigns.writer.signtypes = {}
-- The number of signs in each category, e.g. signcounts["London Underground"] = 20
metrosigns.writer.signcounts = {}

---------------------------------------------------------------------------------------------------
-- Load settings
---------------------------------------------------------------------------------------------------

-- Load settings from Minetest's main menu
metrosigns.create_all_flag = minetest.setting_get("metrosigns_create_all") or false

metrosigns.create_subwayblocks_flag = minetest.setting_get("metrosigns_create_subwayblocks")
or false
metrosigns.create_trainblocks_flag = minetest.setting_get("metrosigns_create_trainblocks") or false

metrosigns.create_ext_line_flag = minetest.setting_get("metrosigns_create_ext_line") or true
metrosigns.ext_line_min = minetest.setting_get("metrosigns_ext_line_min") or 11
metrosigns.ext_line_max = minetest.setting_get("metrosigns_ext_line_min") or 20

metrosigns.create_ext_platform_flag = minetest.setting_get("metrosigns_create_ext_platform") or true
metrosigns.ext_platform_min = minetest.setting_get("metrosigns_ext_platform_min") or 11
metrosigns.ext_platform_max = minetest.setting_get("metrosigns_ext_platform_min") or 20

metrosigns.create_text_flag = minetest.setting_get("metrosigns_create_text") or true

metrosigns.create_athens_flag = minetest.setting_get("metrosigns_create_athens") or false
metrosigns.create_bangkok_flag = minetest.setting_get("metrosigns_create_bangkok") or false
metrosigns.create_berlin_flag = minetest.setting_get("metrosigns_create_berlin") or false
metrosigns.create_bucharest_flag = minetest.setting_get("metrosigns_create_bucharest") or false
metrosigns.create_budapest_flag = minetest.setting_get("metrosigns_create_budapest") or false
metrosigns.create_glasgow_flag = minetest.setting_get("metrosigns_create_glasgow") or false
metrosigns.create_hcmc_flag = minetest.setting_get("metrosigns_create_hcmc") or false
metrosigns.create_london_flag = minetest.setting_get("metrosigns_create_london") or true
metrosigns.create_luton_flag = minetest.setting_get("metrosigns_create_luton") or false
metrosigns.create_madrid_flag = minetest.setting_get("metrosigns_create_madrid") or false
metrosigns.create_moscow_flag = minetest.setting_get("metrosigns_create_moscow") or false
metrosigns.create_newyork_flag = minetest.setting_get("metrosigns_create_newyork") or false
metrosigns.create_paris_flag = minetest.setting_get("metrosigns_create_paris") or false
metrosigns.create_prague_flag = minetest.setting_get("metrosigns_create_prague") or false
metrosigns.create_rome_flag = minetest.setting_get("metrosigns_create_rome") or false
metrosigns.create_stockholm_flag = minetest.setting_get("metrosigns_create_stockholm") or false
metrosigns.create_taipei_flag = minetest.setting_get("metrosigns_create_taipei") or false
metrosigns.create_tokyo_flag = minetest.setting_get("metrosigns_create_tokyo") or false
metrosigns.create_toronto_flag = minetest.setting_get("metrosigns_create_toronto") or false
metrosigns.create_vienna_flag = minetest.setting_get("metrosigns_create_vienna") or false

metrosigns.create_tabyss_flag = minetest.setting_get("metrosigns_create_tabyss") or false

-- Override one or more of these settings by uncommenting the lines in this file
dofile(metrosigns.path_mod.."/settings.lua")

---------------------------------------------------------------------------------------------------
-- General functions
---------------------------------------------------------------------------------------------------

function capitalise(str)

    if str == "newyork" then
        return "New York"
    else
        return (str:gsub("^%l", string.upper))
    end

end

function isint(n)

  return n==math.floor(n)

end

-- (Used by the sign-writing machine, if it is created)
function metrosigns.register_category(category)

    table.insert(metrosigns.writer.categories, category)
    metrosigns.writer.signcounts[category] = 0
    metrosigns.writer.signtypes[category] = {}
    if metrosigns.writer.current_category == nil then
        metrosigns.writer.current_category = category
    end

end

function metrosigns.register_sign(category, node, ink_needed)

    local data = {category=category, name=node, ink_needed=ink_needed}
    table.insert(metrosigns.writer.signtypes[category], data)
    metrosigns.writer.signcounts[category] = metrosigns.writer.signcounts[category] + 1

end

---------------------------------------------------------------------------------------------------
-- Original material from advtrains_subwayblocks by gpcf/orwell
---------------------------------------------------------------------------------------------------

dofile(metrosigns.path_mod.."/subwayblocks.lua")

---------------------------------------------------------------------------------------------------
-- Original material from trainblocks by Maxx
---------------------------------------------------------------------------------------------------

dofile(metrosigns.path_mod.."/trainblocks.lua")

---------------------------------------------------------------------------------------------------
-- Extended line and platform signs
---------------------------------------------------------------------------------------------------

dofile(metrosigns.path_mod.."/extsigns.lua")

---------------------------------------------------------------------------------------------------
-- Signs with customisable text (designed to be used alongside the map nodes). Requires signs_api
--      from display_modpack
---------------------------------------------------------------------------------------------------

dofile(metrosigns.path_mod.."/customsigns.lua")

---------------------------------------------------------------------------------------------------
-- City-specific signs
---------------------------------------------------------------------------------------------------

dofile(metrosigns.path_mod.."/citysigns.lua")

---------------------------------------------------------------------------------------------------
-- Server-specific signs
---------------------------------------------------------------------------------------------------

dofile(metrosigns.path_mod.."/serversigns.lua")

---------------------------------------------------------------------------------------------------
-- Sign-writing machines and ink cartridges
---------------------------------------------------------------------------------------------------

dofile(metrosigns.path_mod.."/machine.lua")
