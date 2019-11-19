module wsedit.subsystem.tilemgr;
import wsedit.subsystem.utils;
import ppc.types.image;
import cairo.ImageSurface;
import containers.list;
import wsedit;
import std.format;
import std.stdio;

/**
    A tile in the tileset
*/
struct Tile {
    /**
        The GTK surface generated for use in the viewport
    */
    ImageSurface gtkSurface;

    /**
        The root image
    */
    Image rootImage;

    /**
        The ID of the tile
    */
    string id;

    /**
        Creates a new tile
    */
    this(Image image) {
        rootImage = image;

        // Clone the image, transform it to work with cairo then set the gtkSurface
        Image surfaceImg = image.clone;
        surfaceImg.rgbaToBgra();
        gtkSurface = ImageSurface.createForData(
            surfaceImg.pixelData.ptr, 
            cairo_format_t.ARGB32, 
            cast(int)image.width,
            cast(int)image.height,
            ImageSurface.formatStrideForWidth(cairo_format_t.ARGB32, cast(int)image.width));
    }
}

struct Tileset;

/**
    A position within a tile layout
*/
struct TileLayoutPos {
    /// X
    uint x;

    /// Y
    uint y;
}

/**
    A tile layout
*/
class TileLayout {
private:

    Tile*[TileLayoutPos] tiles;

    uint sizeX = 0;
    uint sizeY = 0;

    bool idAvailable(string id) {
        foreach(tile; tiles) {
            if (tile.id == id) return false;
        }
        return true;
    }

public:

    TileLayoutPos getSize() {
        return TileLayoutPos(sizeX, sizeY);
    }

    /**
        Add a tile to the layout
    */
    bool addTile(Tile* tile, string id) {
        // Make sure we don't add the same tile twice
        if (!idAvailable(id)) return false;
        writeln("Adding ", id);

        // Make more space
        if (tiles.length >= sizeX*sizeY) {
            sizeX++;
            sizeY++;
        }

        // Find space to fit in the tile
        foreach(y; 0..sizeY) {
            foreach(x; 0..sizeX) {
                if (TileLayoutPos(x, y) !in tiles) {
                    tiles[TileLayoutPos(x, y)] = tile;
                    tile.id = id;
                    return true;
                }
            }
        }

        // This should really not happen; but just in case.
        throw new Exception("Tile could not be placed in to the layout!");
    }

    /**
        Finds the first tile that isn't empty
    */
    TileLayoutPos* findFirstTile() {
        foreach(y; 0..sizeY) {
            foreach(x; 0..sizeX) {
                if (TileLayoutPos(x, y) !in tiles) continue;
                return new TileLayoutPos(x, y);
            }
        }
        return null;
    }

    /**
        Get a tile from the layout
    */
    Tile* getTile(uint x, uint y) {
        if (TileLayoutPos(x, y) !in tiles) return null;
        return tiles[TileLayoutPos(x, y)];
    }

    /**
        Remove a tile from the tile layout
    */
    void removeTile(uint x, uint y) {
        if (TileLayoutPos(x, y) !in tiles) return;
        tiles.remove(TileLayoutPos(x, y));
    }

    /**
        Allow iterating over tiles
    */
    int opApply(int delegate(ref TileLayoutPos, Tile*) operations) {
        int result = 0;
        foreach(TileLayoutPos key, Tile* value; tiles) {
            result = operations(key, value);

            if (result) break;
        }

        return result;
    }
}

/**
    The tile manager
*/
class TileManager {
private:
    Tile* selectedTile;
    TileLayoutPos selectedPosition;

public:
    /**
        Construct the tile manager
    */
    this() {
        layout = new TileLayout();
    }

    /**
        Contains the tiles in the tilset
        Organizes them in to a square
    */
    TileLayout layout;

    /**
        Gets the currently selected tile
    */
    Tile* selected() {
        return selectedTile;
    }

    /**
        The position of the currently selected tile
    */
    TileLayoutPos position() {
        return selectedPosition;
    }

    /**
        Horizontal Flipping
    */
    bool hflip;

    /**
        Vertical Flipping
    */
    bool vflip;

    /**
        Add tiles from file
    */
    void add(string file) {
        import std.path : baseName;
        Image image = Image(file);
        uint tileWidth = 32; //STATE.scene.tileWidth;
        uint tileHeight = 32; //STATE.scene.tileHeight;

        // Go through each subtile and add them
        immutable(size_t) segmentsX = image.width/tileWidth;
        immutable(size_t) segmentsY = image.height/tileHeight;
        foreach(yp; 0..segmentsY) {
            foreach(xp; 0..segmentsX) {
                immutable(size_t) x = xp*tileWidth;
                immutable(size_t) y = yp*tileHeight;
                
                layout.addTile(new Tile(image.getSubImage(x, y, tileWidth, tileHeight)), "%s-%s-%s".format(file.baseName, xp, yp));
            }
        }

        if (selectedTile is null) {
            auto tilePos = layout.findFirstTile();
            if (tilePos is null) return;
            selectedPosition = *tilePos;
            selectedTile = layout.getTile(selectedPosition.x, selectedPosition.y);
        }
    }

    /**
        Select a tile
    */
    void select(uint x, uint y) {
        auto tile = layout.getTile(x, y);
        if (tile is null) return;

        this.selectedTile = tile;
        this.selectedPosition = TileLayoutPos(x, y);
    }

    /**
        Remove the specified tile
    */
    void remove(uint x, uint y) {
        layout.removeTile(x, y);
    }

    /**
        Compiles the tiles in to a tileset

        TODO: Finish this function
    */
    Tileset* compile() {
        throw new Exception("Not implemented!");
    }
}