//+------------------------------------------------------------------+
//|                                                   CyberCycle.mq4 |
//|                                     Copyright 2021, luisjavierjn |
//|                                               https://caudas.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2021, luisjavierjn"
#property link        "https://caudas.com"
#property version     "1.00"
#property description "Painting Arrows"
#property indicator_chart_window 

//--- indicator buffers 
double LineBuffer[];

int currentbar = 0;
int n = 1;
int buffers = 0;
int drawBegin = 0;
long current_chart_id;
string dt;

input double InpAlpha=0.07; // alpha
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit() 
{ 
//--- indicator buffers mapping 
   IndicatorBuffers(1);
   initBuffer(LineBuffer);
//--- 
   current_chart_id=ChartID();
   return(INIT_SUCCEEDED); 
} 
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total, 
                const int prev_calculated, 
                const datetime& time[], 
                const double& open[], 
                const double& high[], 
                const double& low[], 
                const double& close[], 
                const long& tick_volume[], 
                const long& volume[], 
                const int& spread[]) 
{ 
   int limit=rates_total-prev_calculated; // start index for calculations
   if(prev_calculated>0) limit++;
   
   if(limit>rates_total-n) // adjust for last bars
      limit=rates_total-n;
   else limit--;    

   if(limit>=0) {
      ArraySetAsSeries(time,true);
      ArraySetAsSeries(open,true);
      ArraySetAsSeries(high,true);
      ArraySetAsSeries(low,true);
      ArraySetAsSeries(close,true);      
   }
   
   for(int i=limit;i>=0;i--) {
      double ATRvalue=iATR(NULL,0,14,i);
      
      int j = iBarShift(NULL,PERIOD_D1,time[i]);      
      LineBuffer[i]=iCustom(NULL,PERIOD_D1,"ITrendToDaily",InpAlpha,0,j);      
      
      if(currentbar++<1) continue;

      dt = TimeToStr(Time[i], TIME_DATE|TIME_SECONDS);
      dt = StringSubstr(dt,0,4) + "-" + StringSubstr(dt,5,2) + "-" + StringSubstr(dt,8,2) + "T" + StringSubstr(dt,11);         
      
      if(LineBuffer[i]>LineBuffer[i+1]) {
         Print(dt + " -> Up");
         DrawArrowUp("Up"+i,time[i],high[i]+ATRvalue,Yellow); 
      }
      
      if(LineBuffer[i]<LineBuffer[i+1]) {
         Print(dt + " -> Down");
         DrawArrowDown("Down"+i,time[i],low[i]-ATRvalue,Red);
      }
   }
   
   return(rates_total);
}

void initBuffer(double &array[], string label = "", int type = DRAW_NONE, int arrow = 0, int style = EMPTY, int width = EMPTY) {
    ArraySetAsSeries(array,true); 
    SetIndexBuffer(buffers, array);
    SetIndexLabel(buffers, label);
    SetIndexEmptyValue(buffers, EMPTY_VALUE);
    SetIndexDrawBegin(buffers, drawBegin);
    SetIndexShift(buffers, 0);
    SetIndexStyle(buffers, type, style, width);
    SetIndexArrow(buffers, arrow);
    buffers++;
}

void DrawArrowUp(string ArrowName,double LineTime,double LinePrice,color LineColor)
{
   ObjectCreate(current_chart_id,ArrowName, OBJ_ARROW, 0, LineTime, LinePrice);
   ObjectSet(ArrowName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(ArrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
   ObjectSet(ArrowName, OBJPROP_COLOR, LineColor);
   ChartRedraw(current_chart_id); 
}

void DrawArrowDown(string ArrowName,double LineTime,double LinePrice,color LineColor)
{
   ObjectCreate(current_chart_id,ArrowName, OBJ_ARROW, 0, LineTime, LinePrice);
   ObjectSet(ArrowName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(ArrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
   ObjectSet(ArrowName, OBJPROP_COLOR, LineColor);
   ChartRedraw(current_chart_id); 
}