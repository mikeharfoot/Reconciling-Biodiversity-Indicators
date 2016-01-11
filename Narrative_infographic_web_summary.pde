

int aggregation = 10;



float historic_fragmentation = 0.002;
float fragmentation_rate = 0.05;
float time_interval = fragmentation_rate/historic_fragmentation;
float pristine_year = 1700;
float max_year = 2100;
//
//
//color(251,180,174),
//color(179,0,0)
color[] cp = {
  color(254,227,145),
  color(179,205,227),
  color(204,235,197)
};

color[] cp_sp = {
  color(140,45,4),
  color(8,50,120),
  color(0,109,44)
};


//import org.gicentre.utils.stat.*;    // For chart classes.
//import org.gicentre.utils.colour.ColourTable;

Ecosystem[] ecosystems;
MyLandscape lscape;
int[][] landscape;
int[][] protection;
Point[][] ProtectedCentres;
int[][] ProtectedAreas;

int matrix;
int pristine;
float Temperature;
float InitialTemperature;

StudyDomain study;
RNG myRNG = new RNG();

float StrokeWt = 1;
 
int border;
 
BarChart ESRBarChart = new BarChart();
//ColourTable ct = new ColourTable();

XYChart LSRChart;
ArrayList<Float> LandscapeSR;
ArrayList<Float> StudySR;

XYChart LAbChart;
ArrayList<Float> LandscapeAb;
ArrayList<Float> StudyAb;

XYChart ERChart;
ArrayList<Float> LandscapeER;

boolean WriteOutputsToFile;

void setup(){
  size(900,450);
  frameRate(10);
  background(255);
  
  border = 5;
  
  //randomSeed(0);
  
  int cols = floor(((width-2*border)/2)/aggregation);
  int rows = floor((height-2*border)/aggregation);
  
//  BiomeImages = new PImage[]{
//    loadImage("grass.jpg"),
//    loadImage("tree.jpg"),
//    loadImage("marsh.jpg")
//  };
  
  matrix = 0;
  
  int n_centres = 20;
  
  int[][][] centres = new int[cp.length][n_centres][2];
  float col_adjuster = random(0.6,1.0);
  float row_adjuster = random(1.0,1.5);
  int[][] x_limits = {
    {0,int(col_adjuster*cols/2)},
    {int(col_adjuster*cols/2),cols},
    {0,cols}
  };
  //{0,int(col_adjuster*cols/2)},
  //{int(col_adjuster*cols/2),cols}
    
  int[][] y_limits = {
    {0,int(row_adjuster*rows/2)},
    {0,int(row_adjuster*rows/2)},
    {int(row_adjuster*rows/2),rows}};
//    {int(row_adjuster*rows/2),rows},
//    {int(row_adjuster*rows/2),rows}};  
  
  for(int i = 0; i < cp.length; i++){
    //Create more than one centre so that the ecosystem types have an irregular feel
    for(int j = 0; j < n_centres; j ++){
      centres[i][j][0] = int(random(x_limits[i][0],x_limits[i][1]));
      centres[i][j][1] = int(random(y_limits[i][0],y_limits[i][1]));
    }
  }
  
  
  // Declare 2D array
  landscape = new int[cols][rows];
  protection = new int[cols][rows];
  lscape = new MyLandscape(landscape,0.2,0.2);
  ProtectedCentres = new Point[cp.length][3];
  ProtectedAreas = new int[cp.length][n_centres];
  float dist;
  int protection_centre;
  //Calculate the distance of each cell from each centre
  for(int i = 0; i < cols; i ++){
    for(int j = 0; j < rows; j ++){
      int closest_hab = 0;
      float min_dist = 999999999;
      for(int k = 0; k < cp.length; k ++){
        for(int l = 0; l <n_centres; l++){
          dist = sqrt(sq(i - centres[k][l][0]) + sq(j - centres[k][l][1]));
          if(dist < min_dist)
          {
            min_dist = dist;
            closest_hab = k;
          }
        }
      }
      landscape[i][j] = closest_hab;
    } 
      
  }
  //Set protection layer to be a specified value
  for(int i = 0; i < cols; i ++){
    for(int j = 0; j < rows; j ++){
      protection[i][j] = -1;
    }
  }
  float noise_coord = 0;
  float noise_inc = 0.005;
  float noise_scale = 50/aggregation;
  for(int k = 0; k < cp.length; k ++){
        for(int l = 0; l < 3; l++){
          protection_centre = floor(random(0,n_centres));
          ProtectedCentres[k][l] = new Point(centres[k][protection_centre][0],centres[k][protection_centre][1]);
          for(int m = max(0,centres[k][protection_centre][0]-round((noise(noise_coord+=noise_inc)*noise_scale)));m < min(protection.length,centres[k][protection_centre][0]+round((noise(noise_coord+=noise_inc)*noise_scale))) ;m++){ 
            for(int n = max(0,centres[k][protection_centre][1]-round((noise(noise_coord+=noise_inc)*noise_scale)));n < min(protection[0].length,centres[k][protection_centre][1]+round((noise(noise_coord+=noise_inc)*noise_scale))) ; n++){
              protection[m][n] = protection_centre;
              ProtectedAreas[k][protection_centre]++;
            }
          }
        }
    }
  
  Temperature = 20;
  InitialTemperature = Temperature;
  
  ecosystems = new Ecosystem[3];
  
  for(int i = 0; i < ecosystems.length; i ++){
    ecosystems[i] = new Ecosystem(i, centres[i]);
  } 
    
  study = new StudyDomain(cols,rows,0.3,0.2);
  
  
  LandscapeSR = new ArrayList<Float>();
  StudySR = new ArrayList<Float>();
  
  LandscapeAb = new ArrayList<Float>();
  StudyAb = new ArrayList<Float>();
  
  LandscapeER = new ArrayList<Float>();
  
  WriteOutputsToFile = true;
  
//    for(int i = 0; i < cp.length; i ++){
//      ct.addDiscreteColourRule(float(i),cp[i]);
//    }
//    ct.addDiscreteColourRule(float(cp.length),200);
    
}


void SetupESRBarChart(){
  
  ESRBarChart.SetExoticData(lscape.GetEcosystemExoticSpeciesRichness());
  ESRBarChart.SetEndemicData(lscape.GetEcosystemEndemicSpeciesRichness());
  //if(ESRBarChart.BackgroundSet == false) ESRBarChart.SetBackgroundData(lscape.GetEcosystemSpeciesRichness());
  
  color[] barcols = new color[4];
  color[] backgroundCols = new color[4];
  for(int i = 0; i < cp.length; i ++) barcols[i] = cp[i];
  barcols[cp.length] = color(255);
  ESRBarChart.SetBarColour(barcols);
  for(int i = 0; i < cp.length; i ++) backgroundCols[i] = color(red(cp_sp[i]),green(cp_sp[i]),blue(cp_sp[i]),250);
  backgroundCols[cp.length] = color(0,250);
  ESRBarChart.SetBackgroundColour(backgroundCols);
  
  // Scaling
  ESRBarChart.SetMinYVal(0.0);
  ESRBarChart.SetMaxYVal(12.0);
  
  ESRBarChart.SetYAxisLabel("Biome species richness");
  ESRBarChart.SetXAxisLabel("Biomes"); 
  
  
  ESRBarChart.SetCategoryLabels(new String[] {"A","B","C","M"});
  
}


void SetupLSRChart(){
  LSRChart = new XYChart();
  float[] times = new float[frameCount];
  
  for(int i = 0;i < frameCount; i ++){
    times[i] = pristine_year + i*time_interval;
  }
  
  float[] LSRArray = new float[LandscapeSR.size()];
  int i = 0;

  for (Float f : LandscapeSR) {
      LSRArray[i++] = (f != null ? f : Float.NaN); // Or whatever default you want.
  }
  
  LSRChart.SetData(times,
                    LSRArray);

  LSRArray = new float[StudySR.size()];
  i = 0;

  for (Float f : StudySR) {
      LSRArray[i++] = (f != null ? f : Float.NaN); // Or whatever default you want.
  }
  LSRChart.SetData2(times,LSRArray);
                    
   
  // Axis formatting and labels.
  
  LSRChart.SetMinYVal(0);
  LSRChart.SetMaxYVal(15);
  
  LSRChart.SetMinXVal(pristine_year);
  LSRChart.SetMaxXVal(max_year);  
     
  LSRChart.SetYAxisLabel("Regional richness");
  LSRChart.SetXAxisLabel("Time"); 
  
  // Symbol colours
  LSRChart.SetPointColour(color(180,50,50,100));
  LSRChart.SetPointColour2(color(150,150,150));
  LSRChart.SetLineColour2(color(150,150,150));
  LSRChart.SetPointSize(5);
  LSRChart.SetLineWidth(2);
}


void SetupERChart(){
  ERChart = new XYChart();
  float[] times = new float[frameCount];
  
  for(int i = 0;i < frameCount; i ++){
    times[i] = pristine_year + i*time_interval;
  }
  
  float[] ERArray = new float[LandscapeER.size()];
  int i = 0;
  for (Float f : LandscapeER) {
      ERArray[i++] = (f != null ? f : Float.NaN); // Or whatever default you want.
  }
  ERChart.SetData(times,ERArray);
  
   
  // Axis formatting and labels.
  
  ERChart.SetMinYVal(0);
  ERChart.SetMaxYVal(1);
  
  ERChart.SetMinXVal(pristine_year);
  ERChart.SetMaxXVal(max_year);  
     
  ERChart.SetYAxisLabel("Species survival index (RLI-like)");
  ERChart.SetXAxisLabel("Time"); 
   
  // Symbol colours
  ERChart.SetPointColour(color(180,50,50,100));
  ERChart.SetPointSize(5);
  ERChart.SetLineWidth(2);
}


