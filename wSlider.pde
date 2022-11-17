interface scaling {
  float getScale(float w, float mx, float mn);
}
class wSlider {
  //instance variables
  /*Set in constuctors/finSetup:
   * slX, slY, slMin, slH, dotX,dotY, slVal, scalingVal
   * optional: slW, slH
   *Should be updatable:
   * (everything techincally but these are the important ones)
   * slW, slH, dotW, dotH, dotStroke, lineColor, dotColor, dotHover, dotClicked
   *Text position should be either on circle, or not visible. refers to textState boolean
   *
   */
  private int slX, slY; //Set upon creation. Will always have value
  //sliderX, sliderY
  private int slMin, slMax; //Set upon creation  Will always have value
  //slider minimum Ra
  private int slW=200, slH=6; 


  private int dotX, dotY; //set upon creation. From finSetup
  private int dotW = 25, dotH = 25;
  private int dotStroke=2;

  private int slVal=0;

  private color lineColor=color(255, 255, 0), dotColor=color(128, 255, 0), dotHover=color(255), dotClicked=color(128);

  private boolean textState = true; //false = no text, true = on dot
  private color textColor=color(0);
  //textFont (valueFont);
  private PFont valueFont=createFont ("Arial", 12);
  private int dotFontSize=12;
  //make this adjust based on dot size, if it remains permanant
  
  //maybe important
  private int textVertOffset=4;

  private float scalingVal;

  private boolean isVisible=false;
  private boolean isLocked=false;
  private int canMoveSlider = 0; //0 = No. 1 = hovering. 2 = pressed & hovering
  private boolean currentlyMoving=false;

  scaling s = (a, b, c) -> ((b-c)/a);

  //private float slStrokeWeight=6;


  /**
   * constructor for a slider, basic
   * @param sliderX x position of slider
   * @param sliderY y position of slider
   * @param sliderMin minimum value of slider
   * @param sliderMax maximum value of slider
   */
  wSlider (int sliderX, int sliderY, int sliderMin, int sliderMax) {
    this.slX = sliderX;
    this.slY = sliderY;
    this.slMin = sliderMin;
    this.slMax = sliderMax;
    finSetup();
  }
  
  /**
   * constructor for a slider with a set width
   * @param sliderX x position of slider
   * @param sliderY y position of slider
   * @param sliderMin minimum value of slider
   * @param sliderMax maximum value of slider
   * @param sliderW width of slider
   */
  wSlider (int sliderX, int sliderY, int sliderMin, int sliderMax, int sliderW) {
    this.slX = sliderX;
    this.slY = sliderY;
    this.slMin = sliderMin;
    this.slMax = sliderMax;
    this.slW = sliderW;
    finSetup();
  }
  
  
  /**
   * full constructor
   * @param sliderX x position of slider
   * @param sliderY y position of slider
   * @param sliderMin minimum value of slider
   * @param sliderMax maximum value of slider
   * @param sliderW width of slider
   * @param sliderH height of slider
   */
  wSlider (int sliderX, int sliderY, int sliderMin, int sliderMax, int sliderW, int sliderH) {
    this.slX = sliderX;
    this.slY = sliderY;
    this.slMin = sliderMin;
    this.slMax = sliderMax;
    this.slW = sliderW;
    this.slH = sliderH;
    finSetup();
  }
  /** 
   * final setup step. Method called by all constructors
   */
  void finSetup() {
    //never want it lower than min
    this.slVal=slMin;
    //scaling scalingVal = () -> {(slW/(slMax-slMin));};
    //lamba cause I wanted to
    //soo unnessary but silly
    scalingVal = s.getScale(slW, slMax, slMin);
    dotX=slX;
    dotY=slY;
  }



//https://processing.github.io/processing-javadocs/core/processing/core/PApplet.html#g
//https://processing.github.io/processing-javadocs/core/processing/core/PGraphics.html
//https://processing.github.io/processing-javadocs/core/constant-values.html, i.e. CORNER=0; CORNERS=1; RADIUS=2; CENTER=3; etc.
//  PGraphics setVals = getGraphics();

  //just in-case theres an difference between strokeWeight(0) and noStroke(). to fix as neede
  void resetStrokeWeight() {
    if (dotStroke!=0) {
      strokeWeight(dotStroke);
    } else {
      noStroke();
    }
  }

  /**
   * updates canMoveSlider boolean, based on current mousePosition and mousePressed
   */
  private void inSliderRange() {
    if (currentlyMoving) {
      if (mouseButton!=LEFT) {
        currentlyMoving=false;
      }
    }
    if ((mouseX > dotX - dotW/2) && (mouseX < dotX + dotW/2) && (mouseY > dotY - dotH/2) && (mouseY < dotY + dotH/2)) {
      if ((mouseButton==LEFT)) {
        currentlyMoving=true;
        canMoveSlider = 2;
      } else {
        canMoveSlider=1;
      }
      return;
    }
    canMoveSlider = 0;
    return;
  }


  //update the slVal int based on the dots X and the slider width
  //use float scalingVal
  private void updateVal() {
    slVal=int((dotX-slX)*scalingVal)+slMin;
  }
  
