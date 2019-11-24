module wsedit.ir.scene;
import wsedit.math;

/**
    A scene
*/
class Scene {
public:
    this() { }

    /**
        Creates a new scene
    */
    this(string name, string path, Vector2i tileSize) {
        this.name = name;
        this.path = path;
        this.tileSize = tileSize;
    }

    /// Name of scene
    string name;

    /// Output file name
    string path;

    /// The size of all tiles
    Vector2i tileSize;

    /// Regions of the scene
    Region[] regions;

    /// The currently selected region
    uint selectedRegion = 0;
}

/**
    A region
*/
class Region {
private:
    Scene parent;
    bool overlapFlag;

public:
    this(Scene parent) {
        this.parent = parent;
    }

    this(Scene parent, Rectangle area) {
        this(parent);
        mainLayer = new Layer(area);
        bgLayer = new Layer(area);
        colLayer = new Layer(area);
        this.resize(area);
        this.scanOverlaps();
    }

    /**
        The area of the region
    */
    Rectangle area;

    /**
        Resize the region, updating the layers' sizes
    */
    void resize(Rectangle area) {
        this.area = area;
        mainLayer.resize(area);
        bgLayer.resize(area);
    }

    /**
        The main layer (drawn infront of player)
    */
    Layer mainLayer;

    /**
        Background layer
    */
    Layer bgLayer;

    /**
        Collission layer
    */
    Layer colLayer;

    /**
        Parallax objects
    */
    ParallaxObject[] parallax;

    void scanOverlaps() {
        foreach(region; parent.regions) {
            if (region == this) continue;

            if (area.intersects(region.area) || region.area.intersects(area)) {
                overlapFlag = true;
                return;
            }
        }
        overlapFlag = false;
    }

    /**
        Returns true if this region is overlapping an other
    */
    bool isOverlapping() {
        return overlapFlag;
    }
}

/**
    A region for a camera
*/
class CamRegion {
    /**
        The area the camera is to stay in
    */
    Rectangle area;

    /// Allow the camera to move within the region
    bool allowMoveWithin;

    /// The zoom level to (smoothly) be applied to the camera
    double cameraZoom;
}

/**
    A parallax scrolling object
*/
class ParallaxObject {
    /// The ID of the object's texture
    string textureId;

    /// The area to render in
    Rectangle textureArea;

    /// Wether to loop the texture inside its render area
    bool loop = false;

    /// The depth to draw in, negative = infront of player, positive = behind, 0 = zfighting
    int depth;
    
    /// The ratio for parallax scrolling
    Vector2 parallaxRatio;
}

/**
    A layer
*/
class Layer {
private:
    Rectangle area;

public:

    /**
        Creates an empty layer
    */
    this() {}

    /**
        Creates a new layer with the specified size
    */
    this(Rectangle area) {
        this.resize(area);
    }

    /**
        Contains tiles

        [y][x]
    */
    Tile[][] tiles;

    /**
        Allows indexing with [x, y] coordinate sets
    */
    ref Tile opIndex(uint x, uint y) {
        return tiles[y][x];
    }

    /**
        Allows iteration via foreach
    */
    int opApply(int delegate(ref uint, ref uint, ref Tile) func) {
        int result = 0;
        for (uint y = 0; y < area.height; y++) {
            for (uint x = 0; x < area.width; x++) {
                result = func(x, y, this[x, y]);

                if (result) break;
            }
        }
        return result;
    }

    /**
        Resizes this layer
    */
    void resize(Rectangle area) {
        this.area = area;
        tiles.length = area.height;
        foreach(y; 0..area.height) {
            tiles[y].length = area.width;
        }
    }
}

/**
    A tile
*/
class Tile {
    /// The ID of the tile
    Vector2i tileId;

    /// Vertical flip
    bool vflip;

    /// Horizontal flip
    bool hflip;
}

/**
    An actor
*/
class Actor {
public:
    /// The ID of the actor
    string actorId;


}