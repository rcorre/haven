module battle.state.deployunit;

import dau.all;
import model.all;
import battle.battle;
import battle.system.undomove;

class DeployUnit : State!Battle {
  this (Player player, Tile tile, string key) {
    _player = player;
    _tile = tile;
    _key = key;
  }

  override {
    void start(Battle b) {
      auto unit = b.spawnUnit(_key, _player, _tile);
      _player.consumeCommandPoints(unit.deployCost);
      b.refreshBattlePanel();
      b.states.popState;
      b.getSystem!UndoMoveSystem.clearMoves();
    }
  }

  private:
  Tile   _tile;
  Player _player;
  string _key;
}
