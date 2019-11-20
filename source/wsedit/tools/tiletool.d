module wsedit.tools.tiletool;
import wsedit.tools;
import wsedit;

/**
    Tile tool
*/
class TileTool : Tool {
private:
    uint mouseX;
    uint mouseY;

public:
    this(Workspace workspace) {
        super("Tile Tool", "view-grid-symbolic", workspace);
    }

    override void draw(Renderer renderer) {

        uint scWidth =  workspace.project.sceneInfo.width;
        uint scHeight = workspace.project.sceneInfo.height;

        if (!(mouseX > 0 && mouseY > 0 && mouseX < scWidth && mouseY < scHeight)) return;
        renderer.renderTile(workspace.tiles.selected, mouseX, mouseY, workspace.tiles.hflip, workspace.tiles.vflip, true);
    }

    override void update(Mouse mouse) {
        uint width =  workspace.project.sceneInfo.tileWidth;
        uint height = workspace.project.sceneInfo.tileHeight;

        Vector2 oPos = workspace.camera.toScene(
            Vector2(
                mouse.position.x, 
                mouse.position.y
            )
        );
        mouseX = cast(uint)oPos.x/width;
        mouseY = cast(uint)oPos.y/height;
    }
}