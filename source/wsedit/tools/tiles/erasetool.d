module wsedit.tools.tiles.erasetool;
import wsedit.tools;
import wsedit;
import wsedit.fmt;

/**
    Eraser tool
*/
class EraseTool : Tool {
private:
    uint mouseX;
    uint mouseY;

    uint lastMouseX = uint.max;
    uint lastMouseY = uint.max;


public:
    this(Workspace workspace, ToolGroup group) {
        super("Erase Tool", "edit-delete-symbolic", group, workspace);
    }

    override void draw(Renderer renderer) {

        uint scWidth =  workspace.project.sceneInfo.width;
        uint scHeight = workspace.project.sceneInfo.height;
        
        uint width =  workspace.project.sceneInfo.tileWidth;
        uint height = workspace.project.sceneInfo.tileHeight;

        uint msX = mouseX*width;
        uint msY = mouseY*height;

        if (!(mouseX >= 0 && mouseY >= 0 && mouseX < scWidth && mouseY < scHeight)) return;
        renderer.renderSelection(Selection(msX, msY, width, height));
    }

    override void update(Mouse mouse) {
        uint width =  workspace.project.sceneInfo.tileWidth;
        uint height = workspace.project.sceneInfo.tileHeight;

        uint scWidth =  workspace.project.sceneInfo.width;
        uint scHeight = workspace.project.sceneInfo.height;

        Vector2 oPos = workspace.camera.toScene(
            Vector2(
                mouse.position.x, 
                mouse.position.y
            )
        );
        mouseX = cast(uint)oPos.x/width;
        mouseY = cast(uint)oPos.y/height;

        if (!(mouseX >= 0 && mouseY >= 0 && mouseX < scWidth && mouseY < scHeight)) return;
        if (lastMouseX == mouseX && lastMouseY == mouseY) return;

        if (mouse.isButtonPressed(MouseButton.Left)) {
            workspace.project.scene.layers[0].removeTileAt(mouseX, mouseY);

            lastMouseX = mouseX;
            lastMouseY = mouseY;
            
        }

        if (mouse.isButtonReleased(MouseButton.Left)) {
            lastMouseX = uint.max;
            lastMouseY = uint.max;
        }
    }
}