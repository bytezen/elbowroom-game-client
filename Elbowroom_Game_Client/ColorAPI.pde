
class ColorAPI {
  ArrayList<JSONObject> colors;

  //keep track of assigned colors
  int cursor = 0;

  ColorAPI() { 
    colors = new ArrayList();

    JSONArray json = loadJSONArray("data/colors.json");
    for (int i=0; i < json.size(); i++) {
      colors.add(json.getJSONObject(i));
    }
  }

  int getColor() {
    JSONObject obj = colors.get(cursor++ % colors.size());
    JSONArray rgb = obj.getJSONArray("rgb");
    if (rgb.size() == 3) {
      return color(rgb.getInt(0), rgb.getInt(1), rgb.getInt(2));
    } else {
      return 0;
    }
  }
}