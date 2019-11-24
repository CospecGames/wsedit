module wsedit.tools.tiles;
import wsedit.tools;
public import wsedit.tools.tiles.erasetool;
public import wsedit.tools.tiles.brushtool;
public import wsedit.tools.tiles.selecttool;

class TileGroup : ToolGroup {
public:
    this(Workspace workspace) {
        super("Tiles", "view-grid-symbolic", workspace);
        tools = [new SelectTool(workspace, this), new TileBrushTool(workspace, this), new EraseTool(workspace, this)];
    }
}