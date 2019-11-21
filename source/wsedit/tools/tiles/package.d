module wsedit.tools.tiles;
import wsedit.tools;
public import wsedit.tools.tiles.erasetool;
public import wsedit.tools.tiles.tiletool;
public import wsedit.tools.tiles.selecttool;

class TileGroup : ToolGroup {
public:
    this(Workspace workspace) {
        super("Tiles", "view-grid-symbolic", workspace);
        tools = [new TileTool(workspace, this), new SelectTool(workspace, this), new EraseTool(workspace, this)];
    }
}