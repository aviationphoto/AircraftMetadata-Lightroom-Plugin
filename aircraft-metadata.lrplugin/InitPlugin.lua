--[[----------------------------------------------------------------------------
InitPlugin.lua
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

if prefs.prefLookupUrl == nil or prefs.prefLookupUrl == '' then
	prefs.prefLookupUrl = 'https://www.jetphotos.com/showphotos.php?regsearch='
end

if prefs.prefFlagLogging == nil then
	prefs.prefFlagLogging = false
end

prefs.prefRegistrationToken1 = '/registration/'
prefs.prefRegistrationToken2 = '"'
prefs.prefAirlineToken1 = '/airline/'
prefs.prefAirlineToken2 = '"'
prefs.prefAircraftToken1 = '/aircraft/'
prefs.prefAircraftToken2 = '"'
prefs.prefManufacturerToken1 = '/aircraft/'
prefs.prefManufacturerToken2 = 'manu='
