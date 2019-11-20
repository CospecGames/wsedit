module wsedit.subsystem.wsrenderer;
import wsedit.subsystem.tilemgr;
import cairo.Context;
import cairo.ImageSurface;
import cairo.RecordingSurface;
import cairo.FontFace;
import cairo.FontOption;
import cairo.Pattern;
import cairo.Matrix;
import gdk.Cairo;
import gtk.DrawingArea;
import gdk.Rectangle;
import wsedit;
import gdkpixbuf.Pixbuf;
import gtk.Widget;

private {
    // The logo is shared across threads
    Pixbuf wseditLogo;
}

/**
    The subsystem that renders various things to do with the workspace.
*/
class Renderer {
private:
    double animOffset = 0.0;
    DrawingArea canvas;
    GdkRectangle widgetArea;
    Matrix originMatrix;
    Matrix tmpMatrix;

    /* Configurations */
    GridConfig gridConfig;
    double antAnimOffset = 0;
    bool isAA;

    /* The render context */
    Context ctx;

public:
    /**
        The workspace camera
    */
    Camera2D camera;

    this(DrawingArea canvas) {
        this.canvas = canvas;

        // Manage size allocation
        this.canvas.addOnSizeAllocate((Allocation alloc, Widget) {
            widgetArea = GdkRectangle(alloc.x, alloc.y, alloc.width, alloc.height);

            // Redraw the widget
            canvas.queueDraw();
        });

        // Create a matrix
        // gtk-d is kinda weird about this
        // So it's kind hacky.
        auto omatrix = new cairo_matrix_t;
        originMatrix = new Matrix(omatrix);

        auto tmatrix = new cairo_matrix_t;
        tmpMatrix = new Matrix(tmatrix);
    }

    /**
        Starts rendering
    */
    void begin(Context ctx) {
        this.ctx = ctx;
        ctx.getMatrix(originMatrix);
        ctx.setAntialias(isAA ? cairo_antialias_t.BEST : cairo_antialias_t.NONE);
    }

    /**
        Ends rendering
    */
    void end() {
        ctx.setMatrix(originMatrix);
        this.ctx = null;
    }

    /**
        Applies camera transform to the rendering
    */
    void applyCamera(Camera2D camera) {
        ctx.translate(camera.origin.x, camera.origin.y);
        ctx.scale(camera.zoom, camera.zoom);
        ctx.translate(camera.position.x, camera.position.y);
    }

    /**
        Sets antialias on or off
    */
    void setAntiAlias(bool aa) {
        isAA = aa;
    }

    /**
        Gets wether antialias is turned on
    */
    bool getAntiAlias() {
        return isAA;
    }

    /**
        Resets the camera
    */
    void resetCamera() {
        ctx.setMatrix(originMatrix);
    }

    void setColor(Color color) {
        ctx.setSourceRgba(color.red, color.green, color.blue, color.alpha);
    }

    /**
        Renders a grid
    */
    bool renderGrid(double offsetX = 0, double offsetY = 0) {
        ctx.newPath();

        double width = gridConfig.cellsX*gridConfig.cellSizeX;
        double height = gridConfig.cellsY*gridConfig.cellSizeY;

        // Apply config
        this.setColor(gridConfig.gridColor);
        ctx.setLineWidth(gridConfig.outerThickness);
        ctx.setLineCap(cairo_line_cap_t.ROUND);

        // Draw outside box
        ctx.moveTo(offsetX, offsetY);
        ctx.relLineTo(width, 0);
        ctx.relLineTo(0, height);
        ctx.relLineTo(-width, 0);
        ctx.closePath();
        ctx.stroke();

        // Apply config for lines
        ctx.setLineWidth(gridConfig.innerThickness);

        // Draw internal lines on the X axis
        foreach(y; 0..gridConfig.cellsY+1) {
            ctx.moveTo(offsetX, offsetY+(y*gridConfig.cellSizeY));
            ctx.relLineTo(width, 0);
            ctx.stroke();
        }

        // Draw internal lines on the y axis
        foreach(x; 0..gridConfig.cellsX+1) {
            ctx.moveTo(offsetX+(x*gridConfig.cellSizeX), offsetY);
            ctx.relLineTo(0, height);
            ctx.stroke();
        }
        return true;
    }