void SetupLAbChart(){
  LAbChart = new XYChart();
  float[] times = new float[frameCount];
  for(int i = 0;i < frameCount; i ++){
    times[i] = pristine_year + i*time_interval;
  }
  
  float[] LAbArray = new float[LandscapeAb.size()];
  int i = 0;
  for (Float f : LandscapeAb) {
      LAbArray[i++] = (f != null ? f : Float.NaN); // Or whatever default you want.
  }
  
  LAbChart.SetData(times,
                    LAbArray);

  LAbArray = new float[StudyAb.size()];
  i = 0;

  for (Float f : StudyAb) {
      LAbArray[i++] = (f != null ? f : Float.NaN); // Or whatever default you want.
  }
  LAbChart.SetData2(times,LAbArray);
                    
   
  // Axis formatting and labels.
  
  LAbChart.SetMinYVal(0);
  LAbChart.SetMaxYVal(250);
  
  LAbChart.SetMinXVal(pristine_year);
  LAbChart.SetMaxXVal(max_year);  
     
  LAbChart.SetYAxisLabel("Abundance (LPI-like)");
  LAbChart.SetXAxisLabel("Time"); 
   
  // Symbol colours
  LAbChart.SetPointColour(color(180,50,50,100));
  LAbChart.SetPointColour2(color(150,150,150));
  LAbChart.SetLineColour2(color(150,150,150));
  LAbChart.SetPointSize(5);
  LAbChart.SetLineWidth(2);
}


float GetLandscapeRichness(){
  float LandscapeRichness = 0;
  boolean exotic_g_present = false;
  boolean exotic_c_present = false;
  
  for(int i = 0;i < ecosystems.length; i ++){
    if(ecosystems[i].s.size() > 0) LandscapeRichness+=1;
    if(ecosystems[i].g.size() > 0) LandscapeRichness+=1;
    if(ecosystems[i].c.size() > 0) LandscapeRichness+=1;
    if(ecosystems[i].t.size() > 0) LandscapeRichness+=1;
    if(ecosystems[i].exotic_g.size() > 0) exotic_g_present = true;
    if(ecosystems[i].exotic_c.size() > 0) exotic_c_present = true;
  }
  
  if(exotic_g_present) LandscapeRichness++;
  if(exotic_c_present) LandscapeRichness++;
  
  return LandscapeRichness;
}


float GetLandscapeAbundance(){
  float LandscapeAbundance = 0;
  
  for(int i = 0;i < ecosystems.length; i ++){
    LandscapeAbundance+=ecosystems[i].s.size();
    LandscapeAbundance+=ecosystems[i].g.size();
    LandscapeAbundance+=ecosystems[i].c.size();
    LandscapeAbundance+=ecosystems[i].t.size();
    LandscapeAbundance+=ecosystems[i].exotic_g.size();
    LandscapeAbundance+=ecosystems[i].exotic_c.size();
  }
  
  return LandscapeAbundance;
}



//void mousePressed() {
//  if (mouseButton == LEFT) {
//    loop();
//  } else if (mouseButton == RIGHT) {
//    setup();
//    noLoop();
//  }
//}

void keyPressed()
{
  if(key == ENTER || key == RETURN){
    loop();
  }
  else if(key == BACKSPACE || key == DELETE){
    setup();
    frameCount = 0;
    ESRBarChart.BackgroundSet = false;
  }
}


void WriteOutputs()
{
  //Create unique stamp for output files
  String uid = join(new String[]{str(year()),str(month()),str(day()),str(hour()),str(minute()),str(second())},"_");
  //Write years
  String[] years = new String[LAbChart.xData.length];
  for(int i = 0; i < years.length; i++){
    years[i] = str(LAbChart.xData[i]);
  }
  //saveStrings("years"+uid+".txt",years);
  println(years);
  
  //write abundances
  String[] data = new String[LAbChart.yData.length];
  for(int i = 0; i < data.length; i++){
    data[i] = str(LAbChart.yData[i]);
  }
  //saveStrings("LandscapeAbund"+uid+".txt",data);
  println(data);
  data = new String[LAbChart.yData2.length];
  for(int i = 0; i < data.length; i++){
    data[i] = str(LAbChart.yData2[i]);
  }
  //saveStrings("StudyAbund"+uid+".txt",data);
  println(data);
  
  //Write Species richnesses
  data = new String[LSRChart.yData.length];
  for(int i = 0; i < data.length; i++){
    data[i] = str(LSRChart.yData[i]);
  }
  //saveStrings("LandscapeSR"+uid+".txt",data);
  println(data);
  
  data = new String[LSRChart.yData2.length];
  for(int i = 0; i < data.length; i++){
    data[i] = str(LSRChart.yData2[i]);
  }
  //saveStrings("StudySR"+uid+".txt",data);
  println(data);
  
  //Write Extinction risk
  data = new String[ERChart.yData.length];
  for(int i = 0; i < data.length; i++){
    data[i] = str(ERChart.yData[i]);
  }
  //saveStrings("SurvivalIndex"+uid+".txt",data);
  println(data);
  
}


void draw(){ 
  
  background(255);
  
  if(frameCount > 1 && frameCount*time_interval + pristine_year <= max_year+time_interval){
    lscape.ConvertHabitat(landscape,fragmentation_rate);
    Temperature+=time_interval/100;
  
    for(int i = 0;i < ecosystems.length; i ++){
      ecosystems[i].FindEcosystemCells();
      ecosystems[i].UpdateSpecies();
    }
    
  }
  
  
  for(int i = 0;i < ecosystems.length; i ++){
    ecosystems[i].drawLandscape();
  }
  for(int i = 0;i < ecosystems.length; i ++){
    ecosystems[i].drawSpecies();
    ecosystems[i].CalculateExtentOfOccurences();
    ecosystems[i].RecordPopulationsSizes();
  }
  SetupESRBarChart();
  ESRBarChart.draw((width/2)+30,15,(width/4)-45,(height/2)-30);
  
  LandscapeSR.add(GetLandscapeRichness());
  LandscapeAb.add(GetLandscapeAbundance());
  study.CalculateStudyEcosystemAbundances();
  study.display();
  StudySR.add(study.StudySpeciesRichness());
  StudyAb.add(study.StudyAbundances());
  SetupLSRChart();
  SetupLAbChart();
  LSRChart.draw((3*width/4)+30,15,(width/4)-45,(height/2)-30);
  LAbChart.draw((width/2)+30,(height/2),(width/4)-45,(height/2)-30);
  if(frameCount > 1){
    LandscapeER.add(lscape.CalculateExtinctionRisk());
  } else {
    LandscapeER.add(1.0);
  }
  
  SetupERChart();
  ERChart.draw((3*width/4)+30,(height/2),(width/4)-45,(height/2)-30);
  if(frameCount*time_interval + pristine_year >= max_year+time_interval & WriteOutputsToFile){
    WriteOutputsToFile = false;
    WriteOutputs();
  }
  //if(frameCount > 10) noLoop();
  noLoop();
}




class BarChart{
  color[] barColors;
  color[] backgroundColors;
  float minYVal;
  float maxYVal;
  float[] data1;
  float[] data2;
  String[] labels;
  String YLab;
  String XLab;
  float[] backgroundData;
  boolean BackgroundSet = false;
  
  
  float leftMargin = 0.08; //Proportion of width
  float AxisLeftMargin = 0.05;
  float LabLeftMargin = 0.005;
  float bottomMargin = 0.1; //Proportion on height
  float AxisBottomMargin = 0.06;
  float LabBottomMargin = 0.01;
  float plotTextSize = 0.05;//text size as proportion of height
  float labTextSize = 0.07;
  float barGaps = 0.1; //Proportion of bar widths
  
  
  BarChart(){
      
  }
 
  void SetMinYVal(float y){
    minYVal = y;
  } 
  
  void SetMaxYVal(float y){
    maxYVal = y;
  }
  
  void SetEndemicData(float[] d){
    
    data1 = d;
    labels = new String[data1.length];
    barColors = new color[data1.length];
    for(int i = 0; i < d.length;i++){
      labels[i] = str(i);
      barColors[i] = 150;
    }
    
  }
  
  void SetExoticData(float[] d){
    data2 = d;
  }
  
    
  void SetCategoryLabels(String[] l){
    
    labels = l;
    
  }
  
  void SetBarColour(color[] c){
    barColors = c;
  }
  
  void SetBackgroundColour(color[] c){
    backgroundColors = c;
  }
  
  void SetYAxisLabel(String s){
    YLab = s;
  }
  
  void SetXAxisLabel(String s){
    XLab = s;
  }
  
