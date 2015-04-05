float LOW = 0;
float HIGH = 255;

int[] values = {0,30,60,90,120,150,180,210,255};
color[] colors = {color(0, 0, 255), color(0, 255, 0), color(255, 0, 0)};  // [BLUE, GREEN, RED]

color convert_to_rgb(float minval, float maxval, float val, color[] colors, int colorLength){
    int max_index = colorLength - 1;
    float v = (val-minval) / (maxval-minval) * max_index;
    color c1 = colors[int(v)];
    color c2 = colors[min(int(v)+1, max_index)];
    float f = v - int(v);
    return color(int(red(c1) + f*(red(c2)-red(c1))), 
                 int(green(c1) + f*(green(c2)-green(c1))), 
                 int(blue(c1) + f*(blue(c2)-blue(c1))));
}

void setup() {
  size(210,210);
  noStroke();
}

    
void draw() {
  drawRectGrid(values);
  //updateValues(values);
}

void drawRectGrid(int arr[]) {
  int xOff = 15, yOff = 15;
  int nWidth = 50, nHeight = 50;
  int spacing = 15;
  noStroke();
  for(int j = 0; j < 3; ++j) {
    for(int i = 0; i < 3; ++i) {
      int val = arr[i+j*3];
      color c = convert_to_rgb(LOW,HIGH,val, colors,3);
      fill(c);
      rect(xOff + i*(nWidth+spacing),yOff+j*(nHeight+spacing),nWidth,nHeight,5);
    }
  }
}
