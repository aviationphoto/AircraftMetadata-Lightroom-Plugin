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
require "Utilities"

function AircraftMetadataImport()
	LrFunctionContext.callWithContext( "Aircraft Metadata Import", function(context)
		-- define progress bar
		progressScope = LrProgressScope({title = 'Aircraft Metadata Lookup'})
		progressScope:setCancelable(true)
		-- cleanup if error is thrown
		context:addCleanupHandler(function()
			progressScope:done()
		end)

		loadPrefs()
		startLogger('AircraftMetadataLookup')

		-- initialize variables
		messageEnd = 'Aircraft Metadata Lookup finished'
		metadataCache = {}
		countSelected = 0
		countProcessed = 0
		countCacheHit = 0
		countLookup = 0
		countNoReg = 0
		countRegNotFound = 0
		flagRegFound = true
		flagRun = true

		-- create / get keyword
		catalog:withWriteAccessDo('set keyword',
		function()
			keywordRegNotFound = catalog:createKeyword(LrPrefs.prefKeywordRegNotFound, {}, false, nil, true)
			keywordWrongReg = catalog:createKeyword(LrPrefs.prefKeywordWrongReg, {}, false, nil, true)
		end)

		-- check if user selected at least one photos
		if catalog:getTargetPhoto() == nil then
			dialogAction = LrDialogs.confirm('Aircraft Metadata Lookup', 'No photo selected - run lookup on all photos in filmstrip?', 'Yes', 'No')
			if dialogAction == 'cancel' then
				-- cleanup if canceled by user
				flagRun = false
				progressScope:done()
				messageEnd = 'Aircraft Metadata Lookup canceled'
				LrLogger:info('no active photo selection - user canceled run on entire filmstrip')
			end
		end

		-- check if user hit cancel in dialog
		if flagRun then
			-- count selected photos
			for _ in pairs(selectedPhotos) do
				countSelected = countSelected + 1
			end
			LrLogger:info('performing lookup for '..countSelected..' selected photos')
			-- loop through each of the photos
			for _, photo in ipairs (selectedPhotos) do
				countProcessed = countProcessed + 1
				flagRegFound = true
				-- check if user hit cancel in progress bar
				if progressScope:isCanceled() then
					messageEnd = 'Aircraft Metadata Lookup canceled'
				else
					-- read photo name for logging
					-- check if we are working on a copy
					if photo:getFormattedMetadata('copyName') == nil then
						photoFilename = photo:getFormattedMetadata('fileName')..'          '
					else
						photoFilename = photo:getFormattedMetadata('fileName')..' ('..photo:getFormattedMetadata('copyName')..')'
					end
					-- read aircraft registration from photo
					searchRegistration = photo:getPropertyForPlugin(_PLUGIN, 'registration')
					-- do we have a registration?
					if not (searchRegistration == '' or searchRegistration == nil) then
						-- yes, photo has registration
						searchRegistration = string.upper(LrStringUtils.trimWhitespace(searchRegistration))
						-- is registration already in cache?
						if not metadataCache[searchRegistration] then
							-- no, we need to do a lookup
							countLookup = countLookup + 1
							lookupURL = LrStringUtils.trimWhitespace(LrPrefs.prefLookupUrl)..searchRegistration
							LrLogger:info(photoFilename..' - looking up registration at '..lookupURL..' for: '..searchRegistration)
							-- do the lookup
							content = LrHttp.get(lookupURL)
							--LrDialogs.message(photoFilename, content, 'info')
							-- check if lookup returned something usefull
							if string.find(content, LrPrefs.prefSuccessfulSearch) == nil then
								-- lookup returned nothing usefull
								countRegNotFound = countRegNotFound + 1
								flagRegFound = false
								LrLogger:warn(photoFilename..' - REG NOT FOUND: no metadata found for registration '..searchRegistration)
								-- mark photo with keyword reg_not_found
								catalog:withWriteAccessDo('set keyword',
								function()
									photo:addKeyword(keywordRegNotFound)
								end)
							else
								-- lookup returned something usefull
								foundRegistration = extractMetadata(content, LrPrefs.prefRegistrationToken1, LrPrefs.prefRegistrationToken2)
								-- check if lookup returned the right registration
								if searchRegistration == foundRegistration then
									-- yes, isolate metadata
									foundAirline = extractMetadata(content, LrPrefs.prefAirlineToken1, LrPrefs.prefAirlineToken2)
									foundAircraft = extractMetadata(content, LrPrefs.prefAircraftToken1, LrPrefs.prefAircraftToken2)
									foundAircraftManufacturer = extractMetadata(content, LrPrefs.prefManufacturerToken1, LrPrefs.prefManufacturerToken2)
									foundAircraftType = LrStringUtils.trimWhitespace(string.sub(foundAircraft, string.len(foundAircraftManufacturer)+1, string.len(foundAircraft)))
									-- cache found metadata
									metadataCache[searchRegistration] = {foundRegistration = foundRegistration, foundAirline = foundAirline, foundAircraft = foundAircraft, foundAircraftManufacturer = foundAircraftManufacturer, foundAircraftType = foundAircraftType, lookupURL = lookupURL}
									LrLogger:info(photoFilename..' - metadata found: Reg: '..foundRegistration..', Airline: '..foundAirline..', Manufacturer: '..foundAircraftManufacturer..', Type: '..foundAircraftType)
								else
									-- no, lookup returned wrong registration
									LrLogger:warn(photoFilename..' - WRONG REG: lookup returned wrong registration: '..foundRegistration..' instead of '..searchRegistration)
									countNoReg = countNoReg + 1
									flagRegFound = false
									-- mark photo with keyword wrong_reg
									catalog:withWriteAccessDo('set keyword',
									function()
										photo:addKeyword(keywordWrongReg)
									end)
								end
							end
						else
							-- yes, use cached metadata
							LrLogger:info(photoFilename..' - using cached metadata for: '..metadataCache[searchRegistration].foundRegistration)
							countCacheHit = countCacheHit + 1
						end
						-- check if we have a reg and user did not hit cancel
						if flagRegFound and not progressScope:isCanceled()then
							-- write metadata to photo
							catalog:withWriteAccessDo('set aircraft metadata',
							function()
								writeMetadata(photo, 'registration', metadataCache[searchRegistration].foundRegistration)
								writeMetadata(photo, 'airline', metadataCache[searchRegistration].foundAirline)
								writeMetadata(photo, 'aircraft_manufacturer', metadataCache[searchRegistration].foundAircraftManufacturer)
								writeMetadata(photo, 'aircraft_type', metadataCache[searchRegistration].foundAircraftType)
								-- set aircraft url - we overwrite this in any case
								photo:setPropertyForPlugin(_PLUGIN, 'aircraft_url', metadataCache[searchRegistration].lookupURL)
								-- remove keywords if set
								photo:removeKeyword(keywordRegNotFound)
								photo:removeKeyword(keywordWrongReg)
							end)
						end
					else
						-- photo has no registration
						LrLogger:info(photoFilename..' - no registration set')
						countNoReg = countNoReg + 1
					end
					-- update progress bar
					progressScope:setPortionComplete(countProcessed, countSelected)
				end
			end
			LrLogger:info('processed '..countProcessed..' photos ('..countLookup..' web lookups, '..countRegNotFound..' regs not found, '..countCacheHit..' cache hits, '..countNoReg..' without reg)')
			progressScope:done()
		end
		LrDialogs.showBezel(messageEnd)
		LrLogger:info('>>>> done')
	end)