  void draw(float x, float top, float w, float h){
    
    if(BackgroundSet == false){
      backgroundData = new float[data1.length];
      for(int i = 0; i < data1.length;i++)
      {
        backgroundData[i] = data1[i] + data2[i];
      }
      BackgroundSet = true;
    }
    
    //Work out the bar widths with
    //  equal widths 
    //  some assumed gap between the bars
    int n_bars = data1.length;
    float barWidth = w*(1-leftMargin)/(n_bars + (barGaps*n_bars));
    float barGapWidth = barGaps*barWidth;
    
    float y0 = (top)+(h*(1-bottomMargin));
    float x0 = x+barGapWidth+w*leftMargin;
    
    float[] barHeights1 = new float[n_bars];
    float[] barHeights2 = new float[n_bars];
    float[] backgroundHeights = new float[n_bars];
    float[] barLefts = new float[n_bars];
    for(int i = 0; i < n_bars; i++){
      if(data1[i] <= minYVal){
        barHeights1[i] = 0;
      }
      else if (data1[i] >= maxYVal){
        barHeights1[i] = h*(1-bottomMargin);
      } else{
        barHeights1[i] = map(data1[i],minYVal, maxYVal,0,h*(1-bottomMargin));
      }
      
      if(data2[i] <= minYVal){
        barHeights2[i] = 0;
      }
      else if (data2[i] >= maxYVal){
        barHeights2[i] = h*(1-bottomMargin);
      } else{
        barHeights2[i] = map(data2[i],minYVal, maxYVal,0,h*(1-bottomMargin));
      }
      
      
      //Also calculate the vertical position for background marks
      if(backgroundData[i] <= minYVal){
        backgroundHeights[i] = 0;
      }
      else if (backgroundData[i] >= maxYVal){
        backgroundHeights[i] = h*(1-bottomMargin);
      } else{
        backgroundHeights[i] = map(backgroundData[i],minYVal, maxYVal,0,h*(1-bottomMargin));
      }
      
      barLefts[i] = x0+(i*(barWidth + barGaps*barWidth));
    }
    
    
    
    
    rectMode(CORNER);
    
    //Draw background boxes
//    for(int i = 0; i < n_bars; i++){
//      fill(backgroundColors[i]);
//      stroke(backgroundColors[i]);
//      rect(barLefts[i],y0,barWidth,-backgroundHeights[i]);
//    }
    
    
    //Draw boxes
    for(int i = 0; i < n_bars; i++){
      
      stroke(150);
      fill(150);
      rect(barLefts[i],y0,barWidth,-barHeights2[i]);
      fill(barColors[i]);
      rect(barLefts[i],y0-barHeights2[i],barWidth,-barHeights1[i]);
    }
    
    for(int i = 0; i < n_bars; i++){
      stroke(backgroundColors[i]);
      line(barLefts[i],y0-backgroundHeights[i],barLefts[i]+barWidth,y0-backgroundHeights[i]);
    }
    
    
    //Draw y axis line
    line(x+w*leftMargin,top,x+w*leftMargin,y0);
    
    //Add y axis labels
    int n_labs = 5;
    float[] y_labs = new float[n_labs];
    float[] y_height = new float[n_labs];
    
    textAlign(RIGHT, CENTER);
    textSize(plotTextSize*h);
    fill(100);
    for(int i = 0; i < n_labs;i++){
      y_labs[i] = minYVal + (i*(maxYVal-minYVal)/(n_labs-1));
      y_height[i] =  map(y_labs[i],minYVal, maxYVal,0,h*(1-bottomMargin));
      text(str(y_labs[i]),x+w*AxisLeftMargin,y0-y_height[i]);
    }
    
    //Add x axis labels
    textAlign(CENTER, CENTER);
    for(int i = 0; i < labels.length; i++){
      text(labels[i],barLefts[i]+barWidth/2,top+h*(1-AxisBottomMargin));
    }
    
    //X label
    fill(100);
    textSize(labTextSize*h);
    textAlign(CENTER, CENTER);
    text(XLab,x0+((n_bars/2)*(barWidth + barGaps*barWidth)),
         top+h*(1-LabBottomMargin));
    
    //Y label
    pushMatrix();    
    fill(100);
    textSize(labTextSize*h);
    textAlign(CENTER, BOTTOM);
    translate(x+w*LabLeftMargin,y0-map(((maxYVal-minYVal)/2),minYVal, maxYVal,0,h*(1-bottomMargin)));
    rotate(-PI/2);
    text(YLab,0,-0.07*w);
    popMatrix();
    

    
    
  }
  

  
}






class Cell
{
  int x;
  int y;
  boolean perim = false;
  boolean occupied = false;
  
  Cell(int c, int r)
  {
    x = c;
    y = r;
    
    //this.CheckPerimeter(e);
    
  }
  
  void SetOccupied(){
    occupied = true;
  }
  
   
}




class ClimateSensitive{
  int Habitat_aff;
  int CurrentHabitat;
  float T_threshold;
  int col;
  int row;
  color cp;
  int size;
  boolean Extinct;
  Shape t;
  
  ClimateSensitive(int affinity, int c, int r, color csp, int sz,float t_th){
    Habitat_aff = affinity;
    col = c;
    row = r;
    cp = csp;
    size = sz;
    T_threshold = t_th;
    CurrentHabitat = landscape[col][row];

    //t = new Triangle(csp,color(0,0,0),2,0.2);
    t = new Shape(csp,color(0,0,0));
    t.MyTriangle(border+(aggregation/2)+c*aggregation,border+(aggregation/2)+r*aggregation,sz);
  }
  
  
  void UpdateHabitat(int newHabitat){
    CurrentHabitat = newHabitat;
  }
  
  boolean CheckExtinction(float T){
    if(T > T_threshold & random(0,1) > 0.5){
      Extinct = true;
    }
    else{
      Extinct = false;
    }
    
    return Extinct;
  }
 
  void display()
 {
   //fill(cp);
   //t.display(col,row);
   t.draw();
 } 
  
}



/**
 * Find the convex hull for an arbitrary collection of points
 */
class ConvexHull
{
  /**
   * First algorithm: Jarvis' March - this is a simple but slow algorithm
   * that forms edges, and then checks that every point left is 
   * on the same side. If a point is found on the wronng side, the
   * edge is broken and a new edge to that point is formed instead.
   */
  Point[] jarvisMarch(ArrayList pointset, int minx, int miny)
  {
    int pslen = pointset.size();
    if(pslen<2) return new Point[0];

    ArrayList path = new ArrayList();
    // we need a virtual "first" point to
    // act as initial reference
    Point virtual = new Point(minx, miny);
    boolean vused = true;
    path.add(virtual);
    Point first = (Point)pointset.get(0);
    path.add(first);

    // finding the first hull point is simpler
    // than finding subsequent hull points
//    for(int s=1; s<pslen; s++) {
//      Point p = (Point)pointset.get(s);
//      if(p.equals(first)) continue;
//      if(aboveEdge(virtual, first, p)) {
//        path.set(1, p);
//        first=p; }}

    // finding hull points is based on the convex property:
    // the bigger the angle to the next point, the better.
    for(int point = 0; point<pslen; point++) {
      if(vused && path.size()>2) { path.remove(0); vused=false; }
      Point ref = vused ? virtual : (Point)path.get(path.size()-2);
      Point last = (Point)path.get(path.size()-1);
      Point provisional = (Point)pointset.get(point);
      if(path.contains(provisional)) { continue; }

      // add the provisional point
      int setpos = path.size();
      path.add(provisional);
      double angle_to_provisional = angleTo(ref, last, provisional);

      // is there a better point?
      for(int s=0; s<pslen; s++) {
        Point test = (Point)pointset.get(s);
        // this point may not already be in the path, unless it's the first point (for closing)
        if(!test.equals(first) && path.contains(test)) { continue; }
        // if the angle to this point is bigger than the angle
        // to the provisional point, this point is better
        double angle_to_test = angleTo(ref, last, test);
        if(angle_to_test > angle_to_provisional) {
          path.set(setpos, test);
          provisional = test;
          angle_to_provisional = angle_to_test;
          point=0; }}

      // if the best candidate was the first point,
      // we found our convex hull
      if(provisional.equals(first)) {
        path.remove(path.size()-1);
        break; }
    }

    // the result is a convex polygon that encloses all pointset in the set.
    Point[] hull = new Point[path.size()];
    for(int p=0; p<hull.length; p++) {
      hull[p] = (Point)path.get(p); }
    return hull;
  }
  
  /**
   * test whether the point 'test' is above the edge {start,end},
   * when we apply T/R so that start is 0/0 and end is x/0
   * we can take a lot of shortcuts in this method, because
   * the only important bit is whether test.y is positive or 
   * negative after translation/rotation.
   */
  boolean aboveEdge(Point s, Point e, Point t)
  {
    double tx = t.x - s.x;
    double ty = t.y - s.y;
    double angle = -getDirection(e.x-s.x, e.y-s.y);
    double t_h = tx*Math.sin(angle) + ty*Math.cos(angle);
    return (t_h > 0);
  }
  
  double getDirection(double a, double b){
    return Math.atan(b/a);
  }
  
  /**
   * get the angle between {start,end} and {end,point}
   */
  double angleTo(Point s, Point e, Point t)
  {
    // vector end->start
    double dx1 = s.x - e.x;
    double dy1 = s.y - e.y;
    // normalise
    double sf = Math.sqrt(dx1*dx1+dy1*dy1);
    dx1 /= sf;
    dy1 /= sf;
    // vector end->test
    double dx2 = t.x - e.x;
    double dy2 = t.y - e.y;
    // normalise
    sf = Math.sqrt(dx2*dx2+dy2*dy2);
    dx2 /= sf;
    dy2 /= sf;
    // angle between the two vectors, in radians
    return Math.acos(dx1*dx2 + dy1*dy2);
  }
  
