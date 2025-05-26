require("Set")

-- https://wiki.openstreetmap.org/wiki/DE:Key:highway
-- https://wiki.openstreetmap.org/wiki/Attribuierung_von_Stra%C3%9Fen_in_Deutschland
-- We keep the different highway classes separate so we can use them for filtering
-- to combine them use the function JoinSets in the ~/topics/helper/JoinSets

-- "*_link" bedeutet "Autobahnzubringer", "Anschlussstelle", "Auf- / Abfahrt"
-- 
 -- way["highway"="cycleway"];
 --  way["highway"="path"]["bicycle"!="no"]["bicycle"!="dismount"];
 --  way["highway"="footway"]["bicycle"="yes"];
 --  way["highway"="footway"]["bicycle"="designated"];
 --  way["highway"="footway"]["bicycle"="permissive"];
 --  way["highway"="bridleway"]["bicycle"="yes"];
 --  way["highway"="bridleway"]["bicycle"="designated"];
 --  way["highway"="bridleway"]["bicycle"="permissive"];
 --  way["highway"="steps"]["bicycle"="yes"];
 --  way["highway"="steps"]["bicycle"="designated"];
 --  way["highway"="steps"]["bicycle"="permissive"];

 --  way["highway"="primary"];
 --  way["highway"="primary_link"];
 --  way["highway"="secondary"];
 --  way["highway"="secondary_link"];
 --  way["highway"="tertiary"];
 --  way["highway"="tertiary_link"];
 --  way["highway"="unclassified"];
 --  way["highway"="residential"];
 --  way["highway"="living_street"];
 --  way["highway"="pedestrian"];
 --  way["highway"="road"];

 --  way["highway"="service"][!"service"];
 --  way["highway"="service"]["service"="alley"];
 --  way["highway"="service"]["bicycle"="yes"];
 --  way["highway"="service"]["bicycle"="designated"];
 --  way["highway"="service"]["bicycle"="permissive"];
 --  way["highway"="track"];
 --
 --  WHERE tags ->> 'highway' in ('cycleway', 'footway', 'path', 'bridleway', 'steps')
 -- 
 --  WHERE (tags ->> 'highway') not in ('cycleway', 'footway', 'path', 'bridleway', 'steps', 'track')

 -- TODO: should not be edited here
HighwayClasses = Set({
  "motorway", "motorway_link",   -- "Autobahn"
  "trunk", "trunk_link",         -- "Autobahnähnliche Straße", "Schnellstraßen" (those have motorroad=yes)
  "primary", "primary_link",     -- "Bundesstraßen" (B XXX)
  "secondary", "secondary_link", -- "Landesstraße" (L XXX)
  "tertiary", "tertiary_link",   -- "Kreisstraße", "Gemeindeverbindungsstraße", "Innerstädtische Vorfahrtstraßen mit Durchfahrtscharakter"
  "unclassified",                -- "Nebenstraßen", "Gemeindestraße mit Verbindungscharakter"
  "residential",                 -- "Straße an und in Wohngebieten"
  "road",                        -- Ohne Klassifizierung
  "living_street",               -- "Verkehrsberuhigter Bereich", "Spielstraße" traffic_sign=325.1 (Beginn), 326 (Ende)
  "pedestrian",                  -- "Fußgängerzone"
  "service",                     -- "Zufahrtswege", aber auch "Grundstückszufahrt", Wege auf Parkplätzen, "Drive trough", "Gassen", "Feuerwehzufahrt"
})

PathClasses = Set({
  "cycleway",
  "footway",
  "path",
  "bridleway", -- Reitweg
  "steps",
})
