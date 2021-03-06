-- Standard awesome library
--local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

local vicious = require("vicious")

atag = require("awful.tag")
aclient = require("awful.client")


-- This is used later as the default terminal and editor to run.
local terminal = "roxterm"
local editor = os.getenv("EDITOR") or "vim"
local editor_cmd = terminal .. " -e " .. editor
local browser = "vivaldi-stable"



-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

local function debug(str, title)
	title = title or ""
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = title,
                     text = str })
end
local debug = function() end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}
-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
--beautiful.init("~/.config/awesome/theme.lua")

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.

local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.magnifier,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.floating
}
-- }}}

--
-- {{{ Wallpaper
--if beautiful.wallpaper then
    --for s = 1, screen.count() do
        --gears.wallpaper.maximized(beautiful.wallpaper, s, false)
    --end
--end

	
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
local tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    --tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
	for _, tag in pairs(tags[s]) do
		awful.tag.setmwfact( .5, tag)
	end
end

screen[1].sloppy_focus = false


-- {{{ Menu
-- Create a laucher widget and a main menu
local myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

--[[
local mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
--]]
-- }}}

-- {{{ Wibox
-- Create a textclock widget
local clock = awful.widget.textclock()

local systray = wibox.widget.systray()
 
--CPU Widget
cpu = wibox.widget.textbox()
vicious.register(cpu, vicious.widgets.cpu, " CPU $1% ")
 
--Memory Usage
mem = wibox.widget.textbox()
vicious.register(mem, vicious.widgets.mem, "MEM $1% ($2/$3) ", 13)

-- Custom Temperature widget
local temps = wibox.widget.textbox()
function getTemp()
		str = {" TEMP "}
		str2 = {}
	    local fd=io.popen("sensors", "r") -- list sensor data
		line = fd:read()
		while line do
			local num, temp = line:match('Core (.):[ \t]*[+-](.-)C')
			temp = temp or line:match("temp1:[ \t]*[+-](.-)C")
			if temp then
				temp = temp:match('(.-)[.]') or "?"
			end
			if num then
				table.insert(str, temp)
				table.insert(str, ",")
			elseif temp then
				table.insert(str2, temp)
				table.insert(str2, ",")
			end
			line = fd:read()
		end
		table.remove(str);table.remove(str2)
		return table.concat(str) ..'|'.. table.concat(str2) .. " "
end
temps:set_text("not testing")
local temp_timer = timer{timeout=2}
temp_timer:connect_signal("timeout", function()
	temps:set_text(getTemp())
end)

-- uncomment this line to include tempurature monitoring
--temp_timer:start()


local tasklistButtons = awful.util.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c.minimized = false
			client.focus = c
			c:raise()
		end
	end),
	awful.button({}, 3, function()
		if instance then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients{ theme = {width=250}}
		end
	end)
)

-- Create a wibox for each screen and add it
local wiboxes = {}
local tasklists = {}
for s = 1, screen.count() do
	wiboxes[s] = awful.wibox{ position="top", screen=s}
	tasklists[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklistButtons)
	local left = wibox.layout.fixed.horizontal()
	local right = wibox.layout.fixed.horizontal()
	right:add(mem)
	right:add(cpu)
	right:add(temps)
	right:add(systray)
	right:add(clock)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left)
	layout:set_middle(tasklists[s])
	layout:set_right(right)
	wiboxes[s]:set_widget(layout)
end
local mypromptbox = {}
local mylayoutbox = {}

local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

local alt = "Mod1"
local ctrl = "Mod2"
-- {{{ Key bindings
local globalkeys = awful.util.table.join(

    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ alt,           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ alt, "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    -- Layout manipulation
    --awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    --awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    --awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    --awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    --awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
	--[[
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

		--]]
    -- Standard program
    awful.key({ modkey, "Shift"   }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
	awful.key({modkey,            }, "r", function() awful.util.spawn("dmenu_run") end),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.util.spawn( "gmrun" ) end ),

	-- launcher keys
	awful.key({ modkey,           }, "w",     function () awful.util.spawn( browser ) end ),
	awful.key({ modkey,           }, "v",     function () awful.util.spawn( terminal ) end ),
	awful.key({ modkey,           }, "c",     function () awful.util.spawn( filemanager ) end ),
	awful.key({ modkey,           }, "x",     function () awful.util.spawn( editor_cmd ) end ),
	awful.key({ modkey,           }, "z",     function () awful.util.spawn( browser ) end ),

	--[[
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
			  --]]
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

local clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

local clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "Florence" }, 
	properties = { floating = true,
	               raise = false,
			focusable = false,
	               focus = false },
	callback =  function( c ) -- dont let the virtual keyboard get focus
		c:connect_signal("focus", function(c)
			local i, last = 0
			repeat
				last =  awful.client.focus.history.get( c.screen, i)
				i=i+1
			until last ~= c or last == nil
			
			if last then
				debug("refocusing", last.class )
				client.focus = last
			elseif debug then
				debug("error", "no previously focused clients?")
			end
		end)
	end },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
client.connect_signal("focus", function(c)
 c.border_width=beautiful.border_width; c.border_color = beautiful.border_focus
local last =  awful.client.focus.history.get( c.screen, 0)
if last then debug("Last Client:", last.class) end
 end)
client.connect_signal("unfocus", function(c)
	-- do not change borders if florence is being focused.
	 c.border_width=beautiful.border_width; c.border_color = beautiful.border_normal
 end)
client.connect_signal("manage", function(c)
	debug("manage:", tostring(c.class) .. " :: " .. tostring(c.name))
end)
-- Signal function to execute when a new client appears.
--[[
client.connect_signal("manage", function (c, startup)
	
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Client",
                     text = c.class .. c.name })
    -- Enable sloppy focus
    --c:connect_signal("mouse::enter", function(c)
        --if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            --and awful.client.focus.filter(c) then
            --client.focus = c
        --end
    --end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)
--]]

-- }}}

awful.util.spawn( terminal )
awful.util.spawn_with_shell( "light -I" )
awful.util.spawn_with_shell( "xset dpms 0 0 0" ) -- set backlight timeout
awful.util.spawn_with_shell( "xbindkeys" )
awful.util.spawn_with_shell( "nm-applet" ) -- show wifi setting
awful.util.spawn_with_shell( "cbatticon" ) -- show battery status
awful.util.spawn_with_shell( "synclient TapButton1=1" ) --turn on tap-to-click 
