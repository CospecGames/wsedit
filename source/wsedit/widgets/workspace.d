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
    The editor workspace
*/
class Workspace : DrawingArea {
private:

    double animOffset = 0.0;

    double mouseX;
    double mouseY;

    double sceneMouseX = 0;
    double sceneMouseY = 0;
    double sceneMouseToX = 0;
    double sceneMouseToY = 0;

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
        drawSelection(ctx);

        // Disable antialias and start drawing all the layers
        ctx.setAntialias(cairo_antialias_t.NONE);
        // TODO: draw layers
    }

    void drawGrid(Context ctx) {
        ctx.setSourceRgb(.4, .4, .4);
        ctx.setLineCap(cairo_line_cap_t.ROUND);
        ctx.setLineJoin(cairo_line_join_t.ROUND);
        ctx.setLineWidth(1);
        foreach(x; 1..(STATE.scene.width/STATE.tileWidth)+1) {
            ctx.moveTo(STATE.tileWidth*x, 0);
            ctx.lineTo(STATE.tileWidth*x, STATE.scene.height);
        }

        foreach(y; 1..(STATE.scene.height/STATE.tileHeight)+1) {
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

        ctx.setLineWidth(2);
        ctx.setSourceRgba(.5, .4, .0, .5);
        foreach(x; 1..(STATE.scene.width/STATE.scene.quadBasisX)+1) {
            ctx.moveTo(STATE.scene.quadBasisX*x, 0);
            ctx.lineTo(STATE.scene.quadBasisX*x, STATE.scene.height);
        }

        foreach(y; 1..(STATE.scene.height/STATE.scene.quadBasisX)+1) {
            ctx.moveTo(0, STATE.scene.quadBasisY*y);
            ctx.lineTo(STATE.scene.width, STATE.scene.quadBasisY*y);   
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

    void drawSelection(Context ctx) {
        if (!isSelecting) return;

        animOffset += 0.1;
        ctx.setDash([8.0], animOffset);

        ctx.setSourceRgb(.5, .5, .8);
        ctx.setLineCap(cairo_line_cap_t.ROUND);
        ctx.setLineJoin(cairo_line_join_t.ROUND);
        ctx.setLineWidth(4);

        ctx.moveTo(STATE.selection.x, STATE.selection.y);
        ctx.lineTo(STATE.selection.toX, STATE.selection.y);
        ctx.lineTo(STATE.selection.toX, STATE.selection.toY);
        ctx.lineTo(STATE.selection.x, STATE.selection.toY);
        ctx.lineTo(STATE.selection.x, STATE.selection.y);
        ctx.closePath();
        ctx.stroke();
    }

    bool isMovingCamera = false;
    double dragOriginX = 0;
    double dragOriginY = 0;
    double cameraOriginX = 0;
    double cameraOriginY = 0;

    bool isSelecting = false;

    bool onMotion(GdkEventMotion* motion, Widget widget) {
        mouseX = motion.x;
        mouseY = motion.y;

        // Handle positioning of the mouse in terms of tiles.
        handlePositioning();

        if (isMovingCamera) {
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

        STATE.selection.x = -1;
        STATE.selection.y = -1;

        int aw = area.width/2;
        int ah = area.height/2;

        sceneMouseX = ((mouseX/camera.zoom)-(aw/camera.zoom))-camera.x;
        sceneMouseY = ((mouseY/camera.zoom)-(ah/camera.zoom))-camera.y;
        sceneMouseToX = ((dragOriginX/camera.zoom)-(aw/camera.zoom))-camera.x;
        sceneMouseToY = ((dragOriginY/camera.zoom)-(ah/camera.zoom))-camera.y;

        // Flip origin and end if needed
        if (sceneMouseToX < sceneMouseX) {
            double iX = sceneMouseToX;
            sceneMouseToX = sceneMouseX;
            sceneMouseX = iX;
        }

        if (sceneMouseToY < sceneMouseY) {
            double iY = sceneMouseToY;
            sceneMouseToY = sceneMouseY;
            sceneMouseY = iY;
        }

        // Selections need to be in-bounds
        if (sceneMouseX < 0) sceneMouseX = 0;
        if (sceneMouseY < 0) sceneMouseY = 0;
        if (sceneMouseX >= STATE.scene.width) sceneMouseX = STATE.scene.width;
        if (sceneMouseY >= STATE.scene.height) sceneMouseY = STATE.scene.height;

        if (sceneMouseToX < 0) sceneMouseToX = 0;
        if (sceneMouseToY < 0) sceneMouseToY = 0;
        if (sceneMouseToX >= STATE.scene.width) sceneMouseToX = STATE.scene.width-1;
        if (sceneMouseToY >= STATE.scene.height) sceneMouseToY = STATE.scene.height-1;

        // TODO: If not in grid mode, don't snap to grid

        int tileXPos = (cast(int)sceneMouseX/STATE.tileWidth);
        int tileYPos = (cast(int)sceneMouseY/STATE.tileWidth);
        int tileToXPos = (cast(int)sceneMouseToX/STATE.tileWidth)+1;
        int tileToYPos = (cast(int)sceneMouseToY/STATE.tileWidth)+1;

        STATE.selection.x = tileXPos*STATE.tileWidth;
        STATE.selection.y = tileYPos*STATE.tileHeight;
        STATE.selection.toX = tileToXPos*STATE.tileWidth;
        STATE.selection.toY = tileToYPos*STATE.tileHeight;
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
            if (ev.button == 3 && !isMovingCamera) {
                this.isMovingCamera = true;
                this.isSelecting = false;
                dragOriginX = ev.x;
                dragOriginY = ev.y;
                cameraOriginX = camera.x;
                cameraOriginY = camera.y;
                setCursor(new Cursor(this.getDisplay(), CursorType.HAND1));
            } else if (ev.button == 1) {
                this.isMovingCamera = false;
                this.isSelecting = true;
                dragOriginX = ev.x;
                dragOriginY = ev.y;
                cameraOriginX = camera.x;
                cameraOriginY = camera.y;
                handlePositioning();
            } else if (ev.button == 2) {
                camera.zoom = 1;
            }
            return true;
        });

        this.addOnButtonRelease((GdkEventButton* ev, Widget) {
            if (STATE.scene is null) return true;
            if (ev.button == 3) {
                this.isMovingCamera = false;
                setCursor(new Cursor(this.getDisplay(), CursorType.LEFT_PTR));
            }

            if (ev.button == 1) {
                this.isSelecting = false;
                animOffset = 0.0;
            }
            return true;
        });

        this.addOnScroll((GdkEventScroll* scroll, Widget) {
            if (STATE.scene is null) return true;

            camera.zoom += scroll.direction == ScrollDirection.UP ? -0.2 : 0.2;
            if (camera.zoom < 0.1) {
                camera.zoom = 0.1;
            }

            // More than 4x zoom is ridiculous.
            if (camera.zoom > 4) {
                camera.zoom = 4;
            }

            mouseX = scroll.x;
            mouseY = scroll.y;
            handlePositioning();
            queueDraw();
            return true;
        });

        import gtk.Widget : Widget;
        import gdk.FrameClock : FrameClock;
        this.addTickCallback((Widget, FrameClock) {
            queueDraw();
            return true;
        });
    }
}