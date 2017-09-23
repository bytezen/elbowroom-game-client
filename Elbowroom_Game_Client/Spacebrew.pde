import spacebrew.*;

String SB_SERVER = "127.0.0.1";
String SB_NAME = "Snakeden Game Client";
String SB_DESCRIPTION = "The main game console for Snakeden Players.";

Spacebrew sb;
String apiColor = "";

void initSpacebrewConnection() {
  sb = new Spacebrew( this );
}

void spacebrewConnect() { 
  //stuff we want to share

  // value = playerid
  sb.addPublish("reset", "string", "");
  // value = playerid
  sb.addPublish("youdied", "string", "");

  //to implement
  // value = playerid
  //sb.addPublish("youwon","string",""); 
  //value = playerid:placestring e.g player10:6/20
  //sb.addPublish("youplaced","string","");
  sb.connect(SB_SERVER, SB_NAME, SB_DESCRIPTION);
}

void initSpacebrewPlayerChannel(Player p) {
  String channelId = p.name;
  sb.addSubscribe(channelId, "string");
  println("[subscriptionInitialized] - channel = " + p.name);
  playerChannelMap.put(channelId, p);
}

void onStringMessage( String channel, String value) {
  //println("[onStringMessage]" + channel + " " + value );
  Player p = playerChannelMap.get(channel);

  //make sure we have a proper id
  if ( p == null ) {
    println("[ERROR: onStringMessage] unknown player: " + channel);
    return;
  }

  // -- value = hello messages

  if (value.equals("hello")) {
    p.active = true;
    return;
  }

  // -- value = goodbye messages

  if (value.equals("goodbye")) {
    p.active = false;
    return;
  }
  
  // -- value = jump messages
  
  if (value.equals("jump")) {
    p.jump();
    return;
  }



  // -- directions messages
  // values = {up,down,left,right,jump}
  //let's assume good data in for now
  if (value.equals("up") || value.equals("down") ||
    value.equals("left") || value.equals("right") ) {
    p.changeDirection(directionFromString(value));
  }
}