module wsedit.tools.selecttool;
import wsedit.tools;

/**
    Select tool
*/
class SelectTool : Tool {
private:

public:
    this(Workspace workspace) {
        super("Select", "edit-select-all-symbolic", workspace);
    }
}