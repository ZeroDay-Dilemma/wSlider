wSlider sliderOne;
void setup(){
  size(500,500);
  sliderOne= new wSlider(150, 350, 0, 10); 
  sliderOne.setVisibility(true);
  sliderOne.setStartingValue(5);
}
void draw(){
  //println(key);
  background(255);
  sliderOne.update();
}
