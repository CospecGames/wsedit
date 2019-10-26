/**
    Copyright © 2019, Cospec Games

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module wsedit.widgets.workspace;
import gtk.DrawingArea;
import gdk.Cairo;
import cairo.Context;
import cairo.ImageSurface;
import cairo.RecordingSurface;
import cairo.FontFace;
import cairo.FontOption;
import cairo.Pattern;
import cairo.Matrix;
import cairo.c.functions : cairo_matrix_init_identity;
import gdkpixbuf.Pixbuf;
import gtk.Widget;
import gdk.DragContext;
import gdk.Cursor;
import core.memory : GC;
import wsedit;

// status text
private {
    enum InfoNoScene = "No scene loaded";

}

/**
    The currently "selected" index
*/
struct Selection {
    /**
        X index
    */
    int x;

    /**
        Y index
    */
    int y;
}

/**
    The editor workspace
*/
class Workspace : DrawingArea {
private:

    double mouseX;
    double mouseY;

    double sceneMouseX;
    double sceneMouseY;

    /* Basic Rendering*/
    GdkRectangle area;
    Pixbuf wereshiftLogo;
    RecordingSurface grid;
    Pattern gridPattern;

    bool onDraw(Context ctx) {

        // First, clear the last pass.
        ctx.setSourceRgba(0, 0, 0, 0);
        ctx.paint();

        // If we haven't loaded our scene, draw our "no scene" graphic.
        if (STATE.currentSceneFile is null) {
            drawUnInit(ctx);
            return true;
        }

        drawScene(ctx);
        return true;
    }

    void drawUnInit(Context ctx) {
        
        // Get useful info for rendering.
        int originX = wereshiftLogo.getWidth()/2;
        int originY = wereshiftLogo.getHeight()/2;

        ctx.selectFontFace("", cairo_font_slant_t.NORMAL, cairo_font_weight_t.BOLD);
        ctx.setFontSize(18);

        cairo_text_extents_t extents;
        ctx.textExtents(InfoNoScene, &extents);

        // Black background
        ctx.setSourceRgb(0, 0, 0);
        ctx.paint();

        // Draw wereshift logo
        ctx.translate(area.width/2, area.height/2);
        ctx.setSourcePixbuf(wereshiftLogo, -originX, -originY);
        ctx.paint();

        // Draw info text
        ctx.translate(-(extents.width/2), originY-32);
        ctx.setSourceRgb(1, 1, 1);
        ctx.showText(InfoNoScene);
    }

    void drawScene(Context ctx) {

        // Set camera
        ctx.translate((area.width/2), (area.height/2));
        ctx.scale(camera.zoom, camera.zoom);
        ctx.translate(camera.x, camera.y);

        drawGrid(ctx);
        drawHover(ctx);

        // Disable antialias and start drawing all the layers
        ctx.setAntialias(cairo_antialias_t.NONE);
        // TODO: draw layers
    }

    void drawGrid(Context ctx) {
        ctx.setSourceRgb(.4, .4, .4);
        ctx.setLineCap(cairo_line_cap_t.ROUND);
        ctx.setLineJoin(cairo_line_join_t.ROUND);
        ctx.setLineWidth(1);
        foreach(x; 1..(STATE.scene.width/STATE.tileWidth)) {
            ctx.moveTo(STATE.tileWidth*x, 0);
            ctx.lineTo(STATE.tileWidth*x, STATE.scene.height);
        }

        foreach(y; 1..(STATE.scene.height/STATE.tileHeight)) {
            ctx.moveTo(0, STATE.tileHeight*y);
            ctx.lineTo(STATE.scene.width, STATE.tileHeight*y);   
        }
        ctx.stroke();

        // Outer lines
        ctx.moveTo(0, 0);
        ctx.lineTo(STATE.scene.width, 0);
        ctx.lineTo(STATE.scene.width, STATE.scene.height);
        ctx.lineTo(0, STATE.scene.height);
        ctx.lineTo(0, 0);
        ctx.stroke();
    }

