
// Delete previous data

MATCH (n) DETACH DELETE n;



// Load the stations

LOAD CSV WITH HEADERS 
FROM 'https://raw.githubusercontent.com/cdugeai/graph-paris-transport/main/stations.csv' AS row
CREATE (s:Station {
	name: row.station, 
	line: row.line, 
	coordinates: point({
		x: toFloat(row.x), 
		y: toFloat(row.y)
	}),
	zone: row.zone
})
return s.line;



// Create the relationships of station connections between metro lines
MATCH (s1:Station)
MATCH (s2:Station)
WHERE s1.name = s2.name AND s1.line <> s2.line
CREATE 
	(s1)
	-[c:TRAVEL {mean: 'foot', _type:'connection', price:0, time:1, line:'underground'}]
	->(s2)
;


// Load the connections
LOAD CSV WITH HEADERS 
FROM 'https://raw.githubusercontent.com/cdugeai/graph-paris-transport/main/connections.csv' AS row
MATCH (s_dep:Station) 
	WHERE s_dep.name = row.from AND s_dep.line = toString(row.line)
MATCH (s_arr:Station) 
	WHERE s_arr.name = row.to AND s_arr.line = toString(row.line)
CREATE 
	(s_dep)
	-[:TRAVEL {mean:row.mean, _type: 'travel', price: row.price, time: row.time, line: row.line}]
	->(s_arr)
;




// Shortest path algorithm (work in progress)

MATCH path = (p1:Station {name:'Massy'}),(p2:Station {name:'Juilliottes'})
CALL apoc.algo.dijkstra(p1, p2, 'TRAVEL', 'price') YIELD weight AS total_price
RETURN p1.name, p2.name, total_price ORDER BY total_price



MATCH 
	(p1:Station {name:'Massy'}),
	(p2:Station {name:'Juilliottes'})
CALL 
	apoc.algo.dijkstra(p1, p2, 'TRAVEL', 'price') 
	YIELD path AS path, weight AS weight
RETURN path, weight