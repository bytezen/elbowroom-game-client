

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

  boolean checkCollision(int[] pxls, int bgcolor) {
    //println("#### (prevPos to startPos) " + this.prevPos.x + "," + prevPos.y + " -- to -- " + this.pos.x + "," + this. pos.y + " ####" );

    //int pcolor, ind;
    //int startJ=0, endJ=0;
    //int startI=0, endI=0;    
    //int pxlColor;


    //if ( !(prevPos.x == pos.x && prevPos.y == pos.y )) { 

    //  if (direction == Direction.LEFT || direction == Direction.RIGHT) {
    //    startJ = endJ = prevY();

    //    if ( direction == Direction.LEFT ) {
    //      startI = int(pos.x);        
    //      endI = int(prevPos.x) - 1;
    //    }

    //    if ( direction == Direction.RIGHT ) {
    //      startI = int(prevPos.x) + 1;
    //      endI = int(pos.x);
    //    } 

    //    if ( startI > endI ) {
    //      startI = endI;
    //    }

    //    for (int i=startI, j = startJ; i <= endI && j <= endJ; i++) {          
    //      ind = getPixelIndex(i, j);
    //      pcolor = playerLayer.pixels[ind];
    //      println(i+","+j+"    " + red(pcolor) +","+ green(pcolor)+","+ blue(pcolor));
    //    }
    //  }



    //  if (direction == Direction.UP || direction == Direction.DOWN) {
    //    startI = endI = prevX();

    //    if ( direction == Direction.UP ) {
    //      startJ = int(pos.y);      
    //      endJ = int(prevPos.y) - 1;
    //    }

    //    if ( direction == Direction.DOWN ) {
    //      startJ = int(prevPos.y) + 1;
    //      endJ = int(pos.y);
    //    }

    //    if ( startJ > endJ ) {
    //      startJ = endJ;
    //    }

    //    for (int j=startJ, i = prevX(); i == prevX() && j <= endJ; j++) {
    //      ind = getPixelIndex(i, j);
    //      pcolor = playerLayer.pixels[ind];
    //      println(i+","+j+"    " + red(pcolor) +","+ green(pcolor)+","+ blue(pcolor));
    //    }
    //  }
    //}







    // -- only check if we are in a different position from last time 

    //if ( !(prevPos.x == pos.x && prevPos.y == pos.y )) { 

    //  // -- LEFT --

    //  if (direction == Direction.LEFT) {
    //    //1 after the prevPosition
    //    //start = int(prevPos.x) - 1;
    //    //end = int(pos.x);
    //    end = int(prevPos.x) - 1;
    //    start = int(pos.x);

    //    //if strokeWeight is 1 and you turn then
    //    //the prevPosition moved over a position (subtracting 1)
    //    //will be less than or equal to the destination position
    //    //so, clamp the start to not be less then the end
    //    //if ( start < end ) {        
    //    if ( start > end ) {
    //      start = end;
    //    }

    //    //if ( start > end ) {
    //    //for (int i=start, j = int(prevPos.y); i >= end; i--) {
    //    for (int i=start, j = int(prevPos.y); i <= end && j == prevY(); i++) {          
    //      ind = getPixelIndex(i, j);
    //      //pxlColor = pxls[ind];
    //      //if ( _collided(pxls[ind], bgcolor) ) {

    //      //  ( red(pxlColor) != RED ) && 
    //      //    ( green(pxlColor) != GREEN) &&
    //      //    ( blue(pxlColor) != BLUE ));             
    //      //  return true;
    //      //}
    //      pcolor = playerLayer.pixels[ind];
    //      println(i+","+j+"    " + red(pcolor) +","+ green(pcolor)+","+ blue(pcolor));
    //    }
    //    //}
    //  }


    //  // -- RIGHT --

    //  if (direction == Direction.RIGHT) {
    //    start = int(prevPos.x) + 1;
    //    end = int(pos.x);

    //    for (int i=start, j = int(prevPos.y); i <= end && j == prevY(); i++) {
    //      ind = getPixelIndex(i, j);

    //      pcolor = playerLayer.pixels[ind];
    //      println(i+","+j+"    " + red(pcolor) +","+ green(pcolor)+","+ blue(pcolor));
    //    }
    //  }

    //  // -- DOWN --

    //  if (direction == Direction.DOWN) {
    //    start = int(prevPos.y) + 1;
    //    end = int(pos.y);

    //    //1 after the prevPosition
    //    for (int j=start, i = int(prevPos.x); i==prevX() && j <= end; j++) {
    //      ind = getPixelIndex(i, j);
    //      if (ind < 0 || ind > playerLayer.pixels.length) { 
    //        break;
    //      }
    //      pcolor = playerLayer.pixels[ind];
    //      println(i+","+j+"    " + red(pcolor) +","+ green(pcolor)+","+ blue(pcolor));
    //    }
    //  }

    //  // -- UP --


    //  if (direction == Direction.UP) {
    //    //start = int(prevPos.y) - 1;
    //    //end = int(pos.y);
    //    end = int(prevPos.y) - 1;
    //    start = int(pos.y);

    //    //if (start < end) {
    //    if (start > end) {
    //      start = end;
    //    }

    //    //for (int j=start, i = int(prevPos.x); j >= end; j--) {
    //    for (int j=start, i = int(prevPos.x); i == prevX() && j <= end; j++) {
    //      ind = getPixelIndex(i, j);
    //      if (ind < 0 || ind > playerLayer.pixels.length) { 
    //        break;
    //      }
    //      pcolor = playerLayer.pixels[ind];
    //      println(i+","+j+"    " + red(pcolor) +","+ green(pcolor)+","+ blue(pcolor));
    //    }
    //  }
    //}     

    //return ( ( red(pxlColor) != RED ) && 
    //  ( green(pxlColor) != GREEN) &&
    //  ( blue(pxlColor) != BLUE ));    
    return false;
  }


  void _collided() {
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