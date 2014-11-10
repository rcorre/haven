module model.trap;

import std.string : format;
import dau.all;
import model.unitaction;

private enum spriteFormat = "%s_trap";

class Trap : Entity {
  const int team;
  const UnitAction effect;

  this(string key, Vector2i pos, int team, const UnitAction effect) {
    auto sprite = new Animation(spriteFormat.format(key), "idle", Animation.Repeat.loop);
    super(pos, sprite, "trap");
    this.team = team;
    this.effect = effect;
  }
}
