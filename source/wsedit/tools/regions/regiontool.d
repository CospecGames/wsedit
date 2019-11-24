module wsedit.tools.regions.regiontool;
import wsedit.tools;
import wsedit.ir;
import wsedit.math;

/**
    Select tool
*/
class RegionTool : Tool {
private:

    int startX;
    int startY;

    int mstartX;
    int mstartY;
    
    Region selectedRegion;

public:

    this(Workspace workspace, ToolGroup group) {
        super("Region Tool", "zoom-fit-best-symbolic", group, workspace);
    }
    
    override void draw(Renderer renderer) {
    
    }

    override void update(Mouse mouse) {
        int tileWidth = workspace.scene.tileSize.x;
        int tileHeight = workspace.scene.tileSize.y;

        Vector2 mousePosition = workspace.camera.toScene(mouse.position);

        // We've stopped dragging
        if (mouse.isButtonReleased(MouseButton.Left) && selectedRegion !is null) {
            selectedRegion = null;
        }
        
        // We've started dragging
        if (mouse.isButtonPressed(MouseButton.Left) && selectedRegion is null) {

            int tileX = (cast(int)mousePosition.x)/tileWidth;
            int tileY = (cast(int)mousePosition.y)/tileHeight;

            foreach(region; workspace.scene.regions) {
                if (region.area.intersects(Vector2i(tileX, tileY))) {

                    // The internal selected region is only for moving
                    selectedRegion = region;

                    // This region is for the toolbar :)
                    workspace.selectedRegion = region;

                    startX = region.area.x;
                    startY = region.area.y;
                    mstartX = cast(int)mousePosition.x;
                    mstartY = cast(int)mousePosition.y;
                    continue;
                }
            }
        }

        // We're dragging
        if (mouse.isButtonPressed(MouseButton.Left) && selectedRegion !is null) {

            int tileX = ((cast(int)mousePosition.x)-mstartX)/tileWidth;
            int tileY = ((cast(int)mousePosition.y)-mstartY)/tileHeight;

            selectedRegion.area.x = startX+tileX;
            selectedRegion.area.y = startY+tileY;
            foreach(region; workspace.scene.regions) {
                region.scanOverlaps();
            }
        }
    }
}