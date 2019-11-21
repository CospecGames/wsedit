module wsedit.tools.tiles.selecttool;
import wsedit.tools;

/**
    Select tool
*/
class SelectTool : Tool {
private:

public:
    this(Workspace workspace, ToolGroup group) {
        super("Select Tool", "edit-select-all-symbolic", group, workspace);
    }
    
    override void draw(Renderer renderer) {
    
    }

    override void update(Mouse mouse) {

    }
}