  double ConvHullArea(Point[] pts){
    
    double Area = 0;
    
    for(int i = 0; i < pts.length-2;i++){
      Area += pts[i+1].x *pts[i].y - pts[i+1].y*pts[i].x;
    }
    
    Area*=0.5;
    return Area;
  }
  
  
  
  
}




class Ecosystem{
  //int[][] landscape;
  int this_ecosystem;
  ArrayList<Specialist> s; 
  ArrayList<Generalist> g; 
  ArrayList<ClimateSensitive> c; 
  ArrayList<Tolerant> t;
  ArrayList<Generalist> exotic_g;
  ArrayList<ClimateSensitive> exotic_c;
  
  //Holds extent of occurence values for each species type in this ecosystem
  ArrayList<Double> eeo_s;
  ArrayList<Double> eeo_g;
  ArrayList<Double> eeo_c;
  ArrayList<Double> eeo_t;
  ArrayList<Double> eeo_ex_g;
  ArrayList<Double> eeo_ex_c;
  
  //Holds population time serires for each species type in this ecosystem
  ArrayList<Integer> pop_s; 
  ArrayList<Integer> pop_g;
  ArrayList<Integer> pop_c;
  ArrayList<Integer> pop_t;
  ArrayList<Integer> pop_ex_g;
  ArrayList<Integer> pop_ex_c;
  
  
  ConvexHull ConvHull = new ConvexHull();
  
//  IntList this_cells_x = new IntList();
//  IntList this_cells_y = new IntList();
  ArrayList<Cell> this_cells;  
  //IntList this_perim  = new IntList();
  int[] LastConvertedCell;
  
  float homogenisation_scale = 1;
  
  Ecosystem(int e, int[][] centres){
    int initial_abund = 20;
    
    this_ecosystem = e;
    
    s = new ArrayList<Specialist>();
    g = new ArrayList<Generalist>();
    c = new ArrayList<ClimateSensitive>();
    t = new ArrayList<Tolerant>();
    exotic_g = new ArrayList<Generalist>();
    exotic_c = new ArrayList<ClimateSensitive>();
    this_cells  = new ArrayList<Cell>();
    
    eeo_s =  new ArrayList<Double>();
    eeo_g =  new ArrayList<Double>();
    eeo_c =  new ArrayList<Double>();
    eeo_t =  new ArrayList<Double>();
    eeo_ex_g =  new ArrayList<Double>();
    eeo_ex_c =  new ArrayList<Double>();
    
    pop_s =  new ArrayList<Integer>();
    pop_g =  new ArrayList<Integer>();
    pop_c =  new ArrayList<Integer>();
    pop_t =  new ArrayList<Integer>();
    pop_ex_g =  new ArrayList<Integer>();
    pop_ex_c =  new ArrayList<Integer>();
       
    this.FindEcosystemCells();
    float InitialDensity = initial_abund/this_cells.size();
    float ClimateSensitivity = random(1.0,1.1);
    float ToleranceDistance = random(2,5);
//    this.FindEcosystemPerimeter();
//    println("Found perimeter cells", e);
      //Add set of species
    int ind;
    
    float angle;
    float dist;
    Point cellXY;

    float specialist_scaling = 20/aggregation; 
    for(int i = 0; i < initial_abund; i ++){
      ind = int(random(0,centres.length));
      angle = random(0,2*PI);
      dist = myRNG.GetNormalSpec(specialist_scaling,specialist_scaling/2);
      cellXY = FindCell(centres[ind],angle, dist);
      s.add(new Specialist(this_ecosystem,
        cellXY.x, cellXY.y,
        cp_sp[this_ecosystem],8,InitialDensity));
    }


    float generalist_scaling = 100/aggregation; 
    float generalist_sensitivity = random(0.0,1.0);
    for(int i = 0; i < initial_abund; i ++){
      ind = int(random(0,centres.length));
      angle = random(0,2*PI);
      dist = myRNG.GetNormalSpec(generalist_scaling,generalist_scaling/2);
      cellXY = FindCell(centres[ind],angle, dist);
      g.add(new Generalist(this_ecosystem,
        cellXY.x, cellXY.y,
        cp_sp[this_ecosystem],10,InitialDensity,generalist_sensitivity));
    }

    float climate_scaling = 10/aggregation; 
    for(int i = 0; i < initial_abund; i ++){
      ind = int(random(0,centres.length));
      angle = random(0,2*PI);
      dist = myRNG.GetNormalSpec(climate_scaling,climate_scaling/2);
      cellXY = FindCell(centres[ind],angle, dist);
      c.add(new ClimateSensitive(this_ecosystem,
        cellXY.x, cellXY.y,
        cp_sp[this_ecosystem],7,ClimateSensitivity*Temperature));
    }
    

    float tolerant_scaling = 50/aggregation; 
    for(int i = 0; i < initial_abund; i ++){
      ind = int(random(0,centres.length));
      angle = random(0,2*PI);
      dist = myRNG.GetNormalSpec(tolerant_scaling,tolerant_scaling/2);
      cellXY = FindCell(centres[ind],angle, dist);
      t.add(new Tolerant(this_ecosystem,
        cellXY.x, cellXY.y,
        cp_sp[this_ecosystem],10,InitialDensity));
    }
  
  }
  
  void FindEcosystemCells(){
    this_cells.clear();
    for(int i = 0; i < landscape.length; i++){
      for(int j = 0; j < landscape[0].length; j++){
        if(landscape[i][j] == this_ecosystem){
          this_cells.add(new Cell(i,j));
          //this_cells.append(j);
        } 
      }
    }
  }
  
  
  Point FindCell(int[] cells, float angle, float d){
    int x = round(cells[0]+sin(angle)*d);
    if(x < 0){
      x = 0;
    } else if (x >= landscape.length){
      x = landscape.length-1;
    }
    int y = round(cells[1]+cos(angle)*d);
    if(y < 0){
      y = 0;
    } else if(y >= landscape[0].length){
      y = landscape[0].length-1;
    }
    return new Point(x,y);
  }
  
  
  void CalculateExtentOfOccurences(){
    
    ArrayList<Point> sp_points = new ArrayList<Point>();
    Point[] ch;
        
    //Process specialists
    for(int i = 0; i < s.size();i++){
      sp_points.add(new Point(s.get(i).col,s.get(i).row));
    }
    ch = ConvHull.jarvisMarch(sp_points,0, 0);
    eeo_s.add(ConvHull.ConvHullArea(ch));
    sp_points.clear();
    
   //Process generalist
    for(int i = 0; i < g.size();i++){
      sp_points.add(new Point(g.get(i).col,g.get(i).row));
    }
    ch = ConvHull.jarvisMarch(sp_points,0, 0);
    eeo_g.add(ConvHull.ConvHullArea(ch));
    sp_points.clear();
    
    //Process generalist
    for(int i = 0; i < c.size();i++){
      sp_points.add(new Point(c.get(i).col,c.get(i).row));
    }
    ch = ConvHull.jarvisMarch(sp_points,0, 0);
    eeo_c.add(ConvHull.ConvHullArea(ch));
   sp_points.clear();
    
    //Process generalist
    for(int i = 0; i < t.size();i++){
      sp_points.add(new Point(t.get(i).col,t.get(i).row));
    }
    ch = ConvHull.jarvisMarch(sp_points,0, 0);
    eeo_t.add(ConvHull.ConvHullArea(ch));
   sp_points.clear();
    
    //Process generalist
    for(int i = 0; i < exotic_g.size();i++){
      sp_points.add(new Point(exotic_g.get(i).col,exotic_g.get(i).row));
    }
    ch = ConvHull.jarvisMarch(sp_points,0, 0);
    eeo_ex_g.add(ConvHull.ConvHullArea(ch));
   sp_points.clear();
    
    //Process generalist
    for(int i = 0; i < exotic_c.size();i++){
      sp_points.add(new Point(exotic_c.get(i).col,exotic_c.get(i).row));
    }
    ch = ConvHull.jarvisMarch(sp_points,0, 0);
    eeo_ex_c.add(ConvHull.ConvHullArea(ch)); 
  }

  void RecordPopulationsSizes(){
    pop_s.add(s.size());
    pop_g.add(g.size());
    pop_c.add(c.size());
    pop_t.add(t.size());
    pop_ex_g.add(exotic_g.size());
    pop_ex_c.add(exotic_c.size());
  }

  
  
