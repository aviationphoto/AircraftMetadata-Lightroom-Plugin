--[[----------------------------------------------------------------------------
ShutdownPlugin.lua
This file is part of LR Aircraft Metadata.
Copyright(c) 2017, aviationphoto

LR Aircraft Metadata is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LR Aircraft Metadata is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LR Aircraft Metadata.  If not, see <http://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]
local prefs = import 'LrPrefs'.prefsForPlugin()

prefs.prefLookupUrl = nil
prefs.prefFlagLogging = nil

prefs.prefRegistrationToken1 = nil
prefs.prefRegistrationToken2 = nil
prefs.prefAirlineToken1 = nil
prefs.prefAirlineToken2 = nil
prefs.prefAircraftToken1 = nil
prefs.prefAircraftToken2 = nil
prefs.prefManufacturerToken1 = nil
prefs.prefManufacturerToken2 = nil
prefs.prefSuccessfulSearch = nil