    /**
        Renders an marching-ant selection box.
    */
    bool renderSelection(Selection selection) {
        ctx.newPath();

        // Set config
        ctx.setSourceRgb(.5, .5, .8);
        ctx.setLineCap(cairo_line_cap_t.ROUND);
        ctx.setLineJoin(cairo_line_join_t.ROUND);
        ctx.setLineWidth(4);

        // Update animation
        antAnimOffset += 0.1;
        ctx.setDash([8.0], antAnimOffset);
        ctx.moveTo(selection.x, selection.y);
        ctx.relLineTo(selection.toX, 0);
        ctx.relLineTo(0, selection.toY);
        ctx.relLineTo(-selection.toX, 0);
        ctx.closePath();
        ctx.stroke();

        // Disable dashes before going on
        ctx.setDash([], 0);

        return true;
    }

    /**
        Renders a tile within the current grid settings
    */
    bool renderTile(Tile* tile, uint x, uint y, bool hflip = false, bool vflip = false, bool ghost = false) {
        
        // We're going to do extra transformations here
        ctx.getMatrix(tmpMatrix);

        // Apply the transformations
        ctx.translate(
            hflip ? gridConfig.cellSizeX : 0, 
            vflip ? gridConfig.cellSizeY : 0
        );
        
        ctx.scale(hflip ? -1 : 1, vflip ? -1 : 1);

        int posX = x * cast(int)gridConfig.cellSizeX;
        int posY = y * cast(int)gridConfig.cellSizeY;

        ctx.setSourceSurface(ghost ? tile.gtkGhost : tile.gtkSurface, 
            hflip ? -posX : posX, 
            vflip ? -posY : posY
        );

        ctx.maskSurface(tile.gtkSurface, 
            hflip ? -posX : posX, 
            vflip ? -posY : posY
        );
        
        // Go back to the transformation before we did any flipping
        ctx.setMatrix(tmpMatrix);

        return true;
    }

    void setGridConfig(GridConfig config) {
        this.gridConfig = config;
    }

    /**
        Renders the wereshift logo with defined subtext.

        It gets rendered to the middle of the screen.
    */
    bool renderLogo(string subtext) {
        ctx.newPath();
        resetCamera();
        
        // Get useful info for rendering.
        int originX = wseditLogo.getWidth()/2;
        int originY = wseditLogo.getHeight()/2;

        ctx.selectFontFace("", cairo_font_slant_t.NORMAL, cairo_font_weight_t.BOLD);
        ctx.setFontSize(18);

        cairo_text_extents_t extents;
        ctx.textExtents(subtext, &extents);

        // Black background
        ctx.setSourceRgb(0, 0, 0);
        ctx.paint();

        // Draw wereshift logo
        ctx.translate(widgetArea.width/2, widgetArea.height/2);
        ctx.setSourcePixbuf(wseditLogo, -originX, -originY);
        ctx.paint();

        // Draw info text
        ctx.translate(-(extents.width/2), originY-32);
        ctx.setSourceRgb(1, 1, 1);
        ctx.showText(subtext);

        return true;
    }
}

shared static this() {
    import ppc.types.image : Image;
    import ppc.backend.cfile : MemFile;

    ubyte[] imageData = cast(ubyte[])import("logo.png");
    Image img = Image(MemFile(imageData.ptr, imageData.length));
    wseditLogo = new Pixbuf(
        cast(char[])img.pixelData, 
        GdkColorspace.RGB, 
        true, 
        8, 
        cast(int)img.width, 
        cast(int)img.height, 
        cast(int)img.width*4, 
        null, 
        null);
}

/**
    Main selection color
*/
enum MAIN_SEL_COLOR = Color(0.4, 0.4, 0.6, 1.0);

/**
    Main line color
*/
enum MAIN_LINE_COLOR = Color(0.5, 0.5, 0.5, 1.0);

/**
    Contains color
*/
struct Color {
    /// red
    double red = 1.0;

    /// green
    double green = 1.0;

    /// blue
    double blue = 1.0;

    /// alpha
    double alpha = 1.0;

    /**
        Constructs a color
    */
    this(double red, double green, double blue, double alpha = 1.0) {
        this.red = red;
        this.green = green;
        this.blue = blue;
        this.alpha = alpha;
    }
}

/**
    Configuration for grid rendering
*/
struct GridConfig {
    /**
        How many cells to render in the X axis
    */
    size_t cellsX;

    /**
        How many cells to render in the Y axis
    */
    size_t cellsY;
    
    /**
        The size of a cell on the X axis
    */
    size_t cellSizeX;

    /**
        The size of a cell on the Y axis
    */
    size_t cellSizeY;

    /**
        How thick the lines should be
    */
    double innerThickness = 2.0;

    /**
        How thick the lines should be
    */
    double outerThickness = 4.0;

    /**
        Color of the grid
    */
    Color gridColor = MAIN_LINE_COLOR;
}