  void CalculateDensities(){
    
  }
  
  
  void UpdateSpecies(){
    
    
    //Calculate the densities of each species within pristine fragments
    
    //update specialists
    for(int i = 0; i < s.size(); i ++){
      s.get(i).UpdateHabitat(landscape[s.get(i).col][s.get(i).row]);
      if(s.get(i).CheckExtinction())
        s.remove(i);
    }
    
    //Update generalists
    int n_matrix_gens = 0;
    for(int i = 0; i < g.size(); i ++){
      g.get(i).UpdateHabitat(landscape[g.get(i).col][g.get(i).row]);
    }
    for(int i = 0; i < g.size(); i ++){
      if(g.get(i).CurrentHabitat == ecosystems.length) n_matrix_gens ++;
    }
    for(int i = 0; i < g.size(); i ++){
      if(g.get(i).CheckExtinction(n_matrix_gens))
      {
        g.remove(i);
        n_matrix_gens--;
      }
    }
    
    //update climate sensitives
    for(int i = 0; i < c.size(); i ++){
      c.get(i).UpdateHabitat(landscape[c.get(i).col][c.get(i).row]);
      if(c.get(i).CheckExtinction(Temperature))
        c.remove(i);
    }
    
    //Disturbance tolerant
    for(int i = 0; i < t.size(); i ++){
      t.get(i).UpdateHabitat(landscape[t.get(i).col][t.get(i).row]);
      if(t.get(i).CheckExtinction(FindNearestPristineHabitat(t.get(i).col,t.get(i).row)))
        t.remove(i);
    }
    
    int ind;
    float angle;
    float dist;
    float InitialDensity;
    float ClimateSensitivity = random(1.0,1.5);
    float generalist_scaling = 50/aggregation;
    float generalist_sensitivity = random(0.0,1.0);
    Point cellXY;
    //Add exotics - max 2 species per step
    for(int i = 0; i < 2; i++){
      if(homogenisation_scale*matrix/pristine > random(0,1)){
        ind = floor(random(0,ProtectedCentres[0].length));
        angle = random(0,2*PI);
        dist = myRNG.GetNormalSpec(generalist_scaling,generalist_scaling/2);
        InitialDensity = 0.5/this_cells.size();
        
        cellXY = FindCell(new int[] {ProtectedCentres[this_ecosystem][ind].x,
                                    ProtectedCentres[this_ecosystem][ind].y},angle, dist);
        exotic_g.add(new Generalist(this_ecosystem,
          cellXY.x, cellXY.y,
          color(0),10,InitialDensity, generalist_sensitivity));
        
      }
      
      float climate_scaling = 20/aggregation;
      if(Temperature/InitialTemperature > random(1.01,2.5)){
        ind = floor(random(0,ProtectedCentres[0].length));
        angle = random(0,2*PI);
        dist = myRNG.GetNormalSpec(climate_scaling,climate_scaling/2);
        
        cellXY = FindCell(new int[] {ProtectedCentres[this_ecosystem][ind].x,
                                    ProtectedCentres[this_ecosystem][ind].y},angle, dist);
        exotic_c.add(new ClimateSensitive(this_ecosystem,
          cellXY.x, cellXY.y,
          color(0),7,ClimateSensitivity*Temperature)); 
      }
    }
    
    //Update generalists
    n_matrix_gens = 0;
    for(int i = 0; i < exotic_g.size(); i ++){
      exotic_g.get(i).UpdateHabitat(landscape[exotic_g.get(i).col][exotic_g.get(i).row]);
    }
    for(int i = 0; i < exotic_g.size(); i ++){
      if(exotic_g.get(i).CurrentHabitat == ecosystems.length) n_matrix_gens ++;
    }
    for(int i = 0; i < exotic_g.size(); i ++){
      if(exotic_g.get(i).CheckExtinction(n_matrix_gens))
      {
        exotic_g.remove(i);
        n_matrix_gens--;
      }
    }
    
        //update climate sensitives
    for(int i = 0; i < exotic_c.size(); i ++){
      exotic_c.get(i).UpdateHabitat(landscape[exotic_c.get(i).col][exotic_c.get(i).row]);
      if(exotic_c.get(i).CheckExtinction(Temperature))
        exotic_c.remove(i);
    }
    
    
  }
  
  
  float FindNearestPristineHabitat(int x, int y){
    float Distance = 1E6;
    
    if(landscape[x][y] == this_ecosystem){
      Distance = 0;
    }
    else{
      
      for(int i = 0; i < landscape.length; i ++)
      {
        for(int j = 0; j < landscape[0].length; j ++)
        {
          if(landscape[x][y] == this_ecosystem && sqrt(sq(i-x) + sq(j - y)) < Distance)
          {
            Distance = sqrt(sq(i-x) + sq(j - y));
          }
        }
      }
    }
    return Distance;
//    while(Distance == 999999)
//      i = 
  }
  
  void drawLandscape(){

    // Draw cells
    for (int i = 0; i < this_cells.size(); i++) {
      int col = this_cells.get(i).x;
      int row = this_cells.get(i).y;
      fill(cp[this_ecosystem]);
      noStroke();
      //point(i*2,j*2);
      rect(border + col*aggregation,border + row*aggregation,aggregation,aggregation);
//      imageMode(CORNER);
//      image(BiomeImages[this_ecosystem],border + col*aggregation,border + row*aggregation,aggregation,aggregation);
    }
  }
  
 void drawSpecies(){ 
    for(int i = 0; i < s.size(); i ++){
      s.get(i).display();
    }
    for(int i = 0;i< g.size(); i++){
      g.get(i).display();
    }
    for(int i = 0;i< c.size(); i++){
      c.get(i).display();
    }
    for(int i = 0;i< t.size(); i++){
      t.get(i).display();
    }
    //exotics
    for(int i = 0;i< exotic_g.size(); i++){
      exotic_g.get(i).display();
    }
    for(int i = 0;i< exotic_c.size(); i++){
      exotic_c.get(i).display();
    }
    
  }
  
}




class Generalist
{
  int Habitat_aff;
  int CurrentHabitat;
  float matrix_density_scaling;
  float InitialDensity;
  int col;
  int row;
  color cp;
  int size;
  boolean Extinct;
  
  
  Generalist(int affinity, int c, int r, color csp, int sz, float i_d, float s){
    Habitat_aff = affinity;
    col = c;
    row = r;
    cp = csp;
    size = sz;
    InitialDensity = i_d;
    CurrentHabitat = landscape[col][row];
    matrix_density_scaling = s;

  }
  
  void UpdateHabitat(int newHabitat){
    CurrentHabitat = newHabitat;
  }
  
  boolean CheckExtinction(int n_in_matrix){
    
    if(matrix > 0){
      if(n_in_matrix/matrix > matrix_density_scaling*InitialDensity){
        Extinct = true;
      }
      else{
        Extinct = false;
      }
    }
    
    return Extinct;
  }
 
  void display()
 {
   fill(cp);
   stroke(0,0,0);
   ellipse(border+(aggregation/2)+col*aggregation,border+(aggregation/2)+row*aggregation,size,size);
 } 
  
}




class MyLandscape{
  int convertedCount;
  ArrayList<Point> FrontierCells1;
  ArrayList<Point> FrontierCells2;
  ArrayList<Point> FrontierCells3;
  
  
  
  MyLandscape(int[][] l, float f1,float f2){
    pristine = l.length*l[0].length;
    FrontierCells1 = new ArrayList<Point>();    
    FrontierCells2 = new ArrayList<Point>();
    FrontierCells3 = new ArrayList<Point>();
    
    int cellsForConversion = int(f1*l.length*l[0].length);
    int initialCells = int(f2*cellsForConversion/3);
    
    //for(int i = 0; i < nSeeds; i++){
      int xs = round(random(0,l.length));
      int ys = round(random(0,l[0].length));
      FrontierCells1.add(new Point(xs,ys));
      xs = round(random(0,l.length));
      ys = round(random(0,l[0].length));
      FrontierCells2.add(new Point(xs,ys));
      
      xs = round(random(0,l.length));
      ys = round(random(0,l[0].length));
      FrontierCells3.add(new Point(xs,ys));
    //}

    int next_x;
    int next_y;    
    //Take a random walk from each seed to generate initial frontier cells
    //for(int j = 0; j < nSeeds; j++){
      for(int i = 0; i < initialCells; i++){    
        //Find next cell
        next_x = round(random(max(0,FrontierCells1.get(i).x-1),min(l.length,FrontierCells1.get(i).x+1)));
        next_y = round(random(max(0,FrontierCells1.get(i).y-1),min(l[0].length,FrontierCells1.get(i).y+1)));
        FrontierCells1.add(new Point(next_x,next_y));
        
        
        next_x = round(random(max(0,FrontierCells2.get(i).x-1),min(l.length,FrontierCells2.get(i).x+1)));
        next_y = round(random(max(0,FrontierCells2.get(i).y-1),min(l[0].length,FrontierCells2.get(i).y+1)));
        FrontierCells2.add(new Point(next_x,next_y));
        
        
        next_x = round(random(max(0,FrontierCells3.get(i).x-1),min(l.length,FrontierCells3.get(i).x+1)));
        next_y = round(random(max(0,FrontierCells3.get(i).y-1),min(l[0].length,FrontierCells3.get(i).y+1)));
        FrontierCells3.add(new Point(next_x,next_y));
        
      }
    //}
    
  }
  
