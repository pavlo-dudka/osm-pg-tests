function showMap(geoJson, diff)
{
	var map = L.map('map').setView([49, 31], 6);
	map.addControl(new L.Control.Permalink());
	
	L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
		maxZoom: 19,
		attribution: '&copy; <a href="http://openstreetmap.org/copyright" target="_blank">OpenStreetMap</a> contributors'
	}).addTo(map);

	if (geoJson.indexOf("railway.dead.ends") > 0)
	{
		L.tileLayer('http://{s}.tiles.openrailwaymap.org/standard/{z}/{x}/{y}.png', {
			maxZoom: 19,
			attribution: '<a href="http://www.openrailwaymap.org/" target="_blank">OpenRailwayMap</a>'
		}).addTo(map);
	}
	if (geoJson.indexOf("decommunization") > 0)
	{
		var data = '{"version": "1.3.1","layers": [{"type": "cartodb", "options": {"cartocss_version": "2.1.1", "cartocss": "#decommunization{line-color: #F22; line-width: 5; line-opacity: 0.5;}","sql": "select * from decommunization"}}]}';
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open('POST', 'http://dudka.cartodb.com/api/v1/map', false);
		xmlhttp.setRequestHeader('Content-Type', 'application/json');
		xmlhttp.send(data);
		var response = eval('(' + xmlhttp.responseText + ')');

		L.tileLayer('https://dudka.cartodb.com/api/v1/map/' + response.layergroupid + '/0/{z}/{x}/{y}.png', {
			maxZoom: 19
		}).addTo(map);
	}
	if (geoJson.indexOf("place.districts") > 0)
	{
		var data = '{"version": "1.3.1","layers": [{"type": "cartodb", "options": {"cartocss_version": "2.1.1", "cartocss": "#all_t{line-color: #F22; line-width: 1; line-opacity: 1;}","sql": "select * from all_t where koatuu::text not like \'%00000000\'"}}]}';
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open('POST', 'http://dudka.cartodb.com/api/v1/map', false);
		xmlhttp.setRequestHeader('Content-Type', 'application/json');
		xmlhttp.send(data);
		var response = eval('(' + xmlhttp.responseText + ')');

		L.tileLayer('https://dudka.cartodb.com/api/v1/map/' + response.layergroupid + '/0/{z}/{x}/{y}.png', {
			maxZoom: 19
		}).addTo(map);
	}
	
	showGeoJson(map, geoJson, diff);
}

function showGeoJson(map, geoJson, diff)
{
	var xmlhttp = new XMLHttpRequest();
	if (typeof(diff) != "undefined")
		geoJson = "http://51.15.73.151:8080/errors/" + geoJson.substring(8).replace('.geojson','') + "/since/"+ diff;
	xmlhttp.open('GET', geoJson, false);
	xmlhttp.send(null);
	
	var myGeoJson = eval('(' + xmlhttp.responseText + ')');	
	if (myGeoJson.features.length == 1);
	else if (myGeoJson.features[0].geometry.type == 'Point' || myGeoJson.no_markers == 'true')
	{
		var geoJsonLayer = L.geoJson(myGeoJson, {
			onEachFeature: function (feature, layer) {
				layer.bindPopup(popupHtml(feature, myGeoJson.errorDescr));
			}
		});
		
		var markers = L.markerClusterGroup();
		markers.addLayer(geoJsonLayer);
		map.addLayer(markers);
	}
	else
	{
		var myGeoJsonPoints = eval('(' + xmlhttp.responseText + ')');	
		for (var i = 0; i < myGeoJson.features.length - 1; i++)
		{			
			myGeoJsonPoints.features[i].geometry.type = 'Point';
			if (myGeoJson.features[0].geometry.type == 'GeometryCollection')
			{
				myGeoJsonPoints.features[i].geometry.coordinates = myGeoJson.features[i].geometry.geometries[0].coordinates;
				myGeoJson.features[i].geometry.geometries = myGeoJson.features[i].geometry.geometries.slice(1);
			}
			else if (myGeoJsonPoints.features[i].geometry.coordinates[0][0] instanceof Array)
				myGeoJsonPoints.features[i].geometry.coordinates = myGeoJson.features[i].geometry.coordinates[0][Math.floor(myGeoJson.features[i].geometry.coordinates[0].length / 2)];
			else
				myGeoJsonPoints.features[i].geometry.coordinates = myGeoJson.features[i].geometry.coordinates[Math.floor(myGeoJson.features[i].geometry.coordinates.length / 2)];
		}
		
		var geoJsonLayer = L.geoJson(myGeoJson, {
			onEachFeature: function (feature, layer) {
				layer.bindPopup(popupHtml(feature, myGeoJson.errorDescr));
			}
		});

		
		map.addLayer(geoJsonLayer);

		var geoJsonLayer2 = L.geoJson(myGeoJsonPoints, {
			onEachFeature: function (feature, layer) {
				layer.bindPopup(popupHtml(feature, myGeoJsonPoints.errorDescr));
			}
		});

		var markers = L.markerClusterGroup();
		markers.addLayer(geoJsonLayer2);
		map.addLayer(markers);
	}	
}

