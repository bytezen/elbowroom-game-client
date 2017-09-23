

class Player {
  PVector initPos, pos, prevPos;
  Direction direction = Direction.NONE;
  Direction initDirection = Direction.NONE;
  int speed = 0;
  color c;
  String name;
  boolean alive = false;
  boolean active = false;
  boolean jumpFlag = false;
  int jumpDistance = 40;
  //TODO: Not needed ??
  final int NOTSET = -100;

  Player(String name, float x, float y, color c) {
    this.name = name;
    this.initPos = new PVector(x, y);
    this.pos = initPos.copy();
    this.prevPos = initPos.copy(); 
    this.c = c;
    speed = 0;
  }

  Player(String name, float x, float y, color c, Direction d) {
    this(name, x, y, c);
    this.initDirection = d;
    this.direction = d;
  }

  PVector getPos() { 
    return pos;
  }

  //TODO: implement update based on direction
  PVector update() {
    if (!alive) {
      speed = 0;
      direction = Direction.NONE;
      return pos;
    }
    if (active) {
      if (jumpFlag) {
        switch (direction) {
        case UP:
          pos.y -= jumpDistance;
          break;
        case DOWN:
          pos.y += jumpDistance;
          break;
        case LEFT:
          pos.x -= jumpDistance;
          break;
        case RIGHT:
          pos.x += jumpDistance;
          break;
        case NONE:
          break;
        }
        jumpFlag = false;
      } 
      prevPos.x = pos.x;
      prevPos.y = pos.y;

      int dPos = PLAYER_SIZE * speed;

      switch(this.direction) {
      case UP:
        pos.y -= dPos;
        break;
      case DOWN:
        pos.y += dPos;
        break;
      case LEFT:
        pos.x -= dPos;
        break;
      case RIGHT:
        pos.x += dPos;
        break;
      case NONE:
        break;
      }
    }
    return pos;
  }

  void die() {
    println("[die] " + this);
    alive = false;
  }

  void render(PGraphics pg) {
    if (active) {
      pg.pushStyle();

      // render death    
      if (!alive) {
        pg.pushStyle();
        pg.noStroke();
        pg.fill(255, 0, 0);
        pg.rectMode(CENTER);
        pg.rect(pos.x, pos.y, 10, 10);
        pg.textAlign(CENTER, CENTER);
        pg.text("x", pos.x, pos.y);
        pg.popStyle();
        return;
      }
      // render normal
      else {
        pg.strokeWeight(PLAYER_SIZE);
        pg.stroke(c);
        pg.fill(c);
        //TODO: Not needed anymore??
        if (prevPos.x != NOTSET && prevPos.y != NOTSET) {
          pg.line(prevPos.x, prevPos.y, pos.x, pos.y);
        }
      }

      pg.popStyle();
    }
  }

  void reset() {
    this.pos = initPos.copy();
    this.prevPos = initPos.copy(); 
    speed = 0;
    alive = false;
    active = false;
    //not necessary?? because this is set by the player on start but just in case
    direction = initDirection;
  }

  void changeDirection(Direction d) { 
    //prevent Hare Kare
    if ((this.direction == Direction.UP && d == Direction.DOWN) ||
      (this.direction == Direction.DOWN && d == Direction.UP) ||
      (this.direction == Direction.RIGHT && d == Direction.LEFT) ||
      (this.direction == Direction.LEFT && d == Direction.RIGHT)) {
      return;
    }
    this.direction = d;
  }

  void jump() {
    jumpFlag = true;
  }

  String toString() {
    return "[player:"+name+"] " + "("+pos.x+","+pos.y+")" + "::" + direction;
  }
}