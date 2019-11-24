module wsedit.tools.tiles.erasetool;
import wsedit.tools;
import wsedit;
import wsedit.ir;

/**
    Eraser tool

    TODO: Improve stability of the tool
*/
class EraseTool : Tool {
private:
    uint mouseX;
    uint mouseY;

    uint startX;
    uint startY;

    bool isDeleting;

public:
    this(Workspace workspace, ToolGroup group) {
        super("Eraser Tool", "edit-delete-symbolic", group, workspace);
    }

    override void draw(Renderer renderer) {

        // uint region = workspace.selectedRegion;
        // uint scWidth =  workspace.scene.regions[region].area.width;
        // uint scHeight = workspace.scene.regions[region].area.height;
        
        // uint width =  workspace.scene.tileSize.x;
        // uint height = workspace.scene.tileSize.y;

        // if (isDeleting) {

        //     int dStartX = startX;
        //     int dWidth = (mouseX-startX)+1;

        //     int dStartY = startY;
        //     int dHeight = (mouseY-startY)+1;

        //     if (dWidth <= 0) {
        //         dStartX = mouseX;
        //         dWidth = (startX-mouseX)+1;
        //     }

        //     if (dHeight <= 0) {
        //         dStartY = mouseY;
        //         dHeight = (startY-mouseY)+1;
        //     }

        //     renderer.renderOutline(
        //         Selection(
        //             dStartX*width, 
        //             dStartY*height, 
        //             dWidth*width, 
        //             dHeight*height
        //         ),
        //         Color(.9, .4, .4)
        //     );
        // } else {
        //     if (!(mouseX >= 0 && mouseY >= 0 && mouseX < scWidth && mouseY < scHeight)) return;
        //     renderer.renderOutline(Selection(mouseX*width, mouseY*height, scWidth, scHeight), Color(.9, .4, .4));
        // }
    }

    override void update(Mouse mouse) {
        // uint width =  workspace.project.sceneInfo.tileWidth;
        // uint height = workspace.project.sceneInfo.tileHeight;

        // uint scWidth =  workspace.project.sceneInfo.width;
        // uint scHeight = workspace.project.sceneInfo.height;

        // Vector2 oPos = workspace.camera.toScene(
        //     Vector2(
        //         mouse.position.x, 
        //         mouse.position.y
        //     )
        // );
        // mouseX = cast(uint)oPos.x/width;
        // mouseY = cast(uint)oPos.y/height;


        // forceLimits(mouseX, mouseY, scWidth, scHeight);
        // forceLimits(startX, startY, scWidth, scHeight);

        // if (mouse.isButtonPressed(MouseButton.Left) && !isDeleting) {
        //     startX = mouseX;
        //     startY = mouseY;
            
        //     isDeleting = true;
        // }

        // if (mouse.isButtonReleased(MouseButton.Left) && isDeleting) {
        //     uint tstartX = startX;
        //     uint tstartY = startY;

        //     if (startX == mouseX && startY == mouseY) {
        //         workspace.project.scene.layers[0].removeTileAt(mouseX, mouseY);
        //         isDeleting = false;
        //         return;
        //     }

        //     fixSelection(tstartX, mouseX);
        //     fixSelection(tstartY, mouseY);

        //     foreach(y; tstartY..mouseY+1) {
        //         foreach(x; tstartX..mouseX+1) {
        //             workspace.project.scene.layers[0].removeTileAt(x, y);
        //         }
        //     }
        //     isDeleting = false;
        // }
    }

    void fixSelection(ref uint lowest, ref uint highest) {
        if (lowest > highest) {
            uint tmp = lowest;

            lowest = highest;
            highest = tmp;
        }
    }

    void forceLimits(ref uint x, ref uint y, uint width, uint height) {
        forceLimit(x, width);
        forceLimit(y, height);
    }

    void forceLimit(ref uint i, uint max) {
        if (i < 0) i = 0;
        if (i >= max) i = max;
    }
}