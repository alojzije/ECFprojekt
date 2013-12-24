FloatTable data;
float dataMin, dataMax;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int rowCount;
int columnCount;
int currentColumn = 0;

int yearMin, yearMax;
int[] years;

int yearInterval = 1;
float volumeInterval = 10;
float volumeIntervalMinor = 5;

float tabLeft, tabRight;
float[] tabTop, tabBottom;
float tabPad = 10;

String[] descriptionLong ={"Average stats for the Static Cloning CLONALG1 version of CLONALG", 
                          "Average stats for the Proportional Cloning CLONALG1 version of CLONALG",
                            "Average stats for the Static Cloning CLONALG2 version of CLONALG",
                        "Average stats for the Proportional Cloning CLONALG2 version of CLONALG",};
                        
String[] descriptionShort ={"Static Cloning CLONALG1", 
                          "Proportional Cloning CLONALG1",
                            "Static Cloning CLONALG2",
                            "Proportional Cloning CLONALG2"};


Integrator[] interpolators;

PFont plotFont; 


void setup() {
  size(820, 605);
 
  
  data = new FloatTable("AllAvgStats.tsv");
  rowCount = data.getRowCount();
  columnCount = data.getColumnCount();
  
  years = int(data.getRowNames());
  yearMin = years[0];
  yearMax = years[years.length - 1];
  
  dataMin = 0;
  dataMax = ceil(data.getTableMax());
 
  interpolators = new Integrator[rowCount];
  for (int row = 0; row < rowCount; row++) {
    float initialValue = data.getFloat(row, 0);
    interpolators[row] = new Integrator(initialValue);
    interpolators[row].attraction = 0.1;  // Set lower than the default
    interpolators[row].damping = 0.3; 
  }

  plotX1 = 120; 
  plotX2 = width - 190;
  labelX = 60;
  plotY1 = 80;
  plotY2 = height - 70;
  labelY = height - 30;
  
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);

  smooth();
}


void draw() {
  background(224);
  
  fill(100);
  textAlign(CENTER, CENTER);
  textSize(17);
  text(descriptionLong[int(currentColumn/3)], plotX1+ 0.5* (plotX2-plotX1) , 40 );
   textSize(10);
  textAlign(LEFT);
  text("To see a specific function's minimum fitness value, hover the cursor over the wanted dot", 5,height-5 );
  
  // Show the plot area as a white box  
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);

  drawTitleTabs();
  drawAxisLabels();
  drawHorizontalGrid();

   for (int row = 0; row < rowCount; row++) {
    interpolators[row].update();
  }

  drawYearLabels();
 // drawVolumeLabels();

  stroke(#5679C1);
  noFill();
  drawDataArea(currentColumn);
  drawDataPoints(currentColumn);
  drawDataHighlight(currentColumn);
}


void drawTitleTabs() {
  rectMode(CORNERS);
  noStroke();
  textSize(10);
  textAlign(LEFT);

  // On first use of this method, allocate space for an array
  // to store the values for the left and right edges of the tabs
  if (tabTop == null){
    tabTop = new float[columnCount];
    tabBottom = new float[columnCount];
  }
  
  tabLeft = plotX2 + 20; 
  tabTop[0] = plotY1;
  tabBottom[0] = plotY1 + textAscent() + 15;
  String title = data.getColumnName(0);
  float titleWidth = textWidth(title);
  tabRight = tabLeft + tabPad + titleWidth + tabPad;
  
  for (int col = 0; col < columnCount; col++) {
    if (col == 0){
      fill(100);
      text(descriptionShort[col], tabLeft , tabTop[col] - 5);
    } else if( col % 3 == 0 && col != 0){
      tabTop[col] = tabBottom[col-1] + 35;
      tabBottom [col] =  tabTop[col] + textAscent() + 15; 
      fill(100);
      text(descriptionShort[int(col/3)], tabLeft , tabTop[col] - 5);
    } else if ( col != 0){ 
      tabTop[col] = tabBottom[col-1] + 2;
      tabBottom [col] =  tabTop[col] + textAscent() + 15;
    }  
  
    title = data.getColumnName(col);
    titleWidth = textWidth(title);
//    tabRight = tabLeft + tabPad + titleWidth + tabPad;
    
    // If the current tab, set its background white, otherwise use pale gray
    fill(col == currentColumn ? 255 : 244);
    rect(tabLeft, tabTop[col], tabRight, tabBottom[col]);
    
    // If the current tab, use black for the text, otherwise use dark gray
    fill(col == currentColumn ? 0 : 64);
    text(title, tabLeft + tabPad, tabTop[col] + 15);
 
      
  }
  }


void mousePressed() {
   if (mouseX > tabLeft && mouseX < tabRight) {
    for (int col = 0; col < columnCount; col++) {
      if (mouseY > tabTop[col] && mouseY < tabBottom[col]) {
     
        setCurrent(col);
      }
    }
  }
}
//void keyPressed() {
//  if (key == 'w' || key == 'W') {
//     dataMin += 10;
//     dataMax += 10;
//    }
//    if (key == 's' || key == 'S') {
//     dataMin -= 10;
//     dataMax -= 10;
//    }
//}