end

------- writeMetadata() -------------------------------------------------------
-- write metadata to db fields
function writeMetadata(photo, fieldName, fieldValue)
	-- check if field is empty
	if photo:getPropertyForPlugin(_PLUGIN, fieldName) == nil then
		-- yes, write to empty field
		photo:setPropertyForPlugin(_PLUGIN, fieldName, fieldValue)
	else
		-- check if user allows overwrite of existing metadata
		if LrPrefs.prefFlagOverwrite then
			-- yes, overwrite existing entry
			photo:setPropertyForPlugin(_PLUGIN, fieldName, fieldValue)
		end
	end
end

------- extractMetadata() -----------------------------------------------------
-- isolate metadata - sorry, creepy html parsing, no fancy things like JSON available
function extractMetadata(payload, Token1, Token2)
	posStart, posEnd = string.find(payload, Token1)
	if posEnd == nil then
		LrLogger:error('Token '..Token1..' not found.')
		LrErrors.throwUserError('Token "'..Token1..'" not found.')
	else
		line = string.sub(payload, posEnd + 1)
		--LrDialogs.message('Lookup Airline - after Token 1', line, 'info')
		posStart, posEnd = string.find(line, Token2)
		if posStart == nil then
			LrLogger:error('Token '..Token2..' not found.')
			LrErrors.throwUserError('Token "'..Token2..'" not found.')
		else
			line = LrStringUtils.trimWhitespace(string.sub(line, 1, posStart - 1))
			--LrDialogs.message('Lookup Airline - after Token 2', line, 'info')
			if line == '' then
				line = 'not set'
			end
			return line
		end
	end
end


import 'LrTasks'.startAsyncTask(AircraftMetadataImport)
