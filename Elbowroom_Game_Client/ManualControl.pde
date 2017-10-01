/*
 *
 * Manuak Control and Collision
 *
 *
 */

// -------------
// -------------
// Collision Logic
// -------------
// -------------

class CollisionSystem {
  private int[] pixelBuffer;
  private int _w;
  private int clearColor = color(255);

  //CollisionSystem() {
  //}

  CollisionSystem(int size, int _width) {
    pixelBuffer = new int[size];
    _w = _width;
  }

  void clearBuffer() {
    for (int i=0; i < pixelBuffer.length; i++) {
      writeToBuffer(i, clearColor);
    }
  }

  //use the internal buffer for collision 
  boolean pixelCollision( int index, int bgcolor ) {
    return pixelCollision(index, pixelBuffer, bgcolor );
  }

  boolean pixelCollision( int index, int[] pxls, int bgcolor ) {
    if (index < 0 || index >= pxls.length) { 
      return false;
    }         
    return pxls[index] != bgcolor;
  }

  int getBufferIndex( int x, int y) {
    return floor(y*_w + x);
  }
  // block out the player path in the buffer
  // this does not account for stroke rendering 
  // and so it may be off by a pixel here and there
  // this should be good enough for collision detection though
  void renderPlayer(Player p) {
    int dx = p.x() - p.prevX();
    int dy = p.y() - p.prevY();
    int x = p.prevX();
    int y = p.prevY();
    int ind;    
    int incx, incy;
    int steps = max(abs(dx),abs(dy));
    
    if (dx < 0 ) { 
      incx = -1;
    } else if (dx > 0) { 
      incx = 1;
    } else { 
      incx = 0;
    }
    
    if (dy < 0 ) { 
      incy = -1;
    } else if (dy > 0) { 
      incy = 1;
    } else { 
      incy = 0;
    }
    
    int limit = 10; //for debug
    while ( steps > 0 && limit > 0) {
      x += incx;
      y += incy; 
      ind = getBufferIndex(x, y);
      if (ind < 0 || ind >= pixelBuffer.length) {
        println("ArrayOutBounds: "+ ind);
        continue;
      }

      writeToBuffer(ind, p.c);
      //print("\t[buffer wrote]: "+ x+","+y);
      //print(" ");
      //print(incx);
      //print(" ");
      //print(incy);
      //print(" ");
      //print(dx);
      //print(" ");
      //print(dy);
      //print(" ");
      //println(steps);
      
      limit--;
      steps--;
    }
    //println();
  }

  void writeToBuffer(int ind, int val) {
    pixelBuffer[ind] = val;
  }
  
  boolean playerCollision(Player p) {
    int dx = p.x() - p.prevX();
    int dy = p.y() - p.prevY();
    int x = p.prevX();
    int y = p.prevY();
    int ind;    
    int incx, incy;
    int steps = max(abs(dx),abs(dy));
    
    if (dx < 0 ) { 
      incx = -1;
    } else if (dx > 0) { 
      incx = 1;
    } else { 
      incx = 0;
    }
    
    if (dy < 0 ) { 
      incy = -1;
    } else if (dy > 0) { 
      incy = 1;
    } else { 
      incy = 0;
    }
    
    int limit = 10; //for debug
    while ( steps > 0 && limit > 0) {
      x += incx;
      y += incy; 
      ind = getBufferIndex(x, y);
      if (ind < 0 || ind >= pixelBuffer.length) {
        println("ArrayOutBounds: "+ ind);
        continue;
      }

      if(pixelCollision(ind,clearColor)) {
        println("COLLISION");
        return true;
      }
      
      //print(" ");
      //print(incx);
      //print(" ");
      //print(incy);
      //print(" ");
      //print(dx);
      //print(" ");
      //print(dy);
      //print(" ");
      //println(steps);
      
      limit--;
      steps--;
    }
    //println();    
    
    return false;
  }
  
}





//println("#### (prevPos to startPos) " + this.prevPos.x + "," + prevPos.y + " -- to -- " + this.pos.x + "," + this. pos.y + " ####" );

//int pcolor, ind;
//int start, end;
//int pxlColor;

// -- only check if we are in a different position from last time 

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








