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
if prefs.prefFlagLogging == nil then
	prefs.prefFlagLogging = false
end
if prefs.prefFlagOverwrite == nil then
	prefs.prefFlagOverwrite = false
end
if prefs.prefTagRegNotFound == nil or prefs.prefTagRegNotFound == '' then
	prefs.prefTagRegNotFound = 'RegNotFound'
end
if prefs.prefLookupUrl == nil or prefs.prefLookupUrl == '' then
	prefs.prefLookupUrl = 'https://www.jetphotos.com/showphotos.php?regsearch='
end
if prefs.prefRegistrationToken1 == nil or prefs.prefRegistrationToken1 == '' then
	prefs.prefRegistrationToken1 = '/registration/'
end
if prefs.prefRegistrationToken2 == nil or prefs.prefRegistrationToken2 == '' then
	prefs.prefRegistrationToken2 = '"'
end
if prefs.prefAirlineToken1 == nil or prefs.prefAirlineToken1 == '' then
	prefs.prefAirlineToken1 = '/airline/'
end
if prefs.prefAirlineToken2 == nil or prefs.prefAirlineToken2 == '' then
	prefs.prefAirlineToken2 = '"'
end
if prefs.prefAircraftToken1 == nil or prefs.prefAircraftToken1 == '' then
	prefs.prefAircraftToken1 = '/aircraft/'
end
if prefs.prefAircraftToken2 == nil or prefs.prefAircraftToken2 == '' then
	prefs.prefAircraftToken2 = '"'
end
if prefs.prefManufacturerToken1 == nil or prefs.prefManufacturerToken1 == '' then
	prefs.prefManufacturerToken1 = 'manu='
end
if prefs.prefManufacturerToken2 == nil or prefs.prefManufacturerToken2 == '' then
	prefs.prefManufacturerToken2 = '"'
end