var featureProperties = new Map([
	['name', 'Name'],
	['nameuk', 'Name(ukr)'],
	['denomination', 'Denomination'],
	['relationtags', 'Relation tag'],
	['membertags', 'Member tag'],
	['memberrole', 'Member Role'],
	['addrhousenumber', 'House No.'],
	['cur_district', 'Current district'],
	['exp_district', 'Expected district'],
	['region', 'Region'],
	['city', 'City'],
	['population', 'Population'],
	['koatuu', 'KOATUU'],
	['length', 'Length (km)'],
	['level', 'Level'],
	['address', 'Address'],
	['old_name', 'Old name'],
	['new_name', 'New name'],
	['levels', 'Building Levels'],
	['NumberOfRoads', 'Roads count'],
	['josm', 'Objects']
]);
function popupHtml(feature, errorDescr)
{
	var result = '';
	if (typeof(feature.properties.error) != "undefined")
	{
		result += '<center><b><font color="FF0000">' + feature.properties.error + '</font></b></center>';
	}
	else if (typeof(errorDescr) != "undefined")
	{
		result += '<center><b><font color="FF0000">' + errorDescr + '</font></b></center>';
	}
	result += '<table>';
	for (var [prop, propName] of featureProperties)
	{
		var value = feature.properties[prop];
		if (typeof(value) == "undefined")
			continue;
		
		switch (prop)
		{
			case 'josm':
				var objects = feature.properties.josm.split(',');
				for (var i = 0; i < objects.length; i++)
				{
					if (objects[i].indexOf('n') == 0)
						objects[i] = '<a href="https://www.openstreetmap.org/node/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
					if (objects[i].indexOf('w') == 0)
						objects[i] = '<a href="https://www.openstreetmap.org/way/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
					if (objects[i].indexOf('r') == 0)
						objects[i] = '<a href="https://www.openstreetmap.org/relation/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
				}
				value = objects.join(', ');
				result += '<tr><th>' + propName + ':</th><td>' + value + '</td></tr>';
				break;
			case 'relationtags':
				var tvs = value.split('&');
				for (var i = 0; i < tvs.length; i++)
				{
					var tv = tvs[i].split('|');
					result += '<tr><th>Relation ' + tv[0] + ':</th><td>' + tv[1] + '</td></tr>';
				}
				break;
			case 'membertags':
				var tv = value.split('|');
				result += '<tr><th>Member ' + tv[0] + ':</th><td>' + tv[1] + '</td></tr>';
				break;
			default:
				result += '<tr><th>' + propName + ':</th><td>' + value + '</td></tr>';
		}
	}

	if (feature.geometry.type == 'Point')
		result += '<tr><th>Coordinates:</th><td><a href="geo:' + feature.geometry.coordinates.slice().reverse().join(',') + '">' + feature.geometry.coordinates + '<a></td></tr>';
	result = result + '</table>';
	
	result += '<input type="button" value="Edit in JOSM" onClick="openInJosm(\'' + feature.properties.josm + '\',\'' + feature.properties.addtags + '\',\'' + feature.geometry.coordinates + '\')">';
	result += '<input type="button" value="Edit in Browser" onClick="openInBrowser(\'' + feature.geometry.coordinates + '\')">';
	
	return result;
}

