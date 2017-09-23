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
  
  //This will be the last channel that we check for
  Player p = playerChannelMap.get(channel);
  if(p != null ){
    p.changeDirection(directionFromString(value));
  }
}

Player getPlayerFromChannel(String channel) {
 return null; 
}

String addPlayerChannel() {
  return null;
} 