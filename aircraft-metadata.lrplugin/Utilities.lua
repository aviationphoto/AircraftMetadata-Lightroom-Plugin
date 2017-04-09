--[[----------------------------------------------------------------------------
Utilities.lua
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

------- Lightroom API ---------------------------------------------------------
LrApplication = import 'LrApplication'
LrFunctionContext = import 'LrFunctionContext'
LrDialogs = import 'LrDialogs'
LrFileUtils = import 'LrFileUtils'
LrPathUtils = import 'LrPathUtils'
LrHttp = import 'LrHttp'
LrProgressScope = import 'LrProgressScope'
LrErrors = import 'LrErrors'
LrStringUtils = import 'LrStringUtils'

prefs = import 'LrPrefs'.prefsForPlugin()
logger = import 'LrLogger'('AircraftMetadata')

------- clearLogfile() --------------------------------------------------------
-- clear old logfile
function clearLogfile()
	local logPath = LrPathUtils.child(LrPathUtils.getStandardFilePath('documents'), 'AircraftMetadata.log')
		if LrFileUtils.exists( logPath ) then
			success, reason = LrFileUtils.delete( logPath )
			if not success then
				logger:error('error deleting existing logfile!'..reason)
			end
	end
end

------- loadPrefs() -----------------------------------------------------------
-- load saved preferences
function loadPrefs()
	-- lookup KeywordRegNotFound
	if (prefs.prefKeywordRegNotFound == nil or prefs.prefKeywordRegNotFound == '') then
		LrErrors.throwUserError('Please set KeywordRegNotFound')
	end
	-- lookup URL
	if (prefs.prefLookupUrl == nil or prefs.prefLookupUrl == '') then
		LrErrors.throwUserError('Please set URL for lookup')
	end
	-- lookup RegistrationToken1
	if (prefs.prefRegistrationToken1 == nil or prefs.prefRegistrationToken1 == '') then
		LrErrors.throwUserError('Please set registration token 1')
	end
	-- lookup RegistrationToken2
	if (prefs.prefRegistrationToken2 == nil or prefs.prefRegistrationToken2 == '') then
		LrErrors.throwUserError('Please set registration token 2')
	end
	-- lookup AirlineToken1
	if (prefs.prefAirlineToken1 == nil or prefs.prefAirlineToken1 == '') then
		LrErrors.throwUserError('Please set airline token 1')
	end
	-- lookup AirlineToken2
	if (prefs.prefAirlineToken2 == nil or prefs.prefAirlineToken2 == '') then
		LrErrors.throwUserError('Please set airline token 2')
	end
	-- lookup AircraftToken1
	if (prefs.prefAircraftToken1 == nil or prefs.prefAircraftToken1 == '') then
		LrErrors.throwUserError('Please set aircraft token 1')
	end
	-- lookup AircraftToken2
	if (prefs.prefAircraftToken2 == nil or prefs.prefAircraftToken2 == '') then
		LrErrors.throwUserError('Please set aircraft token 2')
	end
	-- lookup ManufacturerToken1
	if (prefs.prefManufacturerToken1 == nil or prefs.prefManufacturerToken1 == '') then
		LrErrors.throwUserError('Please set manufacturer token 1')
	end
	-- lookup ManufacturerToken2
	if (prefs.prefManufacturerToken2 == nil or prefs.prefManufacturerToken2 == '') then
		LrErrors.throwUserError('Please set manufacturer token 2')
	end
end