  void ConvertHabitat(int[][] l, float f1){
    
    int cellsForConversion = int(f1*l.length*l[0].length/3);
        
    
    
    int cellsConverted = 0;
    
    //Walk along frontier cells converting anything that isn't matrix
    //for(int s = 0; s < FrontierCells1.length; s++){
      int f = floor(random(0,FrontierCells1.size()));
      while((cellsConverted < cellsForConversion) && (f < FrontierCells1.size())){
        
        for(int i = max(0,FrontierCells1.get(f).x-round(abs(myRNG.GetNormal()*2)));i < min(l.length,FrontierCells1.get(f).x+round(abs(myRNG.GetNormal()*2))) ;i++){ //&& (cellsConverted < cellsForConversion)
          for(int j = max(0,FrontierCells1.get(f).y-round(abs(myRNG.GetNormal()*2)));j < min(l[0].length,FrontierCells1.get(f).y+round(abs(myRNG.GetNormal()*2))) ; j++){//&& (cellsConverted < cellsForConversion)
            if(landscape[i][j] != ecosystems.length && protection[i][j] == -1 && !FrontierCells1.contains(new Point(i,j))){
              landscape[i][j] = ecosystems.length;
              cellsConverted++;
              matrix++;
              FrontierCells1.add(new Point(i,j));
            }
          }
        }
        FrontierCells1.remove(f);
        //f++;
      }
      
      
     f = floor(random(0,FrontierCells2.size()));
      while((cellsConverted < 2*cellsForConversion) && (f < FrontierCells2.size())){
        
        for(int i = max(0,FrontierCells2.get(f).x-round(abs(myRNG.GetNormal()*3)));i < min(l.length,FrontierCells2.get(f).x+round(abs(myRNG.GetNormal()*3))) ;i++){ //&& (cellsConverted < cellsForConversion)
          for(int j = max(0,FrontierCells2.get(f).y-round(abs(myRNG.GetNormal()*3)));j < min(l[0].length,FrontierCells2.get(f).y+round(abs(myRNG.GetNormal()*3))) ; j++){//&& (cellsConverted < cellsForConversion)
            if(landscape[i][j] != ecosystems.length && protection[i][j] == -1  && !FrontierCells2.contains(new Point(i,j))){
              landscape[i][j] = ecosystems.length;
              cellsConverted++;
              matrix++;
              FrontierCells2.add(new Point(i,j));
            }
          }
        }
        FrontierCells2.remove(f);
        //f++;
      }
    //}
    
     f = floor(random(0,FrontierCells3.size()));
      while((cellsConverted < 3*cellsForConversion) && (f < FrontierCells3.size())){
        
        for(int i = max(0,FrontierCells3.get(f).x-round(abs(myRNG.GetNormal()*3)));i < min(l.length,FrontierCells3.get(f).x+round(abs(myRNG.GetNormal()*3))) ;i++){ //&& (cellsConverted < cellsForConversion)
          for(int j = max(0,FrontierCells3.get(f).y-round(abs(myRNG.GetNormal()*3)));j < min(l[0].length,FrontierCells3.get(f).y+round(abs(myRNG.GetNormal()*3))) ; j++){//&& (cellsConverted < cellsForConversion)
            if(landscape[i][j] != ecosystems.length && protection[i][j] == -1  && !FrontierCells3.contains(new Point(i,j))){
              landscape[i][j] = ecosystems.length;
              cellsConverted++;
              matrix++;
              FrontierCells3.add(new Point(i,j));
            }
          }
        }
        FrontierCells3.remove(f);
        //f++;
      }
    
    
    convertedCount += cellsConverted;
    pristine -= cellsConverted;
  }
  
  
  
  
  float[] GetEcosystemEndemicSpeciesRichness(){
    float[] EcosystemRichness = new float[ecosystems.length+1];
    int[][][] EcosystemAbundances = new int[ecosystems.length][4][ecosystems.length+1];
    
    //Loop over all ecosystems
    for(int i = 0;i < ecosystems.length; i++){
      int sp = 0;
      //Count the abundances of each species in each ecosystem type
      for(int j = 0; j < ecosystems[i].s.size(); j++){
        if(ecosystems[i].s.get(j).CurrentHabitat == ecosystems[i].s.get(j).Habitat_aff) 
          EcosystemAbundances[i][sp][ecosystems[i].s.get(j).CurrentHabitat]++;
      }
      sp++;
      for(int j = 0; j < ecosystems[i].g.size(); j++){
        if(ecosystems[i].g.get(j).CurrentHabitat == ecosystems[i].g.get(j).Habitat_aff)
          EcosystemAbundances[i][sp][ecosystems[i].g.get(j).CurrentHabitat]++;
      }
      sp++;
      for(int j = 0; j < ecosystems[i].c.size(); j++){
        if(ecosystems[i].c.get(j).CurrentHabitat == ecosystems[i].c.get(j).Habitat_aff)
          EcosystemAbundances[i][sp][ecosystems[i].c.get(j).CurrentHabitat]++;
      }
      sp++;
      for(int j = 0; j < ecosystems[i].t.size(); j++){
        if(ecosystems[i].t.get(j).CurrentHabitat == ecosystems[i].t.get(j).Habitat_aff)
          EcosystemAbundances[i][sp][ecosystems[i].t.get(j).CurrentHabitat]++;
      }
    }
    
    
    for(int i = 0; i < EcosystemAbundances[0][0].length; i++){
      for(int j = 0; j < EcosystemAbundances[0].length; j++){
        for(int k = 0; k < EcosystemAbundances.length; k++){
          if(EcosystemAbundances[k][j][i] > 0) EcosystemRichness[i]++;
        }
      }
    }
    
    
    return EcosystemRichness;
  }
  
  
  float[] GetEcosystemExoticSpeciesRichness(){
    float[] EcosystemRichness = new float[ecosystems.length+1];
    int[][][] EcosystemAbundances = new int[ecosystems.length][6][ecosystems.length+1];
    
    //Loop over all ecosystems
    for(int i = 0;i < ecosystems.length; i++){
      int sp = 0;
      //Count the abundances of each species in each ecosystem type
      for(int j = 0; j < ecosystems[i].s.size(); j++){
        if(ecosystems[i].s.get(j).CurrentHabitat != ecosystems[i].s.get(j).Habitat_aff) 
          EcosystemAbundances[i][sp][ecosystems[i].s.get(j).CurrentHabitat]++;
      }
      sp++;
      for(int j = 0; j < ecosystems[i].g.size(); j++){
        if(ecosystems[i].g.get(j).CurrentHabitat != ecosystems[i].g.get(j).Habitat_aff)
          EcosystemAbundances[i][sp][ecosystems[i].g.get(j).CurrentHabitat]++;
      }
      sp++;
      for(int j = 0; j < ecosystems[i].c.size(); j++){
        if(ecosystems[i].c.get(j).CurrentHabitat != ecosystems[i].c.get(j).Habitat_aff)
          EcosystemAbundances[i][sp][ecosystems[i].c.get(j).CurrentHabitat]++;
      }
      sp++;
      for(int j = 0; j < ecosystems[i].t.size(); j++){
        if(ecosystems[i].t.get(j).CurrentHabitat != ecosystems[i].t.get(j).Habitat_aff)
          EcosystemAbundances[i][sp][ecosystems[i].t.get(j).CurrentHabitat]++;
      }
      sp++;
      for(int j = 0; j < ecosystems[i].exotic_g.size(); j++){
        EcosystemAbundances[i][sp][ecosystems[i].exotic_g.get(j).CurrentHabitat]++;
      }
      sp++;
      for(int j = 0; j < ecosystems[i].exotic_c.size(); j++){
        EcosystemAbundances[i][sp][ecosystems[i].exotic_c.get(j).CurrentHabitat]++;
      }
    }
    
    
    for(int i = 0; i < EcosystemAbundances[0][0].length; i++){
      for(int j = 0; j < EcosystemAbundances[0].length; j++){
        for(int k = 0; k < EcosystemAbundances.length; k++){
          if(EcosystemAbundances[k][j][i] > 0) EcosystemRichness[i]++;
        }
      }
    }
    
    
    return EcosystemRichness;
  }
  
  
  
