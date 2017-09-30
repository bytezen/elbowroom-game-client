/*
 *
 * Manuak Control and Collision
 *
 *
*/


void manualControls() {
 
 Player manual = getPlayer("player5");
 
 if(manual != null ) {
   if(keyCode == LEFT ) { move(manual.name, Direction.LEFT); }
   if(keyCode == RIGHT ) { move(manual.name, Direction.RIGHT);  }
   if(keyCode == UP ) { move(manual.name, Direction.UP); }
   if(keyCode == DOWN ) { move(manual.name, Direction.DOWN); }   
   
   //if(keyCode == LEFT ) { move(manual.name, "left"); }
   //if(keyCode == RIGHT ) { move(manual.name, "right");  }
   //if(keyCode == UP ) { move(manual.name, "up"); }
   //if(keyCode == DOWN ) { move(manual.name, "down"); }
 }

}

Player getPlayer(String id) {
  for (Player p : players ) {
    if(p.name.equals(id)) {
      return p;
    }
  }
  return null;
}


void move(String playerid, Direction d) {
  for(Player p : players) {
     p.direction = d; 
  }  
}


void move(String playerid, String direction) {
  
  onStringMessage(playerid, direction);
}