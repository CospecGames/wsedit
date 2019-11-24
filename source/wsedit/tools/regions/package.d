module wsedit.tools.regions;
import wsedit.tools;
import wsedit.math;
import std.format;

public import wsedit.tools.regions.regiontool;
public import wsedit.tools.regions.createtool;

class RegionsGroup : ToolGroup {
public:
    this(Workspace workspace) {
        super("Regions", "zoom-fit-best-symbolic", workspace);
        tools = [new RegionTool(workspace, this), new CreateTool(workspace, this)];
    }

    override void draw(Renderer renderer) {
        int twidth = workspace.scene.tileSize.x;
        int theight = workspace.scene.tileSize.y;
        
        foreach(id, region; workspace.scene.regions) {
            auto center = region.area.center();
            renderer.renderBadge("%s".format(id), Vector2(center.x*twidth, center.y*theight), 1.1/workspace.camera.zoom);

            if (region.isOverlapping) {
                double areaX = (cast(double)region.area.x*cast(double)twidth)+64;
                double areaY = (cast(double)region.area.y*cast(double)theight)+32;

                renderer.renderBadge("Error: Overlap", Vector2(areaX, areaY));
            }

            if (region.area.x < 0 || region.area.y < 0) {
                double areaX = (cast(double)region.area.x*cast(double)twidth)+64;
                double areaY = (cast(double)region.area.y*cast(double)theight)+64;

                renderer.renderBadge("Error: OOB", Vector2(areaX, areaY));
            }
        }
    }
}