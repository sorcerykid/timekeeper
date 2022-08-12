--------------------------------------------------------
-- Minetest :: Timekeeper Mod (timekeeper)
--
-- See README.txt for licensing and release notes.
-- Copyright (c) 2020, Leslie E. Krause
--
-- ./games/just_test_tribute/mods/timekeeper/init.lua
--------------------------------------------------------

local g_timer_list = { }
local g_clock = 0.0

globaltimer = { }

globaltimer.start = function ( period, name, func, delay )
	assert( string.find( name, minetest.get_current_modname( ) .. ":" ) == 1 )

	table.insert( g_timer_list, {
		cycles = 0,
		period = period,
		expiry = g_clock + ( delay or 0.0 ),
		func = func,
	} )
end

minetest.register_globalstep( function ( dtime )
	g_clock = g_clock + dtime

	for i, v in ipairs( g_timer_list ) do
		if g_clock >= v.expiry then
			v.expiry = g_clock + v.period
			-- callback( cycles, period, uptime, overrun )
			v.func( v.cycles, v.period, g_clock, g_clock - v.expiry )
			v.cycles = v.cycles + 1
		end
	end
end )

minetest.after( 0.0, function ( )
	globaltimer.start = nil
end )

function Timekeeper( this )
	local timers = { }
	local pending_timers = { }
	local clock = 0.0
	local self = { }

	self.start = function ( period, name, func, delay )
		assert( globaltimer.start == nil )  -- only start timers once environment is initialized

		if timers[ name ] then
			timers[ name ] = nil
		end
		pending_timers[ name ] = { cycles = 0, period = period, expiry = clock + period + ( delay or 0.0 ), started = clock, func = func }
	end

	self.start_now = function ( period, name, func )
		assert( globaltimer.start == nil )  -- only start timers once environment is initialized

		if timers[ name ] then
			timers[ name ] = nil
		end
		if not func( this, 0, period, 0.0, 0.0 ) then
			pending_timers[ name ] = { cycles = 0, period = period, expiry = clock + period, started = clock, func = func }
		end
	end

	self.clear = function ( name )
		pending_timers[ name ] = nil
		if timers[ name ] then
			timers[ name ] = nil
		end
	end

	self.on_step = function ( dtime )
		clock = clock + dtime

		for k, v in pairs( pending_timers ) do
			timers[ k ] = v
			pending_timers[ k ] = nil
		end

		local running_timers = { }
		for k, v in pairs( timers ) do
			if clock >= v.expiry then
				v.expiry = clock + v.period
				v.cycles = v.cycles + 1
				-- callback( this, cycles, period, elapsed, overrun )
				if v.func and v.func( this, v.cycles, v.period, clock - v.started, clock - v.expiry ) then
					self.clear( k )
				end
				running_timers[ k ] = v
			end
		end

		return running_timers
	end

	return self
end
