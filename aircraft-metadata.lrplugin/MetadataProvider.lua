--[[----------------------------------------------------------------------------
MetadataProvider.lua
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
return {
	schemaVersion = 15,

	metadataFieldsForPhotos = {
		{dataType='string', searchable=true, browsable=true, id='registration', title='Registration'},
		{dataType='string', searchable=true, browsable=true, id='aircraft_manufacturer', title='Manufacturer'},
		{dataType='string', searchable=true, browsable=true, id='aircraft_type', title='Type'},
		{dataType='string', searchable=true, browsable=true, id='aircraft_notes', title='Notes'},
		{dataType='string', searchable=true, browsable=true, id='airline', title='Airline'},
		{dataType='url', searchable=false, browsable=false, readOnly=true, id='aircraft_url', title='Aircraft URL'},
		{dataType='string', searchable=true, browsable=true, id='airport_iata', title='Airport (IATA)'},
		--{dataType='string', searchable=true, browsable=true, id='flight', title='Flight'},
		--{dataType='string', searchable=true, browsable=true, id='flight_from', title='from'},
		--{dataType='string', searchable=true, browsable=true, id='flight_to', title='to'},
	}
}
