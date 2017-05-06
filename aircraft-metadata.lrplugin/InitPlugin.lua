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
if prefs.prefKeywordRegNotFound == nil or prefs.prefKeywordRegNotFound == '' then
	prefs.prefKeywordRegNotFound = 'AircraftMetadata-RegNotFound'
end
if prefs.prefKeywordWrongReg == nil or prefs.prefKeywordWrongReg == '' then
	prefs.prefKeywordWrongReg = 'AircraftMetadata-WrongReg'
end
if prefs.prefLookupUrl == nil or prefs.prefLookupUrl == '' then
	prefs.prefLookupUrl = 'https://www.flightradar24.com/data/aircraft/'
end
if prefs.prefMetadataProvider == nil or prefs.prefMetadataProvider == '' then
	prefs.prefMetadataProvider = 'jetphotos'
end
