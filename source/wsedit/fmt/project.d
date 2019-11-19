/**
    Copyright © 2019, Cospec Games

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module wsedit.fmt.project;
import wsf.serialization;
import std.file;
import wsedit.fmt.resource;
import std.algorithm.searching : endsWith;

/**
    Creates a new project
*/
WSEProject newProject(string name, string path, WSESceneInfo info) {
    WSEProject project;
    project.name = name;
    project.path = path;
    project.sceneInfo = info;
    return project;
}

/**
    Loads a WereShift Editor Project
*/
WSEProject loadProject(string file) {
    auto project = deserializeWSF!WSEProject(Tag.parseFile(file));
    project.path = file;
    return project;
}

/**
    Build a WereShift Editor Project
*/
void saveProject(WSEProject project, string file) {
    Tag tag = serializeWSF!WSEProject(project);
    tag.buildFile(file.endsWith(".wsp") ? file : file~".wsp");
}

/**
    A wereshift editor project file
*/
struct WSEProject {

    /**
        Name of the project
    */
    string name;

    /**
        Path to save the project to
    */
    @ignore
    string path;

    /**
        List of resources
    */
    WSEResource[] resources;

    /**
        Information about the scene
    */
    WSESceneInfo sceneInfo;

    /**
        Information about the tiles in the tileset
    */
    WSETilesetInfo[] tilesetInfo;

    void save(string file = null) {
        saveProject(this, file is null ? path : file);
    }
}

/**
    Relevant scene info
*/
struct WSESceneInfo {
    /**
        Width of scene in tiles
    */
    uint width;

    /**
        Height of scene in tiles
    */
    uint height;

    /**
        Width of a single tile
    */
    uint tileWidth;

    /**
        Height of a single tile
    */
    uint tileHeight;
}

/**
    Information about a tileset tile
*/
struct WSETilesetInfo {
    /**
        The X index of the tile in the tilesheet
    */
    uint tileX;

    /**
        The Y Index of the tile in the tilesheet
    */
    uint tileY;
}