  float CalculateExtinctionRisk(){
    // 2 exotic species across all ecosystems and 4 other species per ecosystem 
    float num_species = 2 + ecosystems.length * 4;
    float num_at_risk = 0;
    int l;
    float eeo_thresh = -0.3;
    float pop_thresh = -0.3;
    boolean ex_g_at_risk = false;
    boolean ex_c_at_risk = false;
    
    
    
    for(int i = 0; i < ecosystems.length; i++){
      
      l = ecosystems[i].eeo_s.size()-1;
      if((ecosystems[i].eeo_s.get(0) > 0 && (ecosystems[i].eeo_s.get(l)-ecosystems[i].eeo_s.get(0)) <= ecosystems[i].eeo_s.get(l)*eeo_thresh) ||
         (ecosystems[i].pop_s.get(0) > 0 && (ecosystems[i].pop_s.get(l)-ecosystems[i].pop_s.get(0)) <= ecosystems[i].pop_s.get(l)*pop_thresh)) num_at_risk++;
         
       l = ecosystems[i].eeo_g.size()-1;
      if((ecosystems[i].eeo_g.get(0) > 0 && (ecosystems[i].eeo_g.get(l)-ecosystems[i].eeo_g.get(0)) <= ecosystems[i].eeo_g.get(0)*eeo_thresh) ||
         (ecosystems[i].pop_g.get(0) > 0 && (ecosystems[i].pop_g.get(l)-ecosystems[i].pop_g.get(0)) <= ecosystems[i].pop_g.get(0)*pop_thresh)) num_at_risk++;
         
       l = ecosystems[i].eeo_c.size()-1;
      if((ecosystems[i].eeo_c.get(0) > 0 && (ecosystems[i].eeo_c.get(l)-ecosystems[i].eeo_c.get(0)) <= ecosystems[i].eeo_c.get(0)*eeo_thresh) ||
         (ecosystems[i].pop_c.get(0) > 0 && (ecosystems[i].pop_c.get(l)-ecosystems[i].pop_c.get(0)) <= ecosystems[i].pop_c.get(0)*pop_thresh)) num_at_risk++;
         
       l = ecosystems[i].eeo_t.size()-1;
      if((ecosystems[i].eeo_t.get(0) > 0 && (ecosystems[i].eeo_t.get(l)-ecosystems[i].eeo_t.get(0)) <= ecosystems[i].eeo_t.get(0)*eeo_thresh) ||
         (ecosystems[i].pop_t.get(0) > 0 && (ecosystems[i].pop_t.get(l)-ecosystems[i].pop_t.get(0)) <= ecosystems[i].pop_t.get(0)*pop_thresh)) num_at_risk++;
         
       l = ecosystems[i].eeo_ex_g.size()-1;
      if((ecosystems[i].eeo_ex_g.get(0) > 0 && (ecosystems[i].eeo_ex_g.get(l)-ecosystems[i].eeo_ex_g.get(0)) <= ecosystems[i].eeo_ex_g.get(0)*eeo_thresh) ||
         (ecosystems[i].pop_ex_g.get(0) > 0 && (ecosystems[i].pop_ex_g.get(l)-ecosystems[i].pop_ex_g.get(0)) <= ecosystems[i].pop_ex_g.get(0)*pop_thresh)) num_at_risk++;
         
       l = ecosystems[i].eeo_ex_c.size()-1;
      if((ecosystems[i].eeo_ex_c.get(0) > 0 && (ecosystems[i].eeo_ex_c.get(l)-ecosystems[i].eeo_ex_c.get(0)) <= ecosystems[i].eeo_ex_c.get(0)*eeo_thresh) ||
         (ecosystems[i].pop_ex_c.get(0) > 0 && (ecosystems[i].pop_ex_c.get(l)-ecosystems[i].pop_ex_c.get(0)) <= ecosystems[i].pop_ex_c.get(0)*pop_thresh)) num_at_risk++;
    }
    
    
    
    if(ex_g_at_risk) num_at_risk++;
    if(ex_c_at_risk) num_at_risk++;
    
    
    
    return (1.0 - (num_at_risk/num_species));
    
  }
  
}


class Shape{
  ArrayList<PVector> vertices = new ArrayList<PVector>();
  color fl;
  color strokeCol;
  
  Shape(color f,color st){
    fl = f;
    strokeCol = st;
  }
  
  void addVertex(float x,float y){
    vertices.add(new PVector(x,y));
  }
  void draw(){
    pushStyle();
    beginShape();
    fill(fl);
    stroke(strokeCol);
    for(PVector v : vertices) vertex(v.x,v.y);
    endShape(CLOSE);
    popStyle();
  }
  
  void star(float x, float y, float radius1, float radius2, int npoints) {
    float angle = TWO_PI / npoints;
    float halfAngle = angle/2.0;
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + cos(a) * radius2;
      float sy = y + sin(a) * radius2;
      addVertex(sx, sy);
      sx = x + cos(a+halfAngle) * radius1;
      sy = y + sin(a+halfAngle) * radius1;
      addVertex(sx, sy);
    }
  }
  
  void MyTriangle(float x, float y, float radius){
    float side = 3*radius/sqrt(3);
    float inAngle = TWO_PI/6;
    float outAngle = PI/6;
    float dx = side/2.0;
    float dy = radius/2;
    
    addVertex(x,y - radius);
    addVertex(x+dx,y+dy);
    addVertex(x-dx,y + dy);
  }
  
} 





class Specialist{
  int Habitat_aff;
  int CurrentHabitat;
  float sensitivity = 0.1;
  float InitialDensity;
  int col;
  int row;
  color cp;
  int size;
  Shape s;
  boolean Extinct = false;
  
  Specialist(int affinity, int c, int r, color csp, int sz, float i_d){
    Habitat_aff = affinity;
    col = c;
    row = r;
    cp = csp;
    size = sz;
    InitialDensity = i_d;
    CurrentHabitat = landscape[col][row];

    //s = new Star(csp, color(0,0,0),2,0.15);
    s = new Shape(csp, color(0,0,0));
    s.star(border+(aggregation/2)+c*aggregation,border+(aggregation/2)+r*aggregation,sz*0.5,sz,5);
    
  }
  
  void UpdateHabitat(int newHabitat){
    CurrentHabitat = newHabitat;
  }
  
  boolean CheckExtinction(){
    if(CurrentHabitat != Habitat_aff){
      Extinct = true;
    }
    else{
      Extinct = false;
    }
    
    return Extinct;
  }
  
 
  void display()
 {
   //fill(cp);
   //s.display(col,row);
   s.draw();
 } 
}




class StudyDomain{
  int[] x_extent;
  int[] y_extent;
  int[][][] EcosystemAbundances;  
  
  StudyDomain(int w, int h, float xf, float yf){
    x_extent = new int[2];
    y_extent = new int[2];
    
    x_extent[0] = floor(random(0,w*(1-xf)));
    x_extent[1] = x_extent[0] + floor(xf*w);
    y_extent[0] = floor(random(0,h*(1-yf)));
    y_extent[1] = y_extent[0] + floor(yf*h);
    
    EcosystemAbundances = new int[ecosystems.length][6][ecosystems.length+1];
  }
  
  
  
  void CalculateStudyEcosystemAbundances(){
    EcosystemAbundances = new int[ecosystems.length][6][ecosystems.length+1];
    int x;
    int y;
    //Loop over all ecosystems
    for(int i = 0;i < ecosystems.length; i++){
      int sp = 0;
      //Count the abundances of each species in each ecosystem type
      for(int j = 0; j < ecosystems[i].s.size(); j++){
        x = ecosystems[i].s.get(j).col;
        y = ecosystems[i].s.get(j).row;
        if(x >= x_extent[0] && x <x_extent[1] && y >= y_extent[0] && y < y_extent[1]){ 
          EcosystemAbundances[i][sp][ecosystems[i].s.get(j).CurrentHabitat]++;
        }
      }
      sp++;
      for(int j = 0; j < ecosystems[i].g.size(); j++){
        x = ecosystems[i].g.get(j).col;
        y = ecosystems[i].g.get(j).row;
        if(x >= x_extent[0] && x <x_extent[1] && y >= y_extent[0] && y < y_extent[1]){
          EcosystemAbundances[i][sp][ecosystems[i].g.get(j).CurrentHabitat]++;
        }
      }
      sp++;
      for(int j = 0; j < ecosystems[i].c.size(); j++){
        x = ecosystems[i].c.get(j).col;
        y = ecosystems[i].c.get(j).row;
        if(x >= x_extent[0] && x <x_extent[1] && y >= y_extent[0] && y < y_extent[1]){
          EcosystemAbundances[i][sp][ecosystems[i].c.get(j).CurrentHabitat]++;
        }
      }
      sp++;
      for(int j = 0; j < ecosystems[i].t.size(); j++){
        x = ecosystems[i].t.get(j).col;
        y = ecosystems[i].t.get(j).row;
        if(x >= x_extent[0] && x <x_extent[1] && y >= y_extent[0] && y < y_extent[1]){
          EcosystemAbundances[i][sp][ecosystems[i].t.get(j).CurrentHabitat]++;
        }
      }
      sp++;
      for(int j = 0; j < ecosystems[i].exotic_g.size(); j++){
        x = ecosystems[i].exotic_g.get(j).col;
        y = ecosystems[i].exotic_g.get(j).row;
        if(x >= x_extent[0] && x <x_extent[1] && y >= y_extent[0] && y < y_extent[1]){
          EcosystemAbundances[i][sp][ecosystems[i].exotic_g.get(j).CurrentHabitat]++;
        }
      }
      sp++;
      for(int j = 0; j < ecosystems[i].exotic_c.size(); j++){
        x = ecosystems[i].exotic_c.get(j).col;
        y = ecosystems[i].exotic_c.get(j).row;
        if(x >= x_extent[0] && x <x_extent[1] && y >= y_extent[0] && y < y_extent[1]){
          EcosystemAbundances[i][sp][ecosystems[i].exotic_c.get(j).CurrentHabitat]++;
        }
      }
    }
  }
  
  float StudySpeciesRichness(){
    float StudyRichness = 0;
    
    
    for(int i = 0; i < EcosystemAbundances[0][0].length; i++){
      for(int j = 0; j < EcosystemAbundances[0].length-2; j++){
        for(int k = 0; k < EcosystemAbundances.length; k++){
          if(EcosystemAbundances[k][j][i] > 0) StudyRichness++;
        }
      }
    }
    
    for(int j = EcosystemAbundances[0].length-2; j < EcosystemAbundances[0].length; j++){
      boolean present = false;
      for(int i = 0; i < EcosystemAbundances[0][0].length; i++){
        for(int k = 0; k < EcosystemAbundances.length; k++){
          if(EcosystemAbundances[k][j][i] > 0) present = true;
        }
      }
      if(present) StudyRichness++;
    }

    return StudyRichness;
  }
  
