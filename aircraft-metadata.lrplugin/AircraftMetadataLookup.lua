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
local LrProgressScope = import 'LrProgressScope'

local logger = import 'LrLogger'('AircraftMetadatLookup')
logger:enable( 'logfile' )
--logger:disable()

local baseURL = 'https://www.jetphotos.com/showphotos.php?regsearch='

local AircraftMetadataImport = {}

function AircraftMetadataImport.Jetphotos()
	local metadataCache = {}
	local countSelected = 0
	local countProcessed = 0
	local countCacheHit = 0
	local countLookup = 0
	local countNoReg = 0
	local countRegNotFound = 0

	local flagRegFound = true

	-- clear old logfile
	local logPath = LrPathUtils.child(LrPathUtils.getStandardFilePath('documents'), 'AircraftMetadatLookup.log')
		if LrFileUtils.exists( logPath ) then
			success, reason = LrFileUtils.delete( logPath )
			if not success then
				logger:error('Error deleting existing logfile!'..reason)
			end
	end
	-- define progress bar
	local progressScope = LrProgressScope({title = 'Performing Aircraft Metadata lookup'})
	progressScope:setCancelable(false)

	logger:info('>>>> running lookup')
	-- get a reference to the photos within the current catalog
	local catalog = LrApplication.activeCatalog()
	local selectedPhotos = catalog:getTargetPhotos()
	-- count selected photos
	for _ in pairs(selectedPhotos) do
		countSelected = countSelected + 1
	end
	logger:info('selected photos: '..countSelected)
	-- loop through each of the photos
	for _, photo in ipairs (selectedPhotos) do
		countProcessed = countProcessed + 1
		flagRegFound = true
		-- read photo name
		local photoFilename = photo:getFormattedMetadata('fileName')

		-- read aircraft registration from photo
		searchRegistration = photo:getPropertyForPlugin(_PLUGIN, 'registration')
		-- do we have a registration?
		if not (searchRegistration == '' or searchRegistration == nil) then
			-- yes, photo has registration
			local searchRegistration = trim(searchRegistration)
			-- is registration already in cache?
			if not metadataCache[searchRegistration] then
				-- no, we need to do a lookup
				countLookup = countLookup + 1
				lookupURL = baseURL..searchRegistration
				logger:info(photoFilename..' - looking up registration at '..lookupURL..' for: >>'..searchRegistration..'<<')
				-- do the lookup
				content = LrHttp.get(lookupURL)
				--LrDialogs.message(photoFilename, content, 'info')
				-- check if lookup returned something usefull
				if string.find(content, '>Reg:') == nil then
					-- lookup returned nothing usefull
					countRegNotFound = countRegNotFound + 1
					flagRegFound = false
					logger:info(photoFilename..' - no metadata found for registration >>'..searchRegistration..'<<')
					-- mark photo with keyword reg_not_found
				else
					-- lookup returned something usefull
					foundRegistration = trim(extractMetadata(content, '/registration/', '"'))
					-- check if lookup returned the right registration
					if searchRegistration == foundRegistration then
						-- yes, isolate metadata
						foundAirline = trim(extractMetadata(content, '/airline/', '"'))
						foundAircraft = trim(extractMetadata(content, '/aircraft/', '"'))
						-- split aircraft info in manufacturer and type
						foundAircraftManufacturer = trim(extractMetadata(content, 'manu=', '"'))
						-- check if manufacturer is set
						if foundAircraftManufacturer == '' then
							foundAircraftManufacturer = 'not set'
						end
						foundAircraftType = trim(string.sub(foundAircraft, string.len(foundAircraftManufacturer)+1, string.len(foundAircraft)))
						-- cache found metadata
						metadataCache[searchRegistration] = {foundRegistration = foundRegistration, foundAirline = foundAirline, foundAircraft = foundAircraft, foundAircraftManufacturer = foundAircraftManufacturer, foundAircraftType = foundAircraftType}
						logger:info(photoFilename..' - metadata found: Reg: '..foundRegistration..', Airline: '..foundAirline..', Manufacturer: '..foundAircraftManufacturer..', Type: '..foundAircraftType)
					else
						-- no, lookup returned wrong registration
						logger:info(photoFilename..' -  lookup returned wrong registration: >>'..foundRegistration..'<< instead of >>'..searchRegistration..'<<')
						countNoReg = countNoReg + 1
						-- mark photo with keyword wrong_reg
					end
				end
			else
				-- yes, use cached metadata
				logger:info(photoFilename..' - using cached metadata for: '..metadataCache[searchRegistration].foundRegistration)
				countCacheHit = countCacheHit + 1
			end
			if flagRegFound then
				-- write metadata to image
				catalog:withWriteAccessDo( 'set aircraft metadata',
				function()
					photo:setPropertyForPlugin(_PLUGIN, 'registration', metadataCache[searchRegistration].foundRegistration)
					photo:setPropertyForPlugin(_PLUGIN, 'airline', metadataCache[searchRegistration].foundAirline)
					photo:setPropertyForPlugin(_PLUGIN, 'aircraft_manufacturer', metadataCache[searchRegistration].foundAircraftManufacturer)
					photo:setPropertyForPlugin(_PLUGIN, 'aircraft_type', metadataCache[searchRegistration].foundAircraftType)
				end)
			end
		else
			-- photo has no registration
			logger:info(photoFilename..' - no registration set')
			countNoReg = countNoReg + 1
			-- mark photo with keyword no_reg
		end
		progressScope:setPortionComplete(countProcessed, countSelected)
	end
	logger:info('>>>> lookup done - processed '..countProcessed..' photos ('..countLookup..' lookups, '..countRegNotFound..' regs not found, '..countCacheHit..' cache hits, '..countNoReg..' photos without reg)')
	LrDialogs.message('Lookup done', 'processed '..countProcessed..' photos ('..countLookup..' lookups, '..countRegNotFound..' regs not found, '..countCacheHit..' cache hits, '..countNoReg..' photos without reg)', 'info')
	progressScope:done()
end

-- isolate metadata - sorry, creepy html parsing, no fancy things like JSON available
function extractMetadata(payload, Token1, Token2)
	local posStart, posEnd = string.find(payload, Token1)
	local line = string.sub(payload, posEnd + 1)
	--LrDialogs.message('Lookup Airline - after Token 1', line, 'info')
	posStart, posEnd = string.find(line, Token2)
	line = string.sub(line, 1, posStart - 1)
	--LrDialogs.message('Lookup Airline - after Token 2', line, 'info')
	return line
end

-- remove trailing and leading whitespace from string
function trim(s)
  return (s:gsub('^%s*(.-)%s*$', '%1'))
end

import 'LrTasks'.startAsyncTask(AircraftMetadataImport.Jetphotos)