  //sets the dot to a specific position, 
  private void setStartingValue(int startValue){
    if(startValue>slMax || startValue<slMin) return;
    dotX = int((startValue-slMin)/scalingVal)+slX;
    slVal=startValue;
  }

  /**
   * the core of the class. updates the slider, and draws it
   * running this is required for the slider to work
   */
  void update() {
    if(isVisible==false) return;
    inSliderRange();
    updateVal();
    display();
    dragging();
  }
  
  /**
   * draws the slider
   * should be called by update()
   * but can be called by itself if needed for some reason
   */
  void display() {
    if (isVisible==false) return;
    //int[] storage = grabGraphics();
    //replaced with push/pop, which achieve same effect
    pushStyle();

    //slider bar
    fill(lineColor);
    //if doing vertical sliders, this will all have to change
    strokeWeight(slH);
    line(slX, slY, slX+slW, slY);
    resetStrokeWeight();
    //slider bar END

    //dot

    if (canMoveSlider == 2 || currentlyMoving == true) {
      fill(dotClicked);
    } else if (canMoveSlider == 1) {
      fill(dotHover);
    } else {
      fill(dotColor);
    }
    ellipse(dotX, dotY, dotW, dotH);
    //dot END

    //text, if enabled
    if (textState) {
      fill(textColor);
      textAlign(CENTER);
      textFont(valueFont);
      //adjust the text to be in the center!!
      text(str(slVal), dotX, dotY+textVertOffset);
    }

    //restoreGraphics(storage);
    //replaced with push/pop, which achieve same effect
    popStyle();
  }

  /**
   * allows the slider to be dragged
   * should be called by update()
   * but can be called by itself if needed for some reason
   */
  void dragging() {
    if (isLocked==true) return;
    //LEFT=37,RIGHT=39, CENTER=3 (like rectMode!!)
    if (canMoveSlider==2 || currentlyMoving == true) {
      dotX=mouseX;
      dotX=constrain(dotX, slX, slX+slW);
    }
  }


  //getters
  
  
    
  //THE MOST IMPORTANT OF THE GETTERS. GETS THE VALUE OF THE SLIDER!
  int getVal(){return slVal;}
  
  /**
   * returns current visibility of slider
   * @return boolean
   */
  boolean visibility() {return isVisible;}


  /**
   * gets the X position of slider
   * @return int
   */
  int getSlX() {return slX;}

  /**
   * gets the Y position of the slider
   * @return int
   */
  int getSlY() {return slY;}

  /**
   * returns the minimum value of the slider
   * @return int
   */
  int getSlMin() {return slMin;}

  /**
   * returns the maximum value of the slider
   * @return int
   */
  int getSlMax() {return slMax;}

  /**
   * gets the width of the slider
   * @return int
   */
  int getSlW() {return slW;}
  /**
   * gets the height of the slider
   * @return int
   */
  int getSlH(){return slH;}
  
  int getDotX(){return dotX;}
  int getDotY(){return dotY;}
  int getDotW(){return dotW;}
  int getDotH(){return dotH;}
  int getDotStroke(){return dotStroke;}
  color getLineColor(){return lineColor;}
  color getDotColor(){return dotColor;}
  color getDotHover(){return dotHover;}
  color getDotClicked(){return dotClicked;}
  boolean getTextState(){return textState;}
  color getTextColor(){return textColor;}
  PFont getValueFont(){return valueFont;}
  int getDotFontSize(){return dotFontSize;}
  
  
  int getTextVertOffset(){return textVertOffset;}
  boolean lockedState(){return isLocked;}
  
  
  //setters
  /**
   * sets the visibility of slider
   * @param boolean
   */
  void setVisibility(boolean status) {isVisible=status;}

  /**
   * sets X position of slider
   * @param int
   */
  void setSlX(int val) {slX=val;}

  /**
   * sets the Y position of the slider
   * @param int
   */
  void setSlY(int val) {slY=val;}

  /**
   * sets the minimum value of the slider
   * @param int
   */
  void setSlMin(int val) {slMin=val;}

  /**
   * sets the maximum value of the slider
   * @param int
   */
  void setSlMax(int val) {slMax=val;}

  /**
   * sets the width of the slider
   * @param int
   */
  void setSlW(int val) {slW=val;}
  
  /**
   * gets the height of the slider
   * @return int
   */
  void setSlH(int val){slH=val;}
  void setDotW(int val){dotW=val;}
  void setDotH(int val){dotH=val;}
  void setDotStroke(int val){dotStroke=val;}
  void setLineColor(color val){lineColor=val;}
  void setDotColor(color val){dotColor=val;}
  void setDotHover(color val){dotHover=val;}
  void setDotClicked(color val){dotClicked=val;}
  
  void setTextState(boolean val){textState=val;}
  void setTextColor(color val){textColor=val;}
  void setValueFont(PFont val){valueFont=val;}
  void setDotFontSize(int val){dotFontSize=val;}
  
  
  void setLockedState(boolean val){isLocked=val;}
  void setTextVertOffset(int val){textVertOffset=val;}
  
}
