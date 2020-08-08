----------------------------------------------------------------------
-- Takes a sprite for a tile sheet, splits the tiles into a new sprite 
-- animation and exports the resulting sprite sheet into an extruded
-- sprite file.
----------------------------------------------------------------------
local spr = app.activeSprite

-- Checks for a valid sprite
if not spr then
  app.alert("There is no sprite to export")
  return
end

-- Dialog prompt to get dimensions for an individual sprite
local d = Dialog("Save sprite as extruded tileset")
d:label { id="help", label="Set the width and height to split tiles by:", text="" }
 :number { id="tile_w", label="Tile Width:", text="16", focus=true }
 :number { id="tile_h", label="Tile Height:", text="16" }
 :check { id="askOverwrite", label="Ask before overwrite extruded sprite sheet", selected=false }
 :check { id="keep_sprite_frames", label="Keep generated sprite frames open", selected=false }
 :check { id="openGenerated", label="Open extruded sprite sheet", selected=true }
 :button{ id="ok", text="&OK", focus=true }
 :button{ text="&Cancel" }
 :show()

-- Data validation
local data = d.data
if not data.ok then return end

-- Tiles will be extracted from the active frame of the active sprite
local img = Image(spr.spec)
img:clear()
img:drawSprite(spr, app.activeFrame)

-- Create file name for extruded sprite sheet
local path,title = spr.filename:match("^(.+[/\\])(.-).([^.]*)$")
local extruded_filename = path .. title .. '-' .. 'extruded.png'

-- Create a new sprite with the dimension of one single tile
local newSpr = Sprite(data.tile_w, data.tile_h, spr.colorMode)

--[[
  Copies a single tile to a new sprite frame
  @param {Number} row The row of the tile to copy
  @param {Number} col The column of the tile to copy
  @param {Number} count The overall tile number to be copied
]]--
copyTileToFrame=function(row, col, frameNum)
  local sheetImg = Image(newSpr.spec)
  sheetImg:drawImage(img, -col * data.tile_w, -row * data.tile_h)
  newSpr.cels[frameNum].image = sheetImg
end

-- give the new sprite the same palette as the source sprite
newSpr:setPalette(spr.palettes[1])

local rows = math.floor(spr.height / data.tile_h)
local cols = math.floor(spr.width / data.tile_w)
local tileCount = 0

for j = 0,rows-1 do
  for i = 0,cols-1 do
    tileCount = tileCount+1
    copyTileToFrame(j, i, tileCount)
    if tileCount < rows * cols then
      app.command.NewFrame { ["content"]="current" }
    end
  end
end

if app.apiVersion >= 3 then
  newSpr.filename = "sprite frames"
end

-- Export sprite frames as an extruded sprite sheet
app.command.ExportSpriteSheet{
  ui=false,
  askOverwrite=data.askOverwrite,
  type=SpriteSheetType.ROWS,
  columns=cols,
  textureFilename=extruded_filename,
  extrude=true,
  openGenerated=data.openGenerated
}

-- Close sprite frames again
if data.keep_sprite_frames == false then
  newSpr:close()
end

