final String server = "localhost";
final String clientName = "FOO_RHAZ";
final String clientDescription = "Lorum Ipsum";


WsClient wsc; 
Spacebrew sb;

void setup() {
  try {
    wsc = new WsClient( this, ("ws://" + server + ":9000") );
    wsc.connect();
  } 
  catch (Exception e) {
    println("error connecting to the websocket server" + e);
  }

  jsonAdmin = new JSONObject();
  jsonAdmin.setBoolean("admin", true);
  jsonAdmin.setBoolean("no_msgs", false);  
  println(jsonAdmin.toString());
  
  
  //sample config message...I hope that by sending this we will get some updates??
/*
{"config":
  {"name":"RHAZES TEST"
  ,"description":"This is a simple example of using the admin mix-in."
  ,"publish":
    {"messages":
      [{"name":"buttonPress"
        ,"type":"boolean"
        ,"default":"false"}
       ,{"name":"newClient"
         ,"type":"string"
         ,"default":""}
       ]
     }
   ,"subscribe":
     {"messages":
       [{"name":"toggleBackground"
         ,"type":"boolean"}
       ]
     },
     "options":{}
     ,"remoteAddress":"127.0.0.1"
   },
   "targetType":
     "admin"
   }
*/
  
  
  
  //sb = new Spacebrew(this);
  //sb.addSubscribe("buttonPress", "boolean");
  //sb.connect(server, clientName, clientDescription);
  noLoop();
}

JSONObject jsonAdmin;


void onOpen() {
  println("we opened a connection");
  println("now attempting to send an admin message to register to receive config");
  println("messages\n\n...");

  
  wsc.send(jsonAdmin.toString());
  
 
}


void onMessage(String message) {
 println("Huh??!] we actually got a message ???? " + message); 
}