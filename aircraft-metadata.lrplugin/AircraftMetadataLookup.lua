--[[----------------------------------------------------------------------------
AircraftmetadataLookup.lua
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
local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'
local LrHttp = import 'LrHttp'

local logger = import 'LrLogger'('AircraftMetadatLookup')
logger:enable( "logfile" )
--logger:disable()

local catalog = LrApplication.activeCatalog()
local baseURL = 'https://www.jetphotos.com/showphotos.php?regsearch='

AircraftMetadataImport = {}

function AircraftMetadataImport.Jetphotos()
	local metadataCache = {}
	countPhoto = 0
	countCacheHit = 0
	countLookup = 0
	countNoReg = 0
	countRegNotFound = 0

	-- clear old logfile
	logPath = LrPathUtils.child(LrPathUtils.getStandardFilePath('documents'), 'AircraftMetadatLookup.log')
		if LrFileUtils.exists( logPath ) then
			success, reason = LrFileUtils.delete( logPath )
			if not success then
				logger:error('Error deleting existing logfile!' .. reason)
			end
	end

	logger:info('>>>> running lookup')
	-- get a reference to the photos within the current catalog.
	local catPhotos = catalog.targetPhotos
	-- Loop through each of the photos.
	for _, photo in ipairs (catPhotos) do
		countPhoto = countPhoto + 1
		flagRegFound = true
		-- read photo name for debug messages
		photoFilename = photo:getFormattedMetadata('fileName')
		-- read aircraft registration from photo
		searchRegistration = photo:getPropertyForPlugin(_PLUGIN, 'registration')
		-- do we have a registration?
		if not (searchRegistration == '' or searchRegistration == nil) then
			-- is registration already in cache?
			if not metadataCache[searchRegistration] then
				countLookup = countLookup + 1
				lookupURL = baseURL .. searchRegistration
				logger:info(photoFilename..' - looking up registration at '..lookupURL..' for: >>'..searchRegistration..'<<')
				-- do the lookup
				content = LrHttp.get(lookupURL)
--				LrDialogs.message(photoFilename, content, 'info')
				-- check if lookup returned something usefull
				if string.find(content, '>Reg:') == nil then
					-- lookup returned nothing usefull
					countRegNotFound = countRegNotFound + 1
					flagRegFound = false
					logger:info(photoFilename..' - no metadata found for registration >>'..searchRegistration..'<<')
					-- set label for photo
				else
					-- lookup returned something usefull
--					foundRegistration = extractMetadata(content, '>Reg: <', ' full info</a>', 'class="link">')
					foundRegistration = extractMetadata(content, '>Reg:', ' photos</a>', 'class="link">')
					if searchRegistration == foundRegistration then
						foundAirline = extractMetadata(content, '>Airline:', '</a></span>', 'class="link">')
						foundAircraft = extractMetadata(content, '>Aircraft:', '</a></span>', 'class="link">')
						-- split aircraft info in manufacturer and type 
						-- rework needed - this will only work if manufacturers name has no blanks
						foundAircraftManufacturer = string.sub(foundAircraft, 1, string.find(foundAircraft, ' ') - 1)
						foundAircraftType = string.sub(foundAircraft, string.find(foundAircraft, ' ') + 1, string.len(foundAircraft))
						-- cache found metadata
						metadataCache[searchRegistration] = {foundRegistration = foundRegistration, foundAirline = foundAirline, foundAircraft = foundAircraft, foundAircraftManufacturer = foundAircraftManufacturer, foundAircraftType = foundAircraftType}
						logger:info(photoFilename..' - metadata found: '..foundRegistration..', '..foundAirline..', '..foundAircraftManufacturer..', '..foundAircraftType)
					else
						logger:info(photoFilename..' -  jetphoto returned wrong registration: >>'..foundRegistration..'<< instead of >>'..searchRegistration..'<<')
						countNoReg = countNoReg + 1
					end
				end
			else
				logger:info(photoFilename..' - using cached metadata for: ' .. metadataCache[searchRegistration].foundRegistration)
				countCacheHit = countCacheHit + 1
			end
			if flagRegFound then
				-- write metadata to image
				catalog:withWriteAccessDo( "set aircraft metadata", 
				function() 
					photo:setPropertyForPlugin(_PLUGIN, 'airline', metadataCache[searchRegistration].foundAirline)
					photo:setPropertyForPlugin(_PLUGIN, 'aircraft_manufacturer', metadataCache[searchRegistration].foundAircraftManufacturer)
					photo:setPropertyForPlugin(_PLUGIN, 'aircraft_type', metadataCache[searchRegistration].foundAircraftType)
				end)
			end
		else
			logger:info(photoFilename..' - no registration set')
			countNoReg = countNoReg + 1
		end
	end
	logger:info('>>>> lookup done - processed '..countPhoto..' photos ('..countLookup..' lookups, '..countRegNotFound..' regs not found, '..countCacheHit..' cache hits, '..countNoReg..' photos without reg)')
	LrDialogs.message('Lookup done', 'processed '..countPhoto..' photos ('..countLookup..' lookups, '..countRegNotFound..' regs not found, '..countCacheHit..' cache hits, '..countNoReg..' photos without reg)', 'info')
end

-- isolate metadata - sorry, creepy html parsing, no fancy things like JSON available
function extractMetadata(payload, Token1, Token2, Token3)
	posStart, posEnd = string.find(payload, Token1)
	line = string.sub(payload, posEnd + 1)
--	LrDialogs.message('Lookup Airline - after Token 1', line, 'info')
	posStart, posEnd = string.find(line, Token2)
	line = string.sub(line, 1, posStart - 1)
--	LrDialogs.message('Lookup Airline - after Token 2', line, 'info')
	posStart, posEnd = string.find(line, Token3)
	line = string.sub(line, posEnd + 1)
--	LrDialogs.message('Lookup Airline - after Token 3', line, 'info')
	return line
end

import 'LrTasks'.startAsyncTask(AircraftMetadataImport.Jetphotos)