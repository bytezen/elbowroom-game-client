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
  sb.addPublish("getHexColor","string",apiColor);
  //we will give you colors
  sb.connect(SB_SERVER, SB_NAME, SB_DESCRIPTION);
}

void initSpacebrewPlayerChannel(Player p) {
  String channelId = p.name;
  sb.addSubscribe(channelId, "string");
  println("[subscriptionInitialized] - channel = " + p.name);
  playerChannelMap.put(channelId,p); 
}

void onStringMessage( String channel, String value) {
  println("[onStringMessage]" + channel + " " + value );
  Player p = playerChannelMap.get(channel);

  //make sure we have a proper id
  if( p == null ) {
    println("[ERROR: onStringMessage] unknown player: " + channel);
    return;
  }
    
  // -- value = hello messages
  
  if(value.equals("hello")) {
    p.active = true;
    return;
  }

  // -- value = goodbye messages

  if(value.equals("goodbye")) {
    p.active = false;
    return;
  }
    
  // -- directions messages
  // values = {up,down,left,right,jump}
  if(value.equals("up") || value.equals("down") ||
     value.equals("left") || value.equals("right") ) {
      p.changeDirection(directionFromString(value));   
   }
}