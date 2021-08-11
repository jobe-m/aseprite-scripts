if TilesetMode == nil then return app.alert "Use Aseprite v1.3"  end

local lay = app.activeLayer
if not lay.isTilemap then return app.alert "No active tilemap layer" end

local tileset = lay.tileset

local dlg = Dialog("Export Tileset")
dlg:file{ id="filename", label="Export to Tilemap file:", save=true, focus=true,
          filename=app.fs.joinPath(app.fs.filePath(lay.sprite.filename), "tileset.png") }
 :label{ label="Number of Tiles to be exported", text=tostring(#tileset) }

 :separator()
 :number { id="tilemap_cols", label="Number of columns in Tilemap:", text="16" }
 :check { id="ask_overwrite", label="Ask before overwrite existing Tilemap file", selected=true }
 :check { id="tiles_extruded", label="Extrude Tiles in Tilemap", selected=false }
 :check { id="keep_sprite_frames", label="Keep generated sprite frames open", selected=false }
 :check { id="open_generated", label="Open generated Tilemap", selected=false }

 :separator()
 :button{ text="&Export", focus=true, id="ok" }
 :button{ text="&Cancel" }
 :show()

-- Data validation
local data = dlg.data
if not data.ok then return end

local spec = lay.sprite.spec
local grid = tileset.grid
local size = grid.tileSize

-- Create a new sprite with the dimension of one single tile
local newSpr = Sprite(size.width, size.height, lay.sprite.colorMode)

-- give the new sprite the same palette as the source sprite
newSpr:setPalette(lay.sprite.palettes[1])

-- First copy first tile into sprite frame 1
local tile = tileset:getTile(0)
newSpr.cels[1].image = tile

-- Then create new frame and copy each tile into a new frame of sprite

for i = 1, #tileset - 1 do
  app.command.NewFrame { ["content"]="current" }
  local tile = tileset:getTile(i)
  newSpr.cels[i + 1].image = tile
end

if app.apiVersion >= 3 then
  newSpr.filename = "sprite frames"
end

-- Export sprite frames as an extruded sprite sheet
app.command.ExportSpriteSheet{
  ui=false,
  askOverwrite=data.ask_overwrite,
  type=SpriteSheetType.ROWS,
  columns=data.tilemap_cols,
  textureFilename=data.filename,
  extrude=data.tiles_extruded,
  openGenerated=data.open_generated
}

-- Close sprite frames again
if data.keep_sprite_frames == false then
  newSpr:close()
end

