--[[----------------------------------------------------------------------------
AircraftMetadataProviderJP.lua
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

------- lookupMetadataJP() ----------------------------------------------------
-- lookup metadata on jetphotos
function lookupMetadataJP(photoLogFilename, searchRegistration)
	local result, foundRegistration, foundAirline, foundAircraft, foundAircraftManufacturer, foundAircraftType, lookupURL
	local flagLookupResult = ''

	lookupURL = LrStringUtils.trimWhitespace(LrPrefs.prefLookupUrl)..searchRegistration
	LrLogger:info(photoLogFilename..' - looking up registration at '..lookupURL..' for: '..searchRegistration)
	-- do the lookup
	result = LrHttp.get(lookupURL)
	--LrLogger:debug('HTTP lookup returned: '..result)
	-- check if lookup returned something useful
	if string.find(result, LrPrefs.prefSuccessfulSearch) == nil then
		-- lookup returned nothing useful
		flagLookupResult = 'reg_not_found'
	else
		-- yes, lookup returned something useful
		foundRegistration = string.upper(extractMetadata(result, LrPrefs.prefRegistrationToken1, LrPrefs.prefRegistrationToken2))
		-- check if lookup returned the right registration
		if searchRegistration == foundRegistration then
			-- yes, isolate metadata
			foundAirline = extractMetadata(result, LrPrefs.prefAirlineToken1, LrPrefs.prefAirlineToken2)
			foundAircraft = extractMetadata(result, LrPrefs.prefAircraftToken1, LrPrefs.prefAircraftToken2)
			foundAircraftManufacturer = extractMetadata(result, LrPrefs.prefManufacturerToken1, LrPrefs.prefManufacturerToken2)
			-- check is we could isolate Manufacturer
			if foundAircraftManufacturer == 'not set' then
				-- no set foundAircraft as fallback
				foundAircraftType = foundAircraft
			else
				-- yes, isolate type
				foundAircraftType = LrStringUtils.trimWhitespace(string.sub(foundAircraft, string.len(foundAircraftManufacturer)+1, string.len(foundAircraft)))
			end
			flagLookupResult = 'success'
		else
			-- no, lookup returned wrong registration
			flagLookupResult = 'wrong_reg'
		end
	end
	return flagLookupResult, foundRegistration, foundAirline, foundAircraft, foundAircraftManufacturer, foundAircraftType, lookupURL

end

------- extractMetadata() -----------------------------------------------------
-- isolate metadata - sorry, creepy html parsing, no fancy things like JSON available
function extractMetadata(payload, Token1, Token2)
	local posStart, posEnd, line
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
