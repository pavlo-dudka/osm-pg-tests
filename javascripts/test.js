function showMap(geoJson)
{
	var map = L.map('map').setView([49, 31], 6);
	map.addControl(new L.Control.Permalink());

	var copyright = '&copy; <a href="http://openstreetmap.org/copyright">OpenStreetMap</a> contributors';
	if (geoJson.substring(0,6) == 'geojson/peirce')
	{
		copyright = copyright + ' | <a href="http://peirce.gis-lab.info/qa/UA">Errors</a> found by <a href="http://openstreetmap.org/user/Zkir">Zkir</a>';
	}
	
	L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
		maxZoom: 19,
		attribution: copyright
	}).addTo(map);			
	
	showGeoJson(map, geoJson);
}
function showGeoJson(map, geoJson)
{
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open('GET', geoJson, false);
	xmlhttp.send(null);
	var mypoints = eval('(' + xmlhttp.responseText + ')');
	
	var geoJsonLayer = L.geoJson(mypoints, {
		onEachFeature: function (feature, layer) {
		layer.bindPopup(popupHtml(feature)).openPopup();
		}
	});

	//map.addLayer(geoJsonLayer);
	var markers = L.markerClusterGroup();
	markers.addLayer(geoJsonLayer);
	map.addLayer(markers);
}

function errorTypeClick(cb)
{
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open('GET', cb.name, false);
	xmlhttp.send(null);
	var mypoints = eval('(' + xmlhttp.responseText + ')');
	
	var geoJsonLayer = L.geoJson(mypoints, {
		onEachFeature: function (feature, layer) {
		layer.bindPopup(popupHtml(feature)).openPopup();
		}
	});

	//map.addLayer(geoJsonLayer);
	var markers = L.markerClusterGroup();
	markers.addLayer(geoJsonLayer);
	map.addLayer(markers);
}

function popupHtml(feature)
{
	var result = '<table>';
	if (typeof(feature.properties.name) != "undefined")
	{
		result += '<tr><th>Name:</th><td>' + feature.properties.name + '</td></tr>';
	}
	if (typeof(feature.properties.nameuk) != "undefined")
	{
		result += '<tr><th>Name(ukr):</th><td>' + feature.properties.nameuk + '</td></tr>';
	}
	if (typeof(feature.properties.josm) != "undefined")
	{
		var objects = feature.properties.josm.split(',');
		for(var i=0; i < objects.length; i++)
		{
			if (objects[i].indexOf('n') == 0)
				objects[i] = '<a href="http://www.openstreetmap.org/node/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
			if (objects[i].indexOf('w') == 0)
				objects[i] = '<a href="http://www.openstreetmap.org/way/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
			if (objects[i].indexOf('r') == 0)
				objects[i] = '<a href="http://www.openstreetmap.org/relation/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
		}
		result += '<tr><th>Related objects:</th><td>' + objects.join(', ') + '</td></tr>';
	}
	if (typeof(feature.properties.relationtags) != "undefined")
	{
		var tvs = feature.properties.relationtags.split('&');
		for(var i=0; i < tvs.length; i++)
		{
			var tv = tvs[i].split('|');
			result += '<tr><th>Relation ' + tv[0] +':</th><td>' + tv[1] + '</td></tr>';
		}
	}
	if (typeof(feature.properties.membertags) != "undefined")
	{
		var tv = feature.properties.membertags.split('|');
		result += '<tr><th>Member ' + tv[0] +':</th><td>' + tv[1] + '</td></tr>';
	}
	if (typeof(feature.properties.addrhousenumber) != "undefined")
	{
		result += '<tr><th>House number:</th><td>' + feature.properties.addrhousenumber + '</td></tr>';
	}
	if (typeof(feature.properties.region) != "undefined")
	{
		result += '<tr><th>Region:</th><td><a href="http://peirce.zkir.ru/qa/' + feature.properties.region + '">' + feature.properties.region + '</a></td></tr>';
	}
	if (typeof(feature.properties.city) != "undefined")
	{
		result += '<tr><th>City:</th><td>' + feature.properties.city + '</td></tr>';
	}
	if (typeof(feature.properties.level) != "undefined")
	{
		result += '<tr><th>Level:</th><td>' + feature.properties.level + '</td></tr>';
	}
	if (typeof(feature.properties.NumberOfRoads) != "undefined")
	{
		result += '<tr><th>Roads count:</th><td>' + feature.properties.NumberOfRoads + '</td></tr>';
	}

	result += '<tr><th>Coordinates:</th><td>' + feature.geometry.coordinates + '</td></tr>';
	result = result + '</table>';
	
	result += '<input type="button" value="Edit in JOSM" onClick="openInJosm(\'' + feature.properties.josm + '\',\'' + feature.geometry.coordinates + '\')">';
	result += '<input type="button" value="Edit in Browser" onClick="openInBrowser(\'' + feature.geometry.coordinates + '\')">';
	
	return result;
}

