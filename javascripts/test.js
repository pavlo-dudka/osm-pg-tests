function showGeoJson(geoJson)
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
				objects[i] = '<a href="http://www.openstreetmap.org/browse/node/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
			if (objects[i].indexOf('w') == 0)
				objects[i] = '<a href="http://www.openstreetmap.org/browse/way/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
			if (objects[i].indexOf('r') == 0)
				objects[i] = '<a href="http://www.openstreetmap.org/browse/relation/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
		}
		result += '<tr><th>Related objects:</th><td>' + objects.join(',') + '</td></tr>';
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

	result += '<tr><th>Coordinates:</th><td>' + feature.geometry.coordinates + '</td></tr>';
	result = result + '</table>';
	
	result += '<input type="button" value="Open in JOSM" onClick="openInJosm(\'' + feature.properties.josm + '\',\'' + feature.geometry.coordinates + '\')">';
	result += '<input type="button" value="Open in iD" onClick="openInID(\'' + feature.geometry.coordinates + '\')">';
	
	return result;
}

function openInJosm(load, point)
{
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open('GET', josmLoadObject(load), false);
	xmlhttp.send(null);
	
	var xmlhttp2 = new XMLHttpRequest();
	xmlhttp2.open('GET', josmZoomToPoint(point), false);
	xmlhttp2.send(null);			
}

function openInID(point)
{
	var coords = point.split(',');
	var win=window.open('http://www.openstreetmap.org/edit?editor=id#map=18/' + coords[1] + '/' + coords[0], '_blank');
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