boolean isCollided(Player p) {

  println("#### (prevPos to startPos) " + p.prevX() + "," + p.prevY() + " -- to -- " + p.x() + "," + p.y() + " ####" );


  //if (p.turned() ) {
  //  println("\n*** TURNED ***\n");
  //}

  int startI =0, endI =0, startJ =0, endJ =0;
  int ind;

  if ( !(p.prevX() == p.x() && p.prevY() == p.y() )) { 

    if (p.direction == Direction.LEFT || p.direction == Direction.RIGHT) {
      startJ = endJ = p.prevY();

      if ( p.direction == Direction.LEFT ) {
        startI = int(p.x());        
        endI = int(p.prevX()) - 1;
      }

      if ( p.direction == Direction.RIGHT ) {
        startI = int(p.prevPos.x) + 1;
        endI = int(p.x());
      } 

      if ( startI > endI ) {
        startI = endI;
      }

      for (int i=startI, j = startJ; i <= endI && j <= endJ; i++) {          
        ind = getPixelIndex(i, j);
        println(i+","+j+"    checking color...");// + red(pcolor) +","+ green(pcolor)+","+ blue(pcolor));
        if ( collider.pixelCollision(ind, playerLayer.pixels, BGCOLOR) ) {
          return true;
        }
      }
    }



    if (p.direction == Direction.UP || p.direction == Direction.DOWN) {
      startI = endI = p.prevX();

      if ( p.direction == Direction.UP ) {
        startJ = int(p.y());      
        endJ = int(p.prevY()) - 1;
      }

      if ( p.direction == Direction.DOWN ) {
        startJ = p.prevY() + 1;
        endJ = p.y();
      }

      if ( startJ > endJ ) {
        startJ = endJ;
      }

      for (int j=startJ, i = startI; i == endI && j <= endJ; j++) {
        ind = getPixelIndex(i, j);
        //pcolor = playerLayer.pixels[ind];
        println(i+","+j+"    checking color...");// + red(pcolor) +","+ green(pcolor)+","+ blue(pcolor));
        if ( collider.pixelCollision(ind, playerLayer.pixels, BGCOLOR) ) {
          return true;
        }
      }
    }
  }

  return false;






  //p.checkCollision(playerLayer.pixels, BGCOLOR);
  //if (p.alive && p.active) {
  //find out if we are jumping before updating b/c update will reset jumpFlag

  //if (!p.isJumping()) {
  //if (onColoredPixel(int(p.getPos().x), int(p.getPos().y), playerLayer, BGCOLOR)) {
  //int ind = getPixelIndex(p.x(), p.y());
  //return collider.pixelCollision(ind, playerLayer.pixels, BGCOLOR);

  //if (collider.pixelCollision(ind, playerLayer.pixels, BGCOLOR)) {
  //  return true;
  //}
  //}
  //}
  //return false;
}


//boolean check



int getPixelIndex( int x, int y) {
  return floor(y*width + x);
}

boolean onColoredPixel(int x, int y, PGraphics layer, int bgColor) {
  int pxlIndex = getPixelIndex(x, y); //floor(y*width + x);

  //if you are out of the pixel range then you are off of the layer so...
  //...DIE!!!!  
  if (pxlIndex >= layer.pixels.length || pxlIndex < 0) {

    return true;
  }

  int pxlColor = layer.pixels[pxlIndex];

  //println("[onColoredPixel BGCOLOR (r,g,b)] " + R + "," + G + "," + B);
  //println("[onColoredPixel (r,g,b)] " + red(pxlColor) + "," + green(pxlColor) + "," + blue(pxlColor));
  //return ( ( red(pxlColor) != RED ) && 
  //  ( green(pxlColor) != GREEN) &&
  //  ( blue(pxlColor) != BLUE ));

  return pxlColor != BGCOLOR;
}


// -------------
// -------------
// MANUAL CONTROL
// -------------
// -------------


void manualControls() {

  Player manual = getPlayer("player5");

  if (manual != null ) {
    if (keyCode == LEFT ) { 
      move(manual.name, Direction.LEFT);
    }
    if (keyCode == RIGHT ) { 
      move(manual.name, Direction.RIGHT);
    }
    if (keyCode == UP ) { 
      move(manual.name, Direction.UP);
    }
    if (keyCode == DOWN ) { 
      move(manual.name, Direction.DOWN);
    }   

    //if(keyCode == LEFT ) { move(manual.name, "left"); }
    //if(keyCode == RIGHT ) { move(manual.name, "right");  }
    //if(keyCode == UP ) { move(manual.name, "up"); }
    //if(keyCode == DOWN ) { move(manual.name, "down"); }
  }
}

Player getPlayer(String id) {
  for (Player p : players ) {
    if (p.name.equals(id)) {
      return p;
    }
  }
  return null;
}


void move(String playerid, Direction d) {
  for (Player p : players) {
    p.changeDirection(d);
  }
}


void move(String playerid, String direction) {

  onStringMessage(playerid, direction);
}