  float StudyAbundances(){
    float StudyAbundance = 0;
    
    for(int i = 0; i < EcosystemAbundances[0][0].length; i++){
      for(int j = 0; j < EcosystemAbundances[0].length; j++){
        for(int k = 0; k < EcosystemAbundances.length; k++){
          StudyAbundance += EcosystemAbundances[k][j][i];
        }
      }
    }
    
    return StudyAbundance;
    
  }
  
  void StudyFunctionalRichness(){
  }
  
  void display(){
    strokeWeight(3.0);
    stroke(color(150,150,150,150));
    noFill();
    rect(border+x_extent[0]*aggregation,border +y_extent[0]*aggregation,(x_extent[1]-x_extent[0])*aggregation, (y_extent[1]-y_extent[0])*aggregation);
    strokeWeight(1.0);
    stroke(color(0));
  }
  
}




class RNG
{
  
  float GetNormal()
  {
     float u1 = random(0,1);
     float u2 = random(0,1);
     float r = sqrt(-2.0 * log(u1));
     float theta = 2.0 * PI * u2;
     return r * sin(theta);
  }
  
  float GetNormalSpec(float mean, float sd)
  {
    return mean + sd * this.GetNormal();
  }
  
}



class Tolerant
{
  int Habitat_aff;
  int CurrentHabitat;
  int col;
  int row;
  color cp;
  int size;
  boolean Extinct;
  float ToleranceDistance;
  
  Tolerant(int affinity, int c, int r, color csp, int sz, float t_d){
    Habitat_aff = affinity;
    col = c;
    row = r;
    cp = csp;
    size = sz;
    ToleranceDistance = t_d;
    CurrentHabitat = landscape[col][row];
  }
  
  void UpdateHabitat(int newHabitat){
    CurrentHabitat = newHabitat;
  }
  
  boolean CheckExtinction(float Distance){
    
    if(CurrentHabitat != Habitat_aff && Distance > ToleranceDistance){
      Extinct = true;
    }
    else{
      Extinct = false;
    }
    
    return Extinct;
  }
  
 
  void display()
 {
   fill(cp);
   stroke(0,0,0);
   rectMode(CENTER);
   rect(border+(aggregation/2)+col*aggregation,border+(aggregation/2)+row*aggregation,size,size);
   rectMode(CORNER);
 } 
  
}






class XYChart{
  float minYVal;
  float maxYVal;
  float minXVal;
  float maxXVal;
  float[] yData;
  float[] xData;
  float[] yData2;
  float[] xData2;
  boolean plotPts;
  color lCol;
  color ptCol;
  color lCol2;
  color ptCol2;
  float lWidth;
  float ptSize;
  String YLab;
  String XLab;
  
  
    
  float leftMargin = 0.1; //Proportion of width
  float AxisLeftMargin = 0.08;
  float LabLeftMargin = 0.0;
  float bottomMargin = 0.1; //Proportion on height
  float AxisBottomMargin = 0.05;
  float LabBottomMargin = 0.0;
  float plotTextSize = 0.05;//text size as proportion of height
  float labTextSize = 0.07;
  
  XYChart(){
    lCol = color(0);
    lWidth = 2;
    
    plotPts = true;
    ptCol = color(0);
    ptSize = 4;
  }
  
  
  void SetLineColour(color c){
    lCol = c;
  }

  void SetLineColour2(color c){
    lCol2 = c;
  }  
  
  void SetLineWidth(float w){
    lWidth = w;
  }
  
  void SetPointColour(color c){
    ptCol = c;
  }
  
  void SetPointColour2(color c){
    ptCol2 = c;
  }
  
  void SetPointSize(float s){
    ptSize = s;
  }
  
  void SetMinYVal(float y){
    minYVal = y;
  } 
  
  void SetMaxYVal(float y){
    maxYVal = y;
  }
  
  void SetMinXVal(float x){
    minXVal = x;
  }
  
  void SetMaxXVal(float x){
    maxXVal = x;
  }
  
  void SetData(float[] x_d, float[] y_d){
    xData = x_d;
    yData = y_d;
  }
  
  void SetData2(float[] x_d, float[] y_d){
    xData2 = x_d;
    yData2 = y_d;
  }
  
  float[] GetYCoords(float h, float[] Data){
    float[] y_coords = new float[Data.length];
    
    for(int i = 0; i < Data.length; i++){
      if(Data[i] <= minYVal){
        y_coords[i] = 0;
      }
      else if (Data[i] >= maxYVal){
        y_coords[i] = h*(1-bottomMargin);
      } else{
        y_coords[i] = map(Data[i],minYVal, maxYVal,0,h*(1-bottomMargin));
      }
    }
    return y_coords;
  }
  
  float[] GetXCoords(float w, float[] Data){
    float[] x_coords = new float[Data.length]; 
    
    for(int i = 0; i < Data.length; i++){
      if(Data[i] <= minXVal){
        x_coords[i] = 0;
      }
      else if (Data[i] >= maxXVal){
        x_coords[i] = w*(1-leftMargin);
      } else{
        x_coords[i] = map(Data[i],minXVal, maxXVal,0,w*(1-leftMargin));
      }
    }
    return x_coords;
  }
  
    void SetYAxisLabel(String s){
    YLab = s;
  }
  
  void SetXAxisLabel(String s){
    XLab = s;
  }
  
  void draw(float x, float top, float w, float h){
    
    //Calculate the y coordinates of each data point in screen coordinates
    float y0 = (top)+(h*(1-bottomMargin));
    float[] y_coords;
    float[] y_coords2;
    
    y_coords = GetYCoords(h,yData);
    if(yData2 != null){
      y_coords2 = GetYCoords(h,yData2);
    } else{
      y_coords2 = new float[0];
    } 
         
        
    //Calculate the x coordinates of each data point in screen coordinates
    float x0 = x+w*leftMargin;
    float[] x_coords; 
    float[] x_coords2;
    
    x_coords = GetXCoords(w,xData);
    if(xData2 != null){
      x_coords2 = GetXCoords(w,xData2);
    } else{
      x_coords2 = new float[0]; 
    }
        
    if(plotPts){
      //Plot points at each x,y pair
      ellipseMode(CENTER);
      fill(ptCol);
      for(int i = 0; i < xData.length; i++){
        ellipse(x0+x_coords[i],y0-y_coords[i],ptSize,ptSize);
      }
      
      if(xData2 != null){
        fill(ptCol2);
        for(int i = 0; i < xData2.length; i++){
          ellipse(x0+x_coords2[i],y0-y_coords2[i],ptSize,ptSize);
        }
      }
      
    }
    
       
    //Plot lines between each x,y pair
    stroke(lCol);
    strokeWeight(lWidth);
    for(int i = 0; i < xData.length-1; i++){
      line(x0+x_coords[i],y0-y_coords[i],x0+x_coords[i+1],y0-y_coords[i+1]);
    }
    if(xData2 != null){
      stroke(lCol2);
      for(int i = 0; i < xData2.length-1; i++){
        line(x0+x_coords2[i],y0-y_coords2[i],x0+x_coords2[i+1],y0-y_coords2[i+1]);
      }
    }
    
    strokeWeight(StrokeWt);
    
    
    //Draw y axis line
    line(x+w*leftMargin,top,x+w*leftMargin,y0);
    
    //Add y axis labels
    int n_labs = 5;
    float[] y_labs = new float[n_labs];
    float[] y_height = new float[n_labs];
    
    textAlign(RIGHT, CENTER);
    textSize(plotTextSize*h);
    fill(100);
    for(int i = 0; i < n_labs;i++){
      y_labs[i] = minYVal + (i*(maxYVal-minYVal)/(n_labs-1));
      y_height[i] =  map(y_labs[i],minYVal, maxYVal,0,h*(1-bottomMargin));
      text(str(y_labs[i]),x+w*AxisLeftMargin,y0-y_height[i]);
    }
    
    
    //Draw x axis line
    stroke(color(0));
    line(x+w*leftMargin,y0,x+w,y0);
    
    //Add x axis labels
    float[] x_labs = new float[n_labs];
    float[] x_width = new float[n_labs];
    
    textAlign(CENTER, CENTER);
    for(int i = 0; i < n_labs;i++){
      x_labs[i] = minXVal + (i*(maxXVal-minXVal)/(n_labs-1));
      x_width[i] =  map(x_labs[i],minXVal, maxXVal,0,w*(1-leftMargin));
      text(int(x_labs[i]),x0+x_width[i],top+h*(1-AxisBottomMargin));
    }
    
    //X label
    fill(100);
    textSize(labTextSize*h);
    textAlign(CENTER, CENTER);
    text(XLab,x0+map(minXVal+(maxXVal-minXVal)/2.0,minXVal, maxXVal,0,w*(1-leftMargin)),
         top+h*(1-LabBottomMargin));
    
    //Y label
    pushMatrix();    
    fill(100);
    textSize(labTextSize*h);
    textAlign(CENTER, BOTTOM);
    translate(x+w*LabLeftMargin,y0-map(((maxYVal-minYVal)/2),minYVal, maxYVal,0,h*(1-bottomMargin)));
    rotate(-PI/2);
    text(YLab,0,-0.07*w);
    popMatrix();
   
  }
  
  
}


class Point{
  int x;
  int y;

  Point(int col, int row){
    x = col;
    y = row;
  }
}

