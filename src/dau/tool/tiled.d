module dau.tool.tiled;

import std.conv;
import std.range;
import std.file;
import std.algorithm;
import dau.engine;
import dau.graphics.all;
import dau.util.jsonizer;

auto loadTiledMap(string path) {
  assert(path.exists, "no map file found at " ~ path);
  return readJSON!MapData(path);
}

class TileData {
  int row, col;
  int tilesetIdx;
  string tilesetName;
  string[string] properties;
}

class MapData {
  mixin JsonizeMe;

  enum Orientation {
    orthogonal,
    isometric
  }

  @jsonize {
    int width, height;         // in number of tiles
    int tilewidth, tileheight; // in pixels
    float opacity;
    Orientation orientation;
    string[string] properties;
    MapLayer[] layers;
    TileSet[] tilesets;
  }

  TileRange layerTileData(int idx) {
    assert(idx >= 0 && idx < layers.length, "no layer at idx " ~ idx.to!string);
    return TileRange(layers[idx], tilesets);
  }

  TileRange layerTileData(string name) {
    auto idx = layers.countUntil!(x => name == x.name);
    assert(idx >= 0, "no layer named " ~ name);
    return layerTileData(idx.to!int);
  }

  struct TileRange {
    this(MapLayer layer, TileSet[] tilesets) {
      _layer = layer;
      _tilesets = tilesets;
    }

    @property {
      bool empty() {
        return _idx == _layer.width * _layer.height;
      }

      TileData front() {
        auto data = new TileData;
        auto gid = _layer.data[_idx];
        auto tileset = gidToTileset(gid);
        data.row = _idx / _layer.width;
        data.col = _idx % _layer.width;
        data.tilesetIdx = gid - tileset.firstgid;
        data.tilesetName = tileset.name;
        data.properties = tileset.properties;
        return data;
      }
    }

    void popFront() {
      ++_idx;
    }

    private:
    MapLayer _layer;
    TileSet[] _tilesets;
    int _idx;

    TileSet gidToTileset(int gid) {
      if (gid == 0) { return null; }
      auto tileset = _tilesets.find!(x => x.firstgid <= gid);
      assert(!tileset.empty, "could not match gid " ~ to!string(gid));
      return tileset.front;
    }
  }
}

class MapLayer {
  enum Type {
    tilelayer,
    objectgroup
  }

  mixin JsonizeMe;

  @jsonize {
    int[] data;
    MapObject[] objects;
    int width, height;
    string name;
    float opacity;
    Type type;
    bool visible;
    int x, y;
  }
}

class MapObject {
  mixin JsonizeMe;
  @jsonize {
    int gid;
    int width, height;
    string name;
    string type;
    string[string] properties;
    bool visible;
    int x, y;
  }
}

class TileSet {
  mixin JsonizeMe;
  @jsonize {
    int firstgid;
    string image;
    string name;
    int tilewidth, tileheight;
    int imagewidth, imageheight;
    string[string] properties;
    string[string][string] tileproperties;
  }
}