void setCurrent(int col) {
  currentColumn = col;
  
  for (int row = 0; row < rowCount; row++) {
    interpolators[row].target(data.getFloat(row, col));
  }
}


void drawAxisLabels() {
  fill(0);
  textSize(13);
  textLeading(15);
  
  textAlign(CENTER, CENTER);
  text("Average\nfitness minimum\nachieved", labelX, (plotY1+plotY2)/2 -10);
  textAlign(CENTER);
  text("Functions", (plotX1+plotX2)/2, labelY);
}


void drawYearLabels() {
  fill(0);
  textSize(10);
  textAlign(CENTER);
  
  // Use thin, gray lines to draw the grid
  stroke(224);
  strokeWeight(1);
  
  for (int row = 0; row < rowCount; row++) {
    if (years[row] % yearInterval == 0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + textAscent() + 10);
      line(x, plotY1, x, plotY2);
    }
  }
}


void drawHorizontalGrid() {
  fill(0);
  textSize(10);
  textAlign(RIGHT);
   float textOffset = textAscent()/2; 
  // Use thin, gray lines to draw the grid
  stroke(224);
  strokeWeight(1);
  
  float y;
  y = map(0, dataMin, 100, plotY2, plotY2- 0.4*( plotY2-plotY1));
  line(plotX1, y, plotX2, y);
  text(0, plotX1 - 10, y + textOffset);
  
  y = map(50, dataMin, 100, plotY2, plotY2- 0.4*( plotY2-plotY1));
  line(plotX1, y, plotX2, y);
  text(50, plotX1 - 10, y + textOffset);
  
  y = map(100, 0, 1000, plotY2- 0.4*( plotY2-plotY1), plotY2- 0.5*( plotY2-plotY1) );
  line(plotX1, y, plotX2, y);
  text(100, plotX1 - 10, y + textOffset);
  
  y = map(1000, 0, 5000, plotY2- 0.6*( plotY2-plotY1), plotY2- 0.7*( plotY2-plotY1) );
  line(plotX1, y, plotX2, y);
  text(nfc(1000), plotX1 - 10, y + textOffset); 
   
  y = map(5000, 0, 100000,  plotY2- 0.7*( plotY2-plotY1), plotY2- 0.8*( plotY2-plotY1));
  line(plotX1, y, plotX2, y);
  text(nfc(5000), plotX1 - 10, y + textOffset);
  
  y = map(100000,0, 1000000,  plotY2- 0.8*( plotY2-plotY1), plotY2- 0.9*( plotY2-plotY1));
  line(plotX1, y, plotX2, y);
  text(nfc(100000), plotX1 - 10, y + textOffset);
    
  y = map(1000000,0, dataMax,plotY2- 0.9*( plotY2-plotY1), plotY1);
  line(plotX1, y, plotX2, y);
  text(nfc(1000000), plotX1 - 10, y + textOffset);
  
}


void drawDataArea(int col) {

  beginShape();
  float lastVal = -10;
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = interpolators[row].value;
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = calculateY(value);
      
      vertex(x, y);
      
//      line(plotX1 - 4, y, plotX1, y);     // Draw major tick
//      if (abs(lastVal - floor(value)) > 10){
//        lastVal = floor(value);
//        textAlign(RIGHT);
//    
//        text(floor(value), plotX1 - 10, y + textOffset);
//      }
     
    }
  }

  endShape();
}
void drawDataHighlight(int col) {
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = calculateY(value);
     
      if (dist(mouseX, mouseY, x, y) < 3) {
        strokeWeight(10);
        point(x, y);
        fill(0);
        textSize(10);
        textAlign(CENTER);
        text(nf(value, 0, 3) + " (" + years[row] + ")", x, y-8);
        textAlign(LEFT);
      }
    }
  }
}

void drawDataPoints(int col) {
  strokeWeight(5);
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = interpolators[row].value;
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = calculateY(value);
     
      point(x, y);
    }
  }
}

float calculateY(float value){
  float y;
      if (value < 100)
        y = map(value, dataMin, 100, plotY2, plotY2- 0.4*( plotY2-plotY1));
      else if ( value < 1000)
        y = map(value, 0, 1000, plotY2- 0.4*( plotY2-plotY1), plotY2- 0.5*( plotY2-plotY1) );
      else if ( value < 5000)
        y = map(value, 0, 5000, plotY2- 0.6*( plotY2-plotY1), plotY2- 0.7*( plotY2-plotY1) );
      else if ( value < 100000)
        y = map(value, 0, 100000,  plotY2- 0.7*( plotY2-plotY1), plotY2- 0.8*( plotY2-plotY1));
      else if ( value < 1000000)
        y = map(value,0, 1000000,  plotY2- 0.8*( plotY2-plotY1), plotY2- 0.9*( plotY2-plotY1));
      else
        y = map(value,0, dataMax,plotY2- 0.9*( plotY2-plotY1), plotY1+15);
      
 
      return y;
    }
