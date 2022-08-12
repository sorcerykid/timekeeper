Timekeeper Mod v1.3
By Leslie E. Krause

Timekeeper acts as a centralized dispatcher for all time-sensitive routines, thereby 
obviating the need for redundant timer implementations within each mod.

The Timekeeper class provides a simple and efficient means of executing code at regular 
intervals. The constructor itself is global, so typically it will be used in conjunction 
with entities.

 * Timekeeper( this )
   Instantiates and returns a new timekeeper object, with an optional meta table for use 
   by callbacks (typically this will be a reference to the entity itself). Ideally the 
   Timekeeper constructor will be called as soon as the LuaEntitySAO has been added to 
   the environment.

The timekeeper object is instantiated within the on_activate callback of an entity:

>  on_activate(self)
>          self.timekeeper = Timekeeper(self)
>          :
>  end,

The following methods are available:

 * timekeeper.start( period, name, func, delay )
   Starts a new timer with the given name and period. The callback will execute no sooner 
   than the next server step. If the callback returns false, then the timer will be 
   cancelled and removed from the queue. An optional delay can be specified to avoid 
   concurrency with other running timers.

 * timekeeper.start_now( period, name, func )
   Identical to timekeeper.start(), except the first iteration of the callback will be 
   executed immediately.

 * timekeeper.clear( name )
   Cancels an existing timer with the given name.

Four parameters are provided to the timer callback for each iteration:

 * this - the meta table that was originally passed to the constructor
 * cycles - the number of cycles that have accrued, beginning at 1
 * period - the interval between each cycle
 * elapsed - the elapsed time for all cycles
 * overrun - the overrun time from the last cycle

In order for the timers to be processed correctly, you must call the on_step method of 
the timekeeper object during every server step. For example, in the case of entities:

>  on_step = function (self, dtime)
>          local timers = self.timekeeper.on_step(dtime)
>          :
>  end,

The on_step method of the timekeeper object returns a table of running timers. This can 
be useful for post-processing of timers within the on_step callback. Each timer consists 
of the following read-only fields: cycles, period, expiry, started, and func.

For convenience, a globaltimer singleton object is available for use by all mods. This 
can avoid the need to register multiple globalsteps when a simple timer mechanism is all 
that is required. In this case, the timer names must be prefixed with the mod name and a 
colon to avoid collisions.

The following method is available, but only at server startup:

 * globaltimer.start( period, name, func, delay )
   Starts a new global timer with the given name and period (name must be prefixed with
   the current mod name). The callback will execute no sooner than the first server step. 
   An optional delay can be specified to avoid concurrency with other global timers.

Four parameters are provided to the global timer callback for each iteration:

 * cycles - the number of cycles that have accrued, beginning at 1
 * period - the interval between each cycle
 * uptime - the elapsed time since server start
 * overrun - the overrun time from the last cycle

Since global timers are persistent, they are best suited for ongoing tasks that execute 
for the lifetime of the server. Hence, there is no clear method.


Repository
----------------------

Browse source code...
  https://bitbucket.org/sorcerykid/timekeeper

Download archive...
  https://bitbucket.org/sorcerykid/timekeeper/get/master.zip
  https://bitbucket.org/sorcerykid/timekeeper/get/master.tar.gz

Installation
----------------------

  1) Unzip the archive into the mods directory of your game.
  2) Rename the timekeeper-master directory to "timekeeper".
  3) Add "timekeeper" as a dependency to any mods using the API.

License of source code
----------------------------------------------------------

The MIT License (MIT)

Copyright (c) 2020-2022, Leslie Krause (leslie@searstower.org)

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

For more details:
https://opensource.org/licenses/MIT
