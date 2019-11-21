module wsedit.tools.camera.zonetool;
import wsedit.tools;

/**
    Select tool
*/
class ZoneTool : Tool {
private:

public:
    this(Workspace workspace, ToolGroup group) {
        super("Zone Tool", "edit-select-all-symbolic", group, workspace);
    }
    
    override void draw(Renderer renderer) {
    
    }

    override void update(Mouse mouse) {

    }
}