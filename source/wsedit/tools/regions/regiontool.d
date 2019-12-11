module wsedit.tools.regions.regiontool;
import wsedit.tools;
import wsedit.ir;
import wsedit.ir.scene;
import wsedit.math;
import std.format;

enum ResizeMode {
    None = 0,
    Right = 1,
    Bottom = 2,
    Corner = 3,
}

enum HANDLE_RADIUS = 8.0;

/**
    Select tool
*/
class RegionTool : Tool {
private:

    int startX;
    int startY;

    int mstartX;
    int mstartY;

    ResizeMode resizeMode;
    
    Region selectedRegion;
    Region hRegion;
    Vector2 mousePosition;
    Vector2 surfMousePosition;


public:

    this(Workspace workspace, ToolGroup group) {
        super("Region Tool", "zoom-fit-best-symbolic", group, workspace);
    }
    
    override void draw(Renderer renderer) {
        if (hRegion !is null) {
            Vector2 renderPos = Vector2(
                surfMousePosition.x+(32*workspace.camera.zoom), 
                surfMousePosition.y+(32*workspace.camera.zoom)
            );

            renderer.renderBadge(
                resizeMode == ResizeMode.None ? 
                    "Move" : "Resize", 
                workspace.camera.toScene(renderPos), 
                1.1/workspace.camera.zoom
            );
        }
    }

    override void update(Mouse mouse) {
        int tileWidth = workspace.scene.tileSize.x;
        int tileHeight = workspace.scene.tileSize.y;

        mousePosition = workspace.camera.toScene(mouse.position);
        surfMousePosition = mouse.position;

        // We've stopped dragging
        if (mouse.isButtonReleased(MouseButton.Left) && selectedRegion !is null) {
            selectedRegion = null;
        }

        // Prepare tile position
        int tileX = cast(int)(mousePosition.x/cast(double)tileWidth);
        int tileY = cast(int)(mousePosition.y/cast(double)tileHeight);

        // Handle modes
        if (selectedRegion is null) {
            hRegion = null;
            resizeMode = ResizeMode.None;

            foreach(region; workspace.scene.regions) {
                Rectangle actualArea = Rectangle(
                    region.area.x*tileWidth, 
                    region.area.y*tileHeight, 
                    (region.area.width*tileWidth)+cast(int)HANDLE_RADIUS,
                    (region.area.height*tileHeight)+cast(int)HANDLE_RADIUS
                );
                
                if (actualArea.intersects(mousePosition)) {
                    hRegion = region;

                    double right = region.area.right*tileWidth;
                    double bottom = region.area.bottom*tileHeight;

                    double selX = clamp(mousePosition.x, region.area.left*tileWidth, region.area.right*tileWidth);
                    double selY = clamp(mousePosition.y, region.area.top*tileHeight, region.area.bottom*tileHeight);

                    if (mousePosition.isInCircle(Vector2(selX, bottom), HANDLE_RADIUS)) {
                        resizeMode |= ResizeMode.Bottom;
                    }

                    if (mousePosition.isInCircle(Vector2(right, selY), HANDLE_RADIUS)) {
                        resizeMode |= ResizeMode.Right;
                    }

                    mstartX = cast(int)mousePosition.x;
                    mstartY = cast(int)mousePosition.y;

                    if (!resizeMode) {
                        startX = region.area.x;
                        startY = region.area.y;
                    } else {
                        startX = region.area.width;
                        startY = region.area.height;
                    }

                    if (mouse.isButtonPressed(MouseButton.Left)) {
                        // The internal selected region is only for moving
                        selectedRegion = region;

                        // This region is for the toolbar :)
                        workspace.selectedRegion = region;
                    }                    
                    break;
                }
            }
        }

        // We're dragging
        if (mouse.isButtonPressed(MouseButton.Left) && selectedRegion !is null) {

            tileX = ((cast(int)mousePosition.x)-mstartX)/tileWidth;
            tileY = ((cast(int)mousePosition.y)-mstartY)/tileHeight;

            if (resizeMode > 0) {
                // RESIZE MODE
                if ((resizeMode & ResizeMode.Right) > 0) {
                    selectedRegion.area.width = startX+tileX;
                    if (selectedRegion.area.width <= 1) selectedRegion.area.width = 1;
                }

                if ((resizeMode & ResizeMode.Bottom) > 0) {
                    selectedRegion.area.height = startY+tileY;
                    if (selectedRegion.area.height <= 1) selectedRegion.area.height = 1;
                }

                foreach(region; workspace.scene.regions) {
                    region.scanOverlaps();
                }
            } else {
                // MOVE MODE
                selectedRegion.area.x = startX+tileX;
                selectedRegion.area.y = startY+tileY;
                foreach(region; workspace.scene.regions) {
                    region.scanOverlaps();
                }
            }
        }
    }
}