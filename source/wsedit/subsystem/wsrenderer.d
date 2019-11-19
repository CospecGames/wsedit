module wsedit.subsystem.wsrenderer;
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

    }

    /**
        Renders the wereshift logo with defined subtext.

        It gets rendered to the middle of the screen.
    */
    bool renderLogo(Context ctx, string subtext) {
        
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