function showTable(geoJson)
{
	document.write('<table>');

	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open('GET', geoJson, false);
	xmlhttp.send(null);
	var mypoints = eval('(' + xmlhttp.responseText + ')');
	
	for(j = 0; j < mypoints.features.length - 1; j++)
	{
		var feature = mypoints.features[j];
		if (j == 0)
		{
			document.write('<tr>');
			document.write('<th>#</th>');
			document.write('<th>Josm</th>');
			
			if (typeof(feature.properties.name) != "undefined")
			{
				document.write('<th>Name</th>');
			}
			if (typeof(feature.properties.nameuk) != "undefined")
			{
				document.write('<th>Name:uk</th>');
			}
			if (typeof(feature.properties.relationtags) != "undefined")
			{
				document.write('<th>Relation</th>');
			}
			if (typeof(feature.properties.membertags) != "undefined")
			{
				document.write('<th>Member</th>');
			}
			if (typeof(feature.properties.addrhousenumber) != "undefined")
			{
				document.write('<th>House No.</th>');
			}
			if (typeof(feature.properties.region) != "undefined")
			{
				document.write('<th>Region</th>');
			}
			if (typeof(feature.properties.city) != "undefined")
			{
				document.write('<th>City</th>');
			}
			if (typeof(feature.properties.level) != "undefined")
			{
				document.write('<th>Level</th>');
			}
			if (typeof(feature.properties.NumberOfRoads) != "undefined")
			{
				document.write('<th>Roads count</th>');
			}
			
			if (typeof(feature.properties.josm) != "undefined")
			{
				document.write('<th>Objects</th>');
			}
			document.write('</tr>');
		}
		
		document.write('<tr>');		
		document.write('<td>' + (j+1) + '</td>');
		document.write('<td><input type="button" value="Edit" onClick="openInJosm(\'' + feature.properties.josm + '\',\'' + feature.geometry.coordinates + '\')"></td>');
		
		if (typeof(feature.properties.name) != "undefined")
		{
			document.write('<td>' + feature.properties.name + '</td>');
		}
		if (typeof(feature.properties.nameuk) != "undefined")
		{
			document.write('<td>' + feature.properties.nameuk + '</td>');
		}
		if (typeof(feature.properties.relationtags) != "undefined")
		{
			var tvs = feature.properties.relationtags.split('&');
			for(var i=0; i < tvs.length; i++)
			{
				var tv = tvs[i].split('|');
				document.write('<td>' + tv[1] + '</td>');
			}
		}
		if (typeof(feature.properties.membertags) != "undefined")
		{
			var tv = feature.properties.membertags.split('|');
			document.write('<td>' + tv[1] + '</td>');
		}
		if (typeof(feature.properties.addrhousenumber) != "undefined")
		{
			document.write('<td>' + feature.properties.addrhousenumber + '</td>');
		}
		if (typeof(feature.properties.region) != "undefined")
		{
			document.write('<td><a href="http://peirce.zkir.ru/qa/' + feature.properties.region + '">' + feature.properties.region + '</a></td>');
		}
		if (typeof(feature.properties.city) != "undefined")
		{
			document.write('<td>' + feature.properties.city + '</td>');
		}
		if (typeof(feature.properties.level) != "undefined")
		{
			document.write('<td>' + feature.properties.level + '</td>');
		}
		if (typeof(feature.properties.NumberOfRoads) != "undefined")
		{
			document.write('<td>' + feature.properties.NumberOfRoads + '</td>');
		}

		if (typeof(feature.properties.josm) != "undefined")
		{
			var objects = feature.properties.josm.split(',');
			for(var i=0; i < objects.length; i++)
			{
				if (objects[i].indexOf('n') == 0)
					objects[i] = '<a href="http://www.openstreetmap.org/node/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
				if (objects[i].indexOf('w') == 0)
					objects[i] = '<a href="http://www.openstreetmap.org/way/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
				if (objects[i].indexOf('r') == 0)
					objects[i] = '<a href="http://www.openstreetmap.org/relation/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
			}
			document.write('<td>' + objects.join(', ') + '</td>');
		}
		
		document.write('</tr>');
	}
	
	document.write('</table>');
}

function openInJosm(load, point)
{
    if (load != "undefined")
    {
        var xmlhttp = new XMLHttpRequest();
        xmlhttp.open('GET', josmLoadObject(load), false);
        xmlhttp.send(null);
            
        var xmlhttp2 = new XMLHttpRequest();
        xmlhttp2.open('GET', josmZoomToPoint(point), false);
        xmlhttp2.send(null);
	}
    else
    {
        var xmlhttp = new XMLHttpRequest();
        xmlhttp.open('GET', josmZoomAndLoadToPoint(point), false);
        xmlhttp.send(null);
    }
}

function openInBrowser(point)
{
	var coords = point.split(',');
	var win=window.open('http://www.openstreetmap.org/edit?#map=19/' + coords[1] + '/' + coords[0], '_blank');
	win.focus();
}

function josmLoadObject(load)
{
	return 'http://localhost:8111/load_object?new_layer=false&objects=' + load;
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