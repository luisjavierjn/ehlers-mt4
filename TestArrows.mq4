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
#property indicator_buffers 1 
#property indicator_color1  Yellow

int n = 0;
int buffers = 0;
int drawBegin = 0;
long current_chart_id;

//--- indicator buffers 
double LineBuffer[]; 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit() 
{ 
//--- indicator buffers mapping 
   IndicatorBuffers(1);
   initBuffer(LineBuffer, "Line", DRAW_LINE);
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
   
   //for(int i=limit;i>=0;i--) {
         
      /*if(close[i]>open[i]) {
         LineBuffer[i]=high[i];
      }      
      else if(close[i]<open[i]) {
         LineBuffer[i]=low[i];
      }
      else {
         LineBuffer[i]=close[i];
      }*/
   //}

   //if(prev_calculated == 0) {   
   for(int i=limit;i>=0;i--) {
      double ATRvalue=iATR(NULL,0,14,i)*3; 
      
      double space = ATRvalue * 0.33;
      if(close[i]>open[i]) {
         DrawArrowUp("Up"+i,time[i],high[i]+space,Yellow);      
      }
      
      if(close[i]<open[i]) {
         DrawArrowDown("Down"+i,time[i],low[i]-space,Red);
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
   ObjectCreate(ArrowName, OBJ_ARROW, 0, LineTime, LinePrice);
   ObjectSet(ArrowName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(ArrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
   ObjectSet(ArrowName, OBJPROP_COLOR, LineColor);
   ChartRedraw(current_chart_id); 
}