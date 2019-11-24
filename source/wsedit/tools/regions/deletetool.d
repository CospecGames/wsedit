module wsedit.tools.tiles.deletetool;
import wsedit.tools;

/**
    Select tool
*/
class SelectTool : Tool {
private:

public:
    this(Workspace workspace, ToolGroup group) {
        super("Eraser Tool", "edit-delete-symbolic", group, workspace);
    }
    
    override void draw(Renderer renderer) {
    
    }

    override void update(Mouse mouse) {

    }
}