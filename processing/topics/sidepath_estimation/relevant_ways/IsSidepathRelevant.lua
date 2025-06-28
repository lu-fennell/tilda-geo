require("Set")

local function bicycle_ok(tags) return tags.bicycle == 'yes' or tags.bicycle == 'designated' or tags.bicycle  == 'permissive' end

---Test the tags of a way should be included in sidepath estimation.
---The rules are taken from the original Cycling-Quality-Index implementation:
---- https://github.com/SupaplexOSM/OSM-Cycling-Quality-Index?tab=readme-ov-file#how-to-use-this-script
---@return boolean
function IsSidepathRelevant(tags)

  -- This should be equivalent to the original overpass-query linked in CQI-repo:
  --   https://overpass-turbo.eu/?q=W291dDpqc29uXQpbYmJveDo1Mi40NTQzMjQ2MDA5MTEwNzg4LDEzLjM5xJgzNDfEmcSsNTDElzYsxJEuxLDEnDE5xLfEncSgMMSZxKTEpjQ4NTnEoTJdOwovL8SLxI3Ej3t7xIzEjn19xYgKKAogIHdheVsiaGlnaMWceSI9ImN5Y2xlxaUixZbFmsWlxZ_FocWjxa_FqHBhdGjFsMWfYmnFqsWsZSIhxahub8W9IsW_xoHFrcaExahkaXNtxIFudMWwxYnFssWdxbTFosWkxZ3FpyJmb290xa9dxb7GgMWrxo3FqHllc8aXxZnFm8aaxaDGnMW3xqDGosakxp7GpsaKxqjGgsafZMatxaJuxbplZMavxpnFnsazxbbGnsWoxqHGo8alxqfGjMaDxbhlcm3GkXNpdsaDxbHGsceIxbXGncWmxahicmlkxa3Hj8a7x5HGn8asxq7HnMWzx4nHoMafx6PHpcenxrnHkMapx5Iixr_HmGfHgnTHhMeGx53Gm8eKx6HGisekx6bFrse2x6nHuMafcMeUx5Zzx5jHmsiBx6_Hn8a1c8e_cMetx7fGvcarxq3IlMayyJbHiyLImGXImsaJxovIjMaPx4DHvceDx4XHrsihxrTIo8ilyKfGusipyJ0iyI7HlceXx5nHm8WJxrDIlciyyIXGk3RvcsalxpjIgsewxrXJhMmGxaVfbGlua8igx57JgsafdHJ1yZPJlciDx7HFqMmZyZtryZDJksmUxZbJgMixyITIjcekbWFyxabIsMmWyarFuMmsya55yaTJnMmxyZ7Il2VjxIdkybbJncmLyLPJvcm_ybbJuMmmyYnJgcmzIse_cnRpyoHJusqDyIXKjsqQyofJkcm5yorJqcmfIsmbxaxhyJFpZmnIgMqTyKLIhXLHgMa_xpXKkWzKgsqoxp_JkXbJkmdfyJjKqmXGlsqnyZfHk8e7yZnKkW7KsMq9InJvYcivyL_Hh8m7yoRyyrRjx5tbIcikx5TLj8i-yajJssqdc8uVxoDLkcuUy47LncafYWzFrcmwypvLmcm8y6DLkMioxrzGqiLHrMuDyozLm8uqy57It8uux7vHgciuy7HLmsucy6vItsutx7nIusiQyJLLl8uLypTJmHJhY8qJCinFicWLIHDHpMaVIMqqc3VsdHMKxIF0IMSNZHnFiT7FicydIHNrZWwgcXQ7&c=BPKl81fY-P---@param tags table
  return (
 --  way["highway"="path"]["bicycle"!="no"]["bicycle"!="dismount"];
    (tags.highway == 'path' and tags.bicycle ~= 'no' and tags.bicycle ~= 'dismount') or
 --  way["highway"="footway"]["bicycle"="yes"];
 --  way["highway"="footway"]["bicycle"="designated"];
 --  way["highway"="footway"]["bicycle"="permissive"];
    (tags.highway == 'footway' and bicycle_ok(tags)) or
 --  way["highway"="bridleway"]["bicycle"="yes"];
 --  way["highway"="bridleway"]["bicycle"="designated"];
 --  way["highway"="bridleway"]["bicycle"="permissive"];
    (tags.highway == 'bridleway' and bicycle_ok(tags)) or
 --  way["highway"="steps"]["bicycle"="yes"];
 --  way["highway"="steps"]["bicycle"="designated"];
 --  way["highway"="steps"]["bicycle"="permissive"];
    (tags.highway == 'steps' and bicycle_ok(tags)) or
 -- way["highway"="cycleway"];
 --  way["highway"="motorway"];
 --  way["highway"="motorway_link"];
 --  way["highway"="trunk"];
 --  way["highway"="trunk_link"];
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
--  way["highway"="track"];
    Set({
      "cycleway",
      "motorway",
      "motorway_link",
      "trunk",
      "trunk_link",
      "primary",
      "primary_link",
      "secondary",
      "secondary_link",
      "tertiary",
      "tertiary_link",
      "unclassified",
      "residential",
      "living_street",
      "pedestrian",
      "road",
      "track",
    })[tags.highway] or
 --  way["highway"="service"][!"service"];
 --  way["highway"="service"]["service"="alley"];
    (tags.highway == 'service' and (tags.service == nil or tags.service == 'alley')) or
 --  way["highway"="service"]["bicycle"="yes"];
 --  way["highway"="service"]["bicycle"="designated"];
 --  way["highway"="service"]["bicycle"="permissive"];
    (tags.highway == 'service' and bicycle_ok(tags))
  )
end