function showTable(geoJson, diff)
{
	document.write('<table class="sortable uk-table uk-table-small uk-table-hover uk-table-divider">');

	var xmlhttp = new XMLHttpRequest();
	if (typeof(diff) != "undefined")
		geoJson = "http://51.15.73.151:8080/errors/" + geoJson.substring(8).replace('.geojson','') + "/since/"+ diff;
	xmlhttp.open('GET', geoJson, false);
	xmlhttp.send(null);
	var mypoints = eval('(' + xmlhttp.responseText + ')');
	
	for (j = 0; j < mypoints.features.length - 1; j++)
	{
		var feature = mypoints.features[j];
		if (j == 0)
		{
			document.write('<tr>');
			document.write('<th class="sorttable_sorted">#<span id="sorttable_sortfwdind">' + (stIsIE ? '&nbsp<font face="webdings">6</font>' : '&nbsp;&#x25BE;') + '</span></th>');
			document.write('<th>Josm</th>');
			
			for (var [prop, propName] of featureProperties)
			{
				var value = feature.properties[prop];
				if (typeof(value) == "undefined")
					continue;
				
				switch (prop)
				{					
					case 'relationtags':
						document.write('<th>' + propName +'</th>');
						if (value.indexOf('&') > -1)
							document.write('<th>' + propName +'</th>');
						break;
					default:
						document.write('<th>' + propName +'</th>');
				}
			}
			
			if (typeof(feature.properties.josm) != "undefined")
			{
				document.write('<th>Objects</th>');
			}
			document.write('</tr>');
		}
		
		// tooltip
		document.write('<tr title="');
		if (typeof(feature.properties.error) != "undefined")
		{
			document.write(feature.properties.error);
		}
		else if (typeof(mypoints.errorDescr) != "undefined")
		{
			document.write(mypoints.errorDescr);
		}
		document.write('">');
		document.write('<td>' + (j+1) + '</td>');
		document.write('<td><input type="button" class="uk-button uk-button-small uk-button-primary" value="Edit" onClick="openInJosm(\'' + feature.properties.josm + '\',\'' + (feature.properties.addtags || '') + '\',\'' + feature.geometry.coordinates + '\')"></td>');
		
		for (var [prop, propName] of featureProperties)		{
			var value = feature.properties[prop];
			if (typeof(value) == "undefined")
				continue;
			
			switch (prop)
			{
				case 'josm':
					var objects = feature.properties.josm.split(',');
					for(var i = 0; i < objects.length; i++)
					{
						if (objects[i].indexOf('n') == 0)
							objects[i] = '<a href="https://www.openstreetmap.org/node/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
						if (objects[i].indexOf('w') == 0)
							objects[i] = '<a href="https://www.openstreetmap.org/way/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
						if (objects[i].indexOf('r') == 0)
							objects[i] = '<a href="https://www.openstreetmap.org/relation/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
					}
					document.write('<td>' + objects.join(', ') + '</td>');
					break;
				case 'relationtags':
					var tvs = feature.properties.relationtags.split('&');
					for (var i = 0; i < Math.min(tvs.length, 2); i++)
					{
						var tv = tvs[i].split('|');
						document.write('<td>' + tv[1] + '</td>');
					}
					break;
				case 'membertags':
					var tv = feature.properties.membertags.split('|');
					document.write('<td>' + tv[1] + '</td>');
					break;
				default:
					document.write('<td>' + value + '</td>');
			}
		}
		
		document.write('</tr>');
	}
	
	document.write('</table>');
}

function openInJosm(load, addtags, point)
{
    if (load)
    {
        var xmlhttp = new XMLHttpRequest();
        xmlhttp.open('GET', josmLoadObject(load), false);
        xmlhttp.send(null);
    }

    if (addtags)
    {
        var xmlhttp = new XMLHttpRequest();
        xmlhttp.open('GET', josmAddNode(point, addtags), false);
        xmlhttp.send(null);
    }

    {
        var xmlhttp2 = new XMLHttpRequest();
        xmlhttp2.open('GET', josmZoomAndLoadToPoint(point), false);
        xmlhttp2.send(null);
    }
}

function openInBrowser(point)
{
	var coords = point.split(',');
	var win = window.open('http://www.openstreetmap.org/edit?#map=19/' + coords[1] + '/' + coords[0], '_blank');
	win.focus();
}

function josmLoadObject(load)
{
	return 'http://localhost:8111/load_object?new_layer=false&objects=' + load;
}

function josmAddNode(point, tags)
{
	var coords = point.split(',');
	return 'http://localhost:8111/add_node?lat=' + coords[1] + '&lon=' + coords[0] + '&addtags=' + tags.replace('|', '%7C');
}

function josmZoomToPoint(point)
{
	var coords = point.split(',');
	var left = coords[0]-0.001;
	var right = Number(coords[0])+0.001;
	var top = coords[1]-0.001;
	var bottom = Number(coords[1])+0.001;
	
	return 'http://localhost:8111/zoom?left=' + left + '&right=' + right + '&top=' + top + '&bottom=' + bottom;
}

function josmZoomAndLoadToPoint(point)
{
	var coords = point.split(',');
	var left = coords[0]-0.001;
	var right = Number(coords[0])+0.001;
	var bottom = coords[1]-0.001;
	var top = Number(coords[1])+0.001;
    	
	return 'http://localhost:8111/load_and_zoom?left=' + left + '&right=' + right + '&top=' + top + '&bottom=' + bottom;
}