module wsedit.widgets.tilebox;
import gtk.DrawingArea;
import gdkpixbuf.Pixbuf;
import cairo.Context;
import cairo.ImageSurface;
import cairo.RecordingSurface;
import cairo.FontFace;
import cairo.FontOption;
import cairo.Pattern;
import cairo.Matrix;
import gdk.Color;
import gdk.Screen;
import gtk.Widget;
import wsedit;
import wsedit.workspace;
import wsedit.subsystem.tilemgr;

/**
    Box containing tiles for tileset
*/
class TileBoxArea : DrawingArea {
private:
    Workspace workspace;
    bool onDraw(Context ctx) {
        // First, clear the last pass.
        ctx.setSourceRgba(0, 0, 0, 0);
        ctx.paint();

        int tileWidth = workspace.scene.tileSize.x;
        int tileHeight = workspace.scene.tileSize.y;

        // Update Size
        auto size = workspace.tiles.layout.getSize();
        this.setSizeRequest(
            size.x*tileWidth, 
            size.y*tileHeight
        );

        // Get origin matrix
        cairo_matrix_t* lmat = new cairo_matrix_t;
        Matrix matrix = new Matrix(lmat);
        ctx.getMatrix(matrix);

        bool vflip = workspace.tiles.vflip;
        bool hflip = workspace.tiles.hflip;

        // Render every tile
        foreach(pos, tile; workspace.tiles.layout) {
            ctx.translate(hflip ? tileWidth : 0, vflip ? tileHeight : 0);
            ctx.scale(hflip ? -1 : 1, vflip ? -1 : 1);

            int xoffset = pos.x*tileWidth;
            int yoffset = pos.y*tileHeight;

            ctx.setSourceSurface(tile.gtkSurface, 
                hflip ? -xoffset : xoffset, 
                vflip ? -yoffset : yoffset
            );

            ctx.setOperator(cairo_operator_t.OVER);

            ctx.maskSurface(tile.gtkSurface, 
                hflip ? -xoffset : xoffset, 
                vflip ? -yoffset : yoffset
            );

            ctx.setMatrix(matrix);
        }

        // We're done with it.
        xdestroy(matrix);

        // Draw the outline around the currently selected tile
        auto pos = workspace.tiles.position;
        int posX = (pos.x*tileWidth)+1;
        int posY = (pos.y*tileHeight)+1;
        tileWidth -= 2;
        tileHeight -= 2;
        ctx.setSourceRgba(0.4, 0.4, 0.6, 0.7);
        ctx.setLineCap(cairo_line_cap_t.SQUARE);
        ctx.setLineJoin(cairo_line_join_t.MITER);
        ctx.setLineWidth(2.0);
        ctx.moveTo(posX, posY);
        ctx.lineTo(posX+tileWidth, posY);
        ctx.lineTo(posX+tileWidth, posY+tileHeight);
        ctx.lineTo(posX, posY+tileHeight);
        ctx.closePath();
        ctx.stroke();

        return true;
    }

public:
    this(Workspace workspace) {

        this.workspace = workspace;

        this.addTickCallback((Widget, FrameClock) {
            queueDraw();
            return true;
        });

        /* Draw */
        this.addOnDraw((Scoped!Context ctx, Widget _) {
            return onDraw(ctx);
        });

        this.addOnButtonPress((GdkEventButton* evnt, _) {
            GdkEventButton* ev = evnt;

            if (ev.button == 1) {
                int tileWidth = workspace.scene.tileSize.x;
                int tileHeight = workspace.scene.tileSize.y;
                uint xPos = (cast(uint)ev.x)/tileWidth;
                uint yPos = (cast(uint)ev.y)/tileHeight;

                workspace.tiles.select(xPos, yPos);
            }

            return false;
        });

    }
}

import gtk.ScrolledWindow;
import dazzle.EntryBox;
import gtk.Box;
import gtk.Label;
import gtk.CheckButton;
class TileBox : EntryBox {
private:
    ScrolledWindow wrapper;
    Box iwrapper;
    TileBoxArea area;
    CheckButton hflip;
    CheckButton vflip;
    Workspace workspace;


public:

    this(Workspace workspace) {
        this.workspace = workspace;
        Box flipBox = new Box(Orientation.HORIZONTAL, 4);

        hflip = new CheckButton("Flip H");
        hflip.setHalign(Align.START);
        hflip.addOnReleased((_) {
            workspace.tiles.hflip = hflip.getActive();
        });

        vflip = new CheckButton("Flip V");
        vflip.setHalign(Align.START);
        vflip.addOnReleased((_) {
            workspace.tiles.vflip = vflip.getActive();
        });

        flipBox.packStart(hflip, false, false, 0);
        flipBox.packStart(vflip, false, false, 0);

        area = new TileBoxArea(workspace);
        wrapper = new ScrolledWindow();
        wrapper.setOverlayScrolling(true);
        wrapper.add(area);

        iwrapper = new Box(Orientation.VERTICAL, 4);
        iwrapper.packStart(new Label("Tile Selection"), false, false, 0);
        iwrapper.packStart(wrapper, true, true, 0);
        iwrapper.packStart(flipBox, false, false, 0);

        this.packStart(iwrapper, true, true, 0);
        this.setSizeRequest(256, 256);
    }


}

void xdestroy(T)(T item) {
    destroy(item);
}