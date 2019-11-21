module wsedit.tools.tiles.tiletool;
import wsedit.tools;
import wsedit;
import wsedit.fmt;

/**
    Tile tool
*/
class TileTool : Tool {
private:
    uint mouseX;
    uint mouseY;

    uint lastMouseX = uint.max;
    uint lastMouseY = uint.max;


public:
    this(Workspace workspace, ToolGroup group) {
        super("Tile Tool", "insert-object-symbolic", group, workspace);
    }

    override void draw(Renderer renderer) {

        uint scWidth =  workspace.project.sceneInfo.width;
        uint scHeight = workspace.project.sceneInfo.height;

        if (!(mouseX >= 0 && mouseY >= 0 && mouseX < scWidth && mouseY < scHeight)) return;
        renderer.renderTile(workspace.tiles.selected, mouseX, mouseY, workspace.tiles.hflip, workspace.tiles.vflip, true);
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
            WSETile tile;
            tile.hflip = workspace.tiles.hflip;
            tile.vflip = workspace.tiles.vflip;
            tile.tileIdX = workspace.tiles.position().x;
            tile.tileIdY = workspace.tiles.position().y;
            tile.x = mouseX;
            tile.y = mouseY;
            workspace.project.scene.layers[0].place(tile);

            lastMouseX = mouseX;
            lastMouseY = mouseY;
        }

        if (mouse.isButtonReleased(MouseButton.Left)) {
            lastMouseX = uint.max;
            lastMouseY = uint.max;
        }
    }
}