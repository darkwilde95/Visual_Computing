
import processing.video.*;
Movie movie,m1;
PImage img;
PGraphics main1, main2, main3;
float xpos1, xpos2, xpos3, ypos;
float f1,f2,f3,f4,f5,f6,f7,f8,f9;
float[][] matrix;
PShader convolutionShader;
boolean selector;


void setup() {
  size(760, 280, P2D);
  main1 = createGraphics(200, 200, P2D);
  main2 = createGraphics(200, 200, P2D);
  main3 = createGraphics(200, 200, P2D);
  xpos1 = 40;
  xpos2 = 280;
  xpos3 = 520;
  ypos = 40;
  selector = false;
  movie = new Movie(this, "traffic.mp4");
  movie.loop();
  img = loadImage("baboon.png");
  matrix = new float [][]{{0.11111, 0.11111, 0.11111},
                          {0.11111, 0.11111, 0.11111},
                          {0.11111, 0.11111, 0.11111}};
  convolutionShader = loadShader("convolutionfrag.glsl");
  matrixToVars();
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {    
  background(0);
  if (selector) {
    mainImage();
  } else {
    mainVideo();
  }
  image(main1, xpos1, ypos);
  image(main2, xpos2, ypos);
  image(main3, xpos3, ypos);
}

void mainVideo() {
  main1.beginDraw();
  main1.background(0);
  main1.image(movie, 0, 0, 200, 200);
  main1.loadPixels();
  main1.endDraw();
  
  setMask();
  main2.beginDraw();
  main2.shader(convolutionShader);
  main2.image(movie, 0, 0, 200, 200);
  main2.endDraw();
  
  main3.beginDraw();
  main3.background(0);
  convolution(matrix);
  main3.endDraw(); 
}

void mainImage() {
  main1.beginDraw();
  main1.background(0);
  main1.image(img, 0, 0, 200, 200);
  main1.loadPixels();
  main1.endDraw();
  
  setMask();
  main2.beginDraw();
  main2.shader(convolutionShader);
  main2.image(img, 0, 0, 200, 200);
  main2.endDraw();
  
  main3.beginDraw();
  main3.background(0);
  convolution(matrix);
  main3.endDraw();
}

void setMask(){  
  convolutionShader.set("f1",f1);
  convolutionShader.set("f2",f2);
  convolutionShader.set("f3",f3);
  convolutionShader.set("f4",f4);
  convolutionShader.set("f5",f5);
  convolutionShader.set("f6",f6);
  convolutionShader.set("f7",f7);
  convolutionShader.set("f8",f8);
  convolutionShader.set("f9",f9);
}

void matrixToVars() {
  f1 = matrix[0][0];
  f2 = matrix[0][1];
  f3 = matrix[0][2];
  f4 = matrix[1][0];
  f5 = matrix[1][1];
  f6 = matrix[1][2];
  f7 = matrix[2][0];
  f8 = matrix[2][1];
  f9 = matrix[2][2];
}

color convolution(int x, int y, float[][] matrix, int matrixsize) {
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;
  int offset = matrixsize / 2;
  for (int i = 0; i < matrixsize; i++){
    for (int j= 0; j < matrixsize; j++){
      int xloc = x+i-offset;
      int yloc = y+j-offset;
      int loc = xloc + main1.width*yloc;
      loc = constrain(loc, 0, main1.pixels.length - 1);
      rtotal += (red(main1.pixels[loc]) * matrix[i][j]);
      gtotal += (green(main1.pixels[loc]) * matrix[i][j]);
      btotal += (blue(main1.pixels[loc]) * matrix[i][j]);
    }
  }
  rtotal = constrain(rtotal, 0, 255);
  gtotal = constrain(gtotal, 0, 255);
  btotal = constrain(btotal, 0, 255);
  return color(rtotal, gtotal, btotal);
}

void convolution(float[][] mask) {
  main3.loadPixels();
  for (int x = 0; x < main1.width; x++) {
    for (int y = 0; y < main1.height; y++ ) {
      color c = convolution(x, y, mask, 3);
      int loc = x + y*main1.width;
      main3.pixels[loc] = c;
    }
  }
  main3.updatePixels();
}

void keyPressed(){
  if(key == '1'){
    // blur
    matrix = new float [][]{{0.11111, 0.11111, 0.11111},
                            {0.11111, 0.11111, 0.11111},
                            {0.11111, 0.11111, 0.11111}};
    matrixToVars();
  }if(key == '2'){
    //edge detection
    matrix = new float [][]{{-1, -1, -1},
                            {-1, 8, -1},
                            {-1, -1, -1}};
    matrixToVars();
  }if(key == '3'){
    //sharpen
    matrix = new float [][]{{0, -1, 0},
                            {-1, 5, -1},
                            {0, -1, 0}};
    matrixToVars();
  }if(key == '4'){
    //gaussian blur
    matrix = new float [][]{{0.0625, 0.125, 0.0625},
                            {0.125, 0.25, 0.125},
                            {0.0625, 0.125, 0.0625}};
    matrixToVars();
  }if(key == '5'){
    //sobel
    matrix = new float [][]{{-2, 1, 0},
                            {1, 1, 1},
                            {0, 1, 2}};
    matrixToVars();
  }if(key == ' '){
    selector = !selector;
  }
}
