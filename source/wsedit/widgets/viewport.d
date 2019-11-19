module wsedit.widgets.viewport;
import gtk.DrawingArea;
import wsedit.subsystem.wsrenderer;

/**
    The editor workspace
*/
class WSViewport : DrawingArea {
private:
//     double animOffset = 0.0;

//     double mouseX;
//     double mouseY;

//     double sceneMouseX = 0;
//     double sceneMouseY = 0;
//     double sceneMouseToX = 0;
//     double sceneMouseToY = 0;

//     /* Basic Rendering*/
//     GdkRectangle area;
//     Pixbuf wereshiftLogo;
//     RecordingSurface grid;
//     Pattern gridPattern;

//     bool onDraw(Context ctx) {

//         // First, clear the last pass.
//         ctx.setSourceRgba(0, 0, 0, 0);
//         ctx.paint();

//         // If we haven't loaded our scene, draw our "no scene" graphic.
//         if (STATE.currentSceneFile is null) {
//             drawUnInit(ctx);
//             return true;
//         }

//         drawScene(ctx);
//         return true;
//     }

//     void drawUnInit(Context ctx) {
        
//         // Get useful info for rendering.
//         int originX = wereshiftLogo.getWidth()/2;
//         int originY = wereshiftLogo.getHeight()/2;

//         ctx.selectFontFace("", cairo_font_slant_t.NORMAL, cairo_font_weight_t.BOLD);
//         ctx.setFontSize(18);

//         cairo_text_extents_t extents;
//         ctx.textExtents(InfoNoScene, &extents);

//         // Black background
//         ctx.setSourceRgb(0, 0, 0);
//         ctx.paint();

//         // Draw wereshift logo
//         ctx.translate(area.width/2, area.height/2);
//         ctx.setSourcePixbuf(wereshiftLogo, -originX, -originY);
//         ctx.paint();

//         // Draw info text
//         ctx.translate(-(extents.width/2), originY-32);
//         ctx.setSourceRgb(1, 1, 1);
//         ctx.showText(InfoNoScene);
//     }

//     void drawScene(Context ctx) {

//         // Set camera
//         ctx.translate((area.width/2), (area.height/2));
//         ctx.scale(camera.zoom, camera.zoom);
//         ctx.translate(camera.x, camera.y);

//         drawGrid(ctx);
//         drawSelection(ctx);

//         // Disable antialias and start drawing all the layers
//         ctx.setAntialias(cairo_antialias_t.NONE);
//         // TODO: draw layers
//     }

//     void drawGrid(Context ctx) {
//         ctx.setSourceRgb(.4, .4, .4);
//         ctx.setLineCap(cairo_line_cap_t.ROUND);
//         ctx.setLineJoin(cairo_line_join_t.ROUND);
//         ctx.setLineWidth(1);
//         foreach(x; 1..STATE.scene.tilesX) {
//             ctx.moveTo(STATE.scene.tileWidth*x, 0);
//             ctx.lineTo(STATE.scene.tileWidth*x, STATE.scene.height);
//         }

//         foreach(y; 1..STATE.scene.tilesY) {
//             ctx.moveTo(0, STATE.scene.tileHeight*y);
//             ctx.lineTo(STATE.scene.width, STATE.scene.tileHeight*y);   
//         }
//         ctx.stroke();

//         // Outer lines
//         ctx.moveTo(0, 0);
//         ctx.lineTo(STATE.scene.width, 0);
//         ctx.lineTo(STATE.scene.width, STATE.scene.height);
//         ctx.lineTo(0, STATE.scene.height);
//         ctx.lineTo(0, 0);
//         ctx.stroke();

//         ctx.setLineWidth(2);
//         ctx.setSourceRgba(.5, .4, .0, .5);
//         foreach(x; 1..(STATE.scene.width/STATE.scene.quadBasisX)+1) {
//             ctx.moveTo(STATE.scene.quadBasisX*x, 0);
//             ctx.lineTo(STATE.scene.quadBasisX*x, STATE.scene.height);
//         }

//         foreach(y; 1..(STATE.scene.height/STATE.scene.quadBasisX)+1) {
//             ctx.moveTo(0, STATE.scene.quadBasisY*y);
//             ctx.lineTo(STATE.scene.width, STATE.scene.quadBasisY*y);   
//         }
//         ctx.stroke();

//         // Outer lines
//         ctx.moveTo(0, 0);
//         ctx.lineTo(STATE.scene.width, 0);
//         ctx.lineTo(STATE.scene.width, STATE.scene.height);
//         ctx.lineTo(0, STATE.scene.height);
//         ctx.lineTo(0, 0);
//         ctx.stroke();
//     }

//     void drawSelection(Context ctx) {
//         if (!isSelecting) return;

//         animOffset += 0.1;
//         ctx.setDash([8.0], animOffset);

//         ctx.setSourceRgb(.5, .5, .8);
//         ctx.setLineCap(cairo_line_cap_t.ROUND);
//         ctx.setLineJoin(cairo_line_join_t.ROUND);
//         ctx.setLineWidth(4);

//         ctx.moveTo(STATE.selection.x, STATE.selection.y);
//         ctx.lineTo(STATE.selection.toX, STATE.selection.y);
//         ctx.lineTo(STATE.selection.toX, STATE.selection.toY);
//         ctx.lineTo(STATE.selection.x, STATE.selection.toY);
//         ctx.lineTo(STATE.selection.x, STATE.selection.y);
//         ctx.closePath();
//         ctx.stroke();
//     }

//     bool isMovingCamera = false;
//     double dragOriginX = 0;
//     double dragOriginY = 0;
//     double cameraOriginX = 0;
//     double cameraOriginY = 0;

//     bool isSelecting = false;

//     bool onMotion(GdkEventMotion* motion, Widget widget) {
//         mouseX = motion.x;
//         mouseY = motion.y;

//         // Handle positioning of the mouse in terms of tiles.
//         handlePositioning();

//         if (isMovingCamera) {
//             camera.x = cameraOriginX - ((dragOriginX - motion.x)/camera.zoom);
//             camera.y = cameraOriginY - ((dragOriginY - motion.y)/camera.zoom);

//             constrainCamera();
//         }
//         queueDraw();
//         return true;
//     }

//     void constrainCamera() {
//         double twidth = STATE.scene.width;
//         double theight = STATE.scene.height;

//         if (camera.x > 0) camera.x = 0;
//         if (camera.x < -twidth) camera.x = -twidth;

//         if (camera.y > 0) camera.y = 0;
//         if (camera.y < -theight) camera.y = -theight;
//     }

//     void handlePositioning() {

//         if (STATE.scene is null) return;

//         STATE.selection.x = -1;
//         STATE.selection.y = -1;

//         int aw = area.width/2;
//         int ah = area.height/2;

//         sceneMouseX = ((mouseX/camera.zoom)-(aw/camera.zoom))-camera.x;
//         sceneMouseY = ((mouseY/camera.zoom)-(ah/camera.zoom))-camera.y;
//         sceneMouseToX = ((dragOriginX/camera.zoom)-(aw/camera.zoom))-camera.x;
//         sceneMouseToY = ((dragOriginY/camera.zoom)-(ah/camera.zoom))-camera.y;

//         // Flip origin and end if needed
//         if (sceneMouseToX < sceneMouseX) {
//             double iX = sceneMouseToX;
//             sceneMouseToX = sceneMouseX;
//             sceneMouseX = iX;
//         }

//         if (sceneMouseToY < sceneMouseY) {
//             double iY = sceneMouseToY;
//             sceneMouseToY = sceneMouseY;
//             sceneMouseY = iY;
//         }

//         // Selections need to be in-bounds
//         if (sceneMouseX < 0) sceneMouseX = 0;
//         if (sceneMouseY < 0) sceneMouseY = 0;
//         if (sceneMouseX >= STATE.scene.width) sceneMouseX = STATE.scene.width;
//         if (sceneMouseY >= STATE.scene.height) sceneMouseY = STATE.scene.height;

//         if (sceneMouseToX < 0) sceneMouseToX = 0;
//         if (sceneMouseToY < 0) sceneMouseToY = 0;
//         if (sceneMouseToX >= STATE.scene.width) sceneMouseToX = STATE.scene.width-1;
//         if (sceneMouseToY >= STATE.scene.height) sceneMouseToY = STATE.scene.height-1;

//         // TODO: If not in grid mode, don't snap to grid

//         int tileXPos = (cast(int)sceneMouseX/STATE.scene.tileWidth);
//         int tileYPos = (cast(int)sceneMouseY/STATE.scene.tileWidth);
//         int tileToXPos = (cast(int)sceneMouseToX/STATE.scene.tileWidth)+1;
//         int tileToYPos = (cast(int)sceneMouseToY/STATE.scene.tileWidth)+1;

//         STATE.selection.x = tileXPos*STATE.scene.tileWidth;
//         STATE.selection.y = tileYPos*STATE.scene.tileHeight;
//         STATE.selection.toX = tileToXPos*STATE.scene.tileWidth;
//         STATE.selection.toY = tileToYPos*STATE.scene.tileHeight;
//     }

// public:
//     /**
//         The workspace camera
//     */
//     Camera2D camera;

//     this() {
//         super(1, 1);
//         wereshiftLogo = new Pixbuf("res/wereshift.png");

//         /* Update */
//         import gtk.Widget : Widget;
//         import gdk.FrameClock : FrameClock;
//         this.addTickCallback((Widget, FrameClock) {
//             queueDraw();
//             return true;
//         });

//         /* Draw */
//         this.addOnDraw((Scoped!Context ctx, Widget _) {
//             return onDraw(ctx);
//         });

//         /* Size alloc */
//         this.addOnSizeAllocate((Allocation alloc, Widget) {
//             area = GdkRectangle(alloc.x, alloc.y, alloc.width, alloc.height);
//         });

//         /* Mouse controls */
//         this.addOnMotionNotify(&onMotion);
//         this.addOnButtonPress((GdkEventButton* ev, Widget) {
//             if (STATE.scene is null) return true;
//             if (ev.button == 3 && !isMovingCamera) {
//                 this.isMovingCamera = true;
//                 this.isSelecting = false;
//                 dragOriginX = ev.x;
//                 dragOriginY = ev.y;
//                 cameraOriginX = camera.x;
//                 cameraOriginY = camera.y;
//                 setCursor(new Cursor(this.getDisplay(), CursorType.HAND1));
//             } else if (ev.button == 1) {
//                 this.isMovingCamera = false;
//                 this.isSelecting = true;
//                 dragOriginX = ev.x;
//                 dragOriginY = ev.y;
//                 cameraOriginX = camera.x;
//                 cameraOriginY = camera.y;
//                 handlePositioning();
//             } else if (ev.button == 2) {
//                 camera.zoom = 1;
//             }
//             return true;
//         });

//         this.addOnButtonRelease((GdkEventButton* ev, Widget) {
//             if (STATE.scene is null) return true;
//             if (ev.button == 3) {
//                 this.isMovingCamera = false;
//                 setCursor(new Cursor(this.getDisplay(), CursorType.LEFT_PTR));
//             }

//             if (ev.button == 1) {
//                 this.isSelecting = false;
//                 animOffset = 0.0;
//             }
//             return true;
//         });

//         this.addOnScroll((GdkEventScroll* scroll, Widget) {
//             if (STATE.scene is null) return true;

//             camera.zoom += scroll.direction == ScrollDirection.UP ? -0.2 : 0.2;
//             if (camera.zoom < 0.1) {
//                 camera.zoom = 0.1;
//             }

//             // More than 4x zoom is ridiculous.
//             if (camera.zoom > 4) {
//                 camera.zoom = 4;
//             }

//             mouseX = scroll.x;
//             mouseY = scroll.y;
//             handlePositioning();
//             queueDraw();
//             return true;
//         });

//     }

public:
    this() {
        super(1, 1);
    }
}