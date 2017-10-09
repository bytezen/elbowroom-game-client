class Player {
  PVector initPos, pos, prevPos;
  private Direction direction = Direction.NONE;
  private Direction prevDirection = Direction.NONE;
  Direction initDirection = Direction.NONE;
  float initSpeed = 1;
  float speed = 1;
  color c;
  String name;
  boolean alive = false;
  boolean active = false;
  boolean jumpFlag = false;


  int jumpDistance = 40;
  //TODO: Not needed ??
  final int NOTSET = -100;

  int lBound = 0, rBound = 0, tBound = 0, bBound = 0;

  Player(String name, float x, float y, color c) {
    this.name = name;
    this.initPos = new PVector(x, y);
    this.pos = initPos.copy();
    this.prevPos = initPos.copy(); 
    //trying a little trick; we will check the alpha channel for collisions
    this.c = c;
    //speed = 1;
  }

  Player(String name, float x, float y, color c, Direction d) {
    this(name, x, y, c);
    this.initDirection = d;
    this.direction = d;
    this.prevDirection = d;
  }

  PVector getPos() { 
    return pos;
  }

  int x() {
    return int(pos.x);
  }

  int y() {
    return int(pos.y);
  }  

  int prevX() {
    return int(prevPos.x);
  }

  int prevY() {
    return int(prevPos.y);
  }  

  //TODO: implement update based on direction
  void update() {

    if (!alive) {
      return;
      //speed = 0;
      //direction = Direction.NONE;
    }

    if (!active) {
      return;
    }
    
    int dPos = max(int(PLAYER_SIZE * speed),1); 
    int sgn = 1;

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
    } 
    prevPos.x = floor(pos.x);
    prevPos.y = floor(pos.y);

    if ( this.direction == Direction.UP || this.direction == Direction.LEFT ) {
      sgn = -1;
    }

    dPos *= sgn;
    switch(this.direction) {
    case UP:
    case DOWN:
      pos.y += dPos;
      break;
    case LEFT:
    case RIGHT:
      pos.x += dPos;
      break;
    case NONE:
      break;
    }
    //}

    pos.x = (float)Math.floor(pos.x);
    pos.y = (float)Math.floor(pos.y);
  }

  void resetFlags() {
    jumpFlag = false;
    prevDirection = direction;
  }

 
  void die() {
    //println("[die] " + this);
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
          //pg.line(prevPos.x, prevPos.y, pos.x, pos.y);
          pg.line(prevX(), prevY(), x(), y());
        }
      }

      pg.popStyle();
    }
  }

  void reset() {
    this.pos = initPos.copy();
    this.prevPos = initPos.copy(); 
    speed = initSpeed;
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
    this.prevDirection = this.direction;
    this.direction = d;
  }

  boolean turned() {
    return prevDirection != direction;
  }

  void jump() {
    jumpFlag = true;
  }

  boolean isJumping() { 
    return jumpFlag;
  }

  String toString() {
    return "[player:"+name+"] " + "("+pos.x+","+pos.y+")" + "::" + direction;
  }
}