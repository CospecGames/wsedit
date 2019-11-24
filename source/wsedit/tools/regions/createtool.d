module wsedit.tools.regions.createtool;
import wsedit.tools;
import wsedit.math;
import wsedit.ir;

/**
    Region Creator tool
*/
class CreateTool : Tool {
private:

    bool isCreating;

    int startX;
    int startY;
    int endX;
    int endY;

    int mstartX;
    int mstartY;

    int mouseX;
    int mouseY;

    int fMouseX;
    int fMouseY;

public:
    this(Workspace workspace, ToolGroup group) {
        super("Region Creator Tool", "insert-object-symbolic", group, workspace);
    }
    
    override void draw(Renderer renderer) {
        int tileWidth = workspace.scene.tileSize.x;
        int tileHeight = workspace.scene.tileSize.y;

        if (isCreating && endX > 0 && endY > 0) {
            renderer.renderGrid(
                Rectangle(
                    startX, 
                    startY, 
                    endX, 
                    endY
                )
            );
        }
    }

    override void postDraw(Renderer renderer) {
        if (isCreating && (endX <= 0 || endY <= 0)) {
            renderer.renderBadge("Cancel?", Vector2(fMouseX, fMouseY+32), 1.4);
        } 
    }

    override void update(Mouse mouse) {
        int tileWidth = workspace.scene.tileSize.x;
        int tileHeight = workspace.scene.tileSize.y;

        Vector2 mousePosition = workspace.camera.toScene(mouse.position);

        mouseX = cast(int)mousePosition.x;
        mouseY = cast(int)mousePosition.y;
        fMouseX = cast(int)mouse.position.x;
        fMouseY = cast(int)mouse.position.y;

        if (mouse.isButtonPressed(MouseButton.Left) && !isCreating) {
            isCreating = true;
            mstartX = mouseX;
            mstartY = mouseY;

            startX = mstartX/tileWidth;
            startY = mstartY/tileHeight;
        }

        endX = ((mouseX-mstartX)/tileWidth)+1;
        endY = ((mouseY-mstartY)/tileHeight)+1;


        if (mouse.isButtonReleased(MouseButton.Left) && isCreating) {
            if (endX <= 0 || endY <= 0) {
                isCreating = false;
                return;
            } 
            workspace.scene.regions ~= new Region(workspace.scene, Rectangle(startX, startY, endX, endY));
            foreach(region; workspace.scene.regions) {
                region.scanOverlaps();
            }
            isCreating = false;
        }
    }
}