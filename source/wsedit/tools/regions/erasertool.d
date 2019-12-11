module wsedit.tools.regions.erasertool;
import wsedit.tools;
import wsedit.math;

/**
    Eraser tool
*/
class EraserTool : Tool {
private:

public:
    this(Workspace workspace, ToolGroup group) {
        super("Eraser Tool", "edit-delete-symbolic", group, workspace);
    }
    
    override void draw(Renderer renderer) {
    
    }

    override void update(Mouse mouse) {
        int tileWidth = workspace.scene.tileSize.x;
        int tileHeight = workspace.scene.tileSize.y;

        Vector2 mousePosition = workspace.camera.toScene(mouse.position);


        // We've started dragging
        if (mouse.isButtonPressed(MouseButton.Left)) {

            int tileX = (cast(int)mousePosition.x)/tileWidth;
            int tileY = (cast(int)mousePosition.y)/tileHeight;

            foreach(i; 0..workspace.scene.regions.count) {
                if (workspace.scene.regions[i].area.intersects(Vector2i(tileX, tileY))) {
                    workspace.scene.regions.removeAt(i);
                    continue;
                }
            }
        }
    }
}