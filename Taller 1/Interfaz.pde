PGraphics space, original, analisis;
PImage img1, img2, img3, analizedImg, convImg1, convImg2, convImg3;
ClickableImage i1, i2, i3;
Button b1, b2, b3;
int option;

void setup() {
  size(1200, 600);
  background(255);
  option = 1;
  img1 = loadImage("baboon.png");
  img2 = loadImage("lena.png");
  img3 = loadImage("cat.jpg");
  space = createGraphics(925, 540);
  original = createGraphics(925, 250);
  analisis = createGraphics(925, 270);
  textSize(12);
  textAlign(CENTER);
  
  b1 = new Button(1, 50, 215, "Histogram", 50, 215+22);
  b2 = new Button(2, 50, 255, "Convolution", 50, 255+22);
  b3 = new Button(3, 50, 295, "Video", 50, 295+22);
  analizedImg = img1;
  i1 = new ClickableImage(img1, 73.75, 20, original, 225, 30);
  i2 = new ClickableImage(img2, 357.5, 20, original, 225, 30);
  i3 = new ClickableImage(img3, 641.25, 20, original, 225, 30);
}

void draw() {
  
  b1.display();
  b2.display();
  b3.display();
  
  space.beginDraw();
  space.background(255);
  space.image(original, 0, 0);
  space.image(analisis, 0, 250);
  space.endDraw();
  
  
  original.beginDraw();
  original.background(255);
  i1.display();
  i2.display();
  i3.display();
  original.endDraw();
  
  
  analisis.beginDraw();
  analisis.background(255);
  selector();
  analisis.endDraw();
  image(space, 225, 30);
}

void selector() {
  switch(option) {
    case 1:
      histogram();
      break;
      
    case 2:
      convolution();
      break;
      
    case 3:
      video();
      break;
  }
}

void histogram() {
  ArrayList<Point>[] points = new ArrayList[256];
  analisis.image(analizedImg, 20, 45, 210,210);
  analisis.stroke(0);
  analisis.line(510, 30, 510, 270);
  analisis.line(510, 269, 975, 269);
  color pixel;
  int avg = 0, histMax = 0, auxX, auxY;
  int[] hist = new int[256];
  for(int i = 20; i < 230; i++) {
    for(int j = 45; j < 255; j++) {
      pixel = analisis.get(i, j);
      avg = (int)((red(pixel) + green(pixel) + blue(pixel))/3);
      analisis.set(i+250, j, color(avg));
      hist[avg]++;
      if (points[avg] == null) {
        points[avg] = new ArrayList();
      }
      points[avg].add(new Point(i+250, j, avg));
    }
  }
  histMax = max(hist);
  for(int i = 0; i < 256; i++) {
    auxX = int(map(i, 0, 256, 0, 415)) + 510;
    auxY = int(map(hist[i], 0, histMax, 0, 240));
    analisis.line(auxX, 270, auxX, 270-auxY);
  }
  
  histInteractive(points);
}

boolean overHist() {
  if(mouseX > 735 && mouseX < 1150) {
    if(mouseY > 310 && mouseY < 550) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

void histInteractive(ArrayList<Point>[] points) {
  PImage aux;
  int auxX;
  if (overHist()) {
    auxX = int(map(mouseX, 735, 1150, 0, 255));
    if(auxX >= 0 && auxX < 256) {
      aux = createImage(210,210, RGB);
      analisis.image(aux, 270, 45);
      if(points[auxX] != null) {
        for(Point p : points[auxX]) {
          analisis.set(p.x, p.y, color(p.c));
        }
      }
    }
  }
}

color convolution(int x, int y, float[][] matrix, PImage img) {
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;
  for (int i = 0; i < 3; i++){
    for (int j= 0; j < 3; j++){
      int pixel = x + i + (y + j) * img.width;
      pixel = constrain(pixel,0,img.pixels.length-1);
      rtotal += (red(img.pixels[pixel]) * matrix[i][j]);
      gtotal += (green(img.pixels[pixel]) * matrix[i][j]);
      btotal += (blue(img.pixels[pixel]) * matrix[i][j]);
    }
  }
  // Make sure RGB is within range
  rtotal = constrain(rtotal, 0, 255);
  gtotal = constrain(gtotal, 0, 255);
  btotal = constrain(btotal, 0, 255);
  // Return the resulting color
  return color(rtotal, gtotal, btotal);
}

void convolution() {
  analizedImg.loadPixels();
  convImg1 = createImage(210, 210, RGB);
  convImg2 = createImage(210, 210, RGB);
  convImg3 = createImage(210, 210, RGB);
  float[][] sharpen = new float [][]{{0, -1, 0},
                                     {-1 , 5, -1},
                                     {0, -1, 0}};
  float[][] blur = new float [][]{{0.11111, 0.11111, 0.11111},
                                  {0.11111, 0.11111, 0.11111},
                                  {0.11111, 0.11111, 0.11111}};
  float[][] edge = new float [][]{{1, 0, -1},
                                  {0, 0, 0},
                                  {-1, 0, 1}};

  for (int x = 0; x < 210; x++) {
    for (int y = 0; y < 210; y++) {
      color blurC = convolution(x, y, blur, analizedImg);
      color sharpenC = convolution(x, y, sharpen, analizedImg);
      color edgeC = convolution(x, y, edge, analizedImg);
      int loc = x + y*210;
      convImg1.pixels[loc] = blurC;
      convImg2.pixels[loc] = sharpenC;
      convImg3.pixels[loc] = edgeC;
    }
  }
  convImg1.updatePixels();
  convImg2.updatePixels();
  convImg3.updatePixels();
  
  analisis.image(convImg1, 73.75, 30);
  analisis.image(convImg2, 357.5, 30);
  analisis.image(convImg3, 641.25, 30);  
}

void video() {

}

class Point {
  public int x, y, c;
  
  public Point(int x, int y, int c) {
    this.x = x;
    this.y = y;
    this.c = c;
  }
}

abstract class Clickable {
  private float xpos, ypos;
  private float width, height;
  public boolean clicked;
  private float xtrans, ytrans;
  
  public Clickable(float xpos, float ypos) {
    this.xpos = xpos;
    this.ypos = ypos;
  }
  
  protected abstract void hover();
  
  public abstract void onClick();
    
  public abstract void toDraw();
  
  private boolean mouseOver() {
    if(mouseX > this.xpos && mouseX < this.xpos + this.width) {
       if(mouseY > this.ypos && mouseY < this.ypos + this.height) {
         return true;
       } else {
         return false;
       }
     } else {
       return false;
     }
  }
  
  private boolean mouseOverCanvas() {
    if(mouseX - this.xtrans > this.xpos && mouseX - this.xtrans < this.xpos + this.width) {
       if(mouseY - this.ytrans > this.ypos && mouseY - this.ytrans < this.ypos + this.height) {
         return true;
       } else {
         return false;
       }
     } else {
       return false;
     }
  }
  
  public void display() {
    this.hover();
    this.toDraw();
  }
}

class Button extends Clickable {
  private String text;
  public boolean selected;
  public int id;
  public float txpos, typos;
  
  public Button(int id, float xpos, float ypos, String text, float txpos, float typos){
    super(xpos, ypos);
    super.width = 125;
    super.height = 30;
    this.id = id;
    super.clicked = false;
    this.text = text;
    this.txpos = txpos;
    this.typos = typos;
  }
  
  
  public void toDraw() {
      
  }
  
  private void noHover() {
    fill(255);
    rect(super.xpos, super.ypos, super.width, super.height);
    fill(0);
    text(this.text, super.xpos + 62.5, super.ypos + 22);
  }
  
  private void hover2() {
    fill(200);
    rect(super.xpos, super.ypos, super.width, super.height);
    fill(0);
    text(this.text, super.xpos + 50, super.ypos + 22);
  }
  
  public void hover() {
     if (super.mouseOver()) {
       if(super.clicked) {
         this.noHover();
       } else {
         this.hover2();
       }
     } else {
       this.noHover();
     }
  }
  
  public void onClick() {
    super.clicked = false;
    if (super.mouseOver()) {
      super.clicked = true;
      option = this.id;
    } else {
      super.clicked = false;
    }
  }
  
}

class ClickableImage extends Clickable {

  private PGraphics canvas;
  private PImage img;
  
  public ClickableImage(PImage img, float xpos, float ypos, PGraphics canvas, float xtrans, float ytrans) {
   super(xpos, ypos);
   super.width = 210;
   super.height = 210;
   this.canvas = canvas;
   super.xtrans = xtrans;
   super.ytrans = ytrans;
   this.img = img;
  }
 
  public void toDraw() {
    this.canvas.image(this.img, super.xpos, super.ypos, super.width, super.height);
  }
  
  public void onClick() {
    super.clicked = false;
    if (super.mouseOverCanvas()) {
      super.clicked = true;
      analizedImg = this.img;
    }
 }
 
  public void hover() {
    if (super.mouseOverCanvas()) {
      if (super.clicked) {
        this.canvas.noTint();
      } else {
        this.canvas.tint(150, 100);
      }
    } else {
      this.canvas.noTint();
    }   
  }
}

void mouseClicked() {
  i1.onClick();
  i2.onClick();
  i3.onClick();
  b1.onClick();
  b2.onClick();
  b3.onClick();
}