    void drawHover(Context ctx) {
        if (selectedTile.x == -1 || selectedTile.y == -1) return;

        ctx.setSourceRgb(.25, .25, .4);
        ctx.setLineCap(cairo_line_cap_t.ROUND);
        ctx.setLineJoin(cairo_line_join_t.ROUND);
        ctx.setLineWidth(4);


        ctx.moveTo(selectedTile.x, selectedTile.y);
        ctx.lineTo(selectedTile.x+STATE.tileWidth, selectedTile.y);
        ctx.lineTo(selectedTile.x+STATE.tileWidth, selectedTile.y+STATE.tileHeight);
        ctx.lineTo(selectedTile.x, selectedTile.y+STATE.tileHeight);
        ctx.lineTo(selectedTile.x, selectedTile.y);
        ctx.stroke();
    }


    bool isDragging = false;
    double dragOriginX = 0;
    double dragOriginY = 0;
    double cameraOriginX = 0;
    double cameraOriginY = 0;
    bool onMotion(GdkEventMotion* motion, Widget widget) {
        mouseX = motion.x;
        mouseY = motion.y;

        // Handle positioning of the mouse in terms of tiles.
        handlePositioning();

        if (isDragging) {
            camera.x = cameraOriginX - ((dragOriginX - motion.x)/camera.zoom);
            camera.y = cameraOriginY - ((dragOriginY - motion.y)/camera.zoom);

            constrainCamera();
        }
        queueDraw();
        return true;
    }

    void constrainCamera() {
        double twidth = STATE.scene.width;
        double theight = STATE.scene.height;

        if (camera.x > 0) camera.x = 0;
        if (camera.x < -twidth) camera.x = -twidth;

        if (camera.y > 0) camera.y = 0;
        if (camera.y < -theight) camera.y = -theight;
    }

    void handlePositioning() {

        if (STATE.scene is null) return;

        selectedTile.x = -1;
        selectedTile.y = -1;

        int aw = area.width/2;
        int ah = area.height/2;

        sceneMouseX = ((mouseX/camera.zoom)-(aw/camera.zoom))-camera.x;
        sceneMouseY = ((mouseY/camera.zoom)-(ah/camera.zoom))-camera.y;
        if (sceneMouseX < 0 || sceneMouseY < 0) return;

        int tileXPos = cast(int)sceneMouseX/STATE.tileWidth;
        int tileYPos = cast(int)sceneMouseY/STATE.tileHeight;
        if (tileXPos >= STATE.scene.width || tileYPos >= STATE.scene.height) return;

        selectedTile.x = tileXPos*STATE.tileWidth;
        selectedTile.y = tileYPos*STATE.tileHeight;
    }

public:
    /**
        The workspace camera
    */
    Camera2D camera;

    /**
        The tile that the mouse is hovering over
    */
    Selection selectedTile;

    this() {
        super(1, 1);
        selectedTile = Selection(0, 0);

        wereshiftLogo = new Pixbuf("res/wereshift.png");
        this.addOnDraw((Scoped!Context ctx, Widget _) {
            return onDraw(ctx);
        });

        this.addOnSizeAllocate((Allocation alloc, Widget) {
            area = GdkRectangle(alloc.x, alloc.y, alloc.width, alloc.height);
        });

        this.addOnMotionNotify(&onMotion);
        this.addOnButtonPress((GdkEventButton* ev, Widget) {
            if (STATE.scene is null) return true;
            if (ev.button == 3 && !isDragging) {
                this.isDragging = true;
                dragOriginX = ev.x;
                dragOriginY = ev.y;
                cameraOriginX = camera.x;
                cameraOriginY = camera.y;
                setCursor(new Cursor(this.getDisplay(), CursorType.HAND1));
            }
            if (ev.button == 2) {
                camera.zoom = 1;
                queueDraw();
            }
            return true;
        });

        this.addOnButtonRelease((GdkEventButton* ev, Widget) {
            if (STATE.scene is null) return true;
            if (ev.button == 3) {
                this.isDragging = false;
                setCursor(new Cursor(this.getDisplay(), CursorType.LEFT_PTR));
            }
            return true;
        });

        this.addOnScroll((GdkEventScroll* scroll, Widget) {
            if (STATE.scene is null) return true;
            mouseX = scroll.x;
            mouseY = scroll.y;
            handlePositioning();

            camera.zoom += scroll.direction == ScrollDirection.UP ? -0.2 : 0.2;
            if (camera.zoom < 0.1) {
                camera.zoom = 0.1;
            }

            // More than 4x zoom is ridiculous.
            if (camera.zoom > 4) {
                camera.zoom = 4;
            }

            queueDraw();
            return true;
        });
    }
}