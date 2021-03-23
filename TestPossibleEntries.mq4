//+------------------------------------------------------------------+
//|                                          TestPossibleEntries.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

//--- indicator buffers 
double ITrendToDaily[];
double TVigor[];
double ChandelierExitBelow[];
double ChandelierExitAbove[];
double chandelierExitDirection[];
double Cycle[];
double Trigger[];

//--- decision variables
double cycle_ant;
double cycle_act;
double vigor_ant;
double vigor_act;

//--- variables
int currentbar = 0;
int n = 1;
int buffers = 0;
int drawBegin = 0;
long current_chart_id;
double value = 0;

//--- input parameters 
input int Range = 6;
input int Shift = 0;
input double InpAlpha = 0.07;
input double CycPart = 0.5;
input double ATRMultipl = 3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   IndicatorBuffers(7);
   initBuffer(ITrendToDaily);
   initBuffer(TVigor);
   initBuffer(ChandelierExitBelow);  
   initBuffer(ChandelierExitAbove);
   initBuffer(chandelierExitDirection);
   initBuffer(Cycle);
   initBuffer(Trigger);    
//---
   current_chart_id=ChartID();
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
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
      ITrendToDaily[i] = iCustom(NULL,PERIOD_D1,"ITrendToDaily",InpAlpha,0,iBarShift(NULL,PERIOD_D1,time[i]));
      TVigor[i] = iCustom(NULL,0,"TrendVigor",InpAlpha,0,i);
      ChandelierExitBelow[i] = iCustom(NULL,0,"ChandelierExit",Range,Shift,InpAlpha,CycPart,ATRMultipl,0,i);
      ChandelierExitAbove[i] = iCustom(NULL,0,"ChandelierExit",Range,Shift,InpAlpha,CycPart,ATRMultipl,1,i);
      chandelierExitDirection[i] = iCustom(NULL,0,"ChandelierExit",Range,Shift,InpAlpha,CycPart,ATRMultipl,4,i);
      Cycle[i] = iCustom(NULL,0,"CyberCycle",InpAlpha,0,i);
      Trigger[i] = iCustom(NULL,0,"CyberCycle",InpAlpha,1,i);      

      if(currentbar++<1) continue;
      
      cycle_ant = cycle_act;
      if(Cycle[i]>Trigger[i] && Cycle[i+1]<Trigger[i+1]) cycle_act = 1;
      if(Cycle[i]<Trigger[i] && Cycle[i+1]>Trigger[i+1]) cycle_act = -1;
      
      //vigor_ant = vigor_act;
      //if(TVigor[i]>1 && TVigor[i+1]<1) vigor_act = 1;
      //if(TVigor[i]<-1 && TVigor[i+1]>-1) vigor_act = -1;

      /*      
      if(chandelierExitDirection[i]>chandelierExitDirection[i+1]) value = DBL_MIN;
      if(chandelierExitDirection[i]<chandelierExitDirection[i+1]) value = DBL_MAX;

      if(
         (ITrendToDaily[i]>0 && TVigor[i]>-1 && ChandelierExitBelow[i]!=EMPTY_VALUE && cycle_act>cycle_ant) ||
         (chandelierExitDirection[i]>chandelierExitDirection[i+1])
         ) { // bullish
         if(ChandelierExitBelow[i]>value) {
            DrawArrowUp("Up"+IntegerToString(i),time[i],high[i]+iATR(NULL,0,14,i),Yellow);
            value = close[i];
         }
      }
      
      if(
         (ITrendToDaily[i]<0 && TVigor[i]<1 && ChandelierExitAbove[i]!=EMPTY_VALUE && cycle_act<cycle_ant) ||
         (chandelierExitDirection[i]<chandelierExitDirection[i+1])
         ) { // bearish
         if(ChandelierExitAbove[i]<value) {
            DrawArrowDown("Down"+IntegerToString(i),time[i],low[i]-iATR(NULL,0,14,i),Red);
            value = close[i];
         }
      }
      */
      
      if(value<=0 && TVigor[i]>-1 && ChandelierExitBelow[i]!=EMPTY_VALUE && cycle_act>cycle_ant) {
         DrawArrowUp("Up"+IntegerToString(i),time[i],high[i]+iATR(NULL,0,14,i),Yellow);
         value = 1;
      }
      
      if(value>=0 && TVigor[i]<1 && ChandelierExitAbove[i]!=EMPTY_VALUE && cycle_act<cycle_ant) {
         DrawArrowDown("Down"+IntegerToString(i),time[i],low[i]-iATR(NULL,0,14,i),Red);
         value = -1;
      }
   }   
      
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+

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
   ObjectCreate(current_chart_id,ArrowName, OBJ_ARROW, 0, (long)LineTime, LinePrice);
   ObjectSet(ArrowName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(ArrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
   ObjectSet(ArrowName, OBJPROP_COLOR, LineColor);
   ChartRedraw(current_chart_id); 
}

void DrawArrowDown(string ArrowName,double LineTime,double LinePrice,color LineColor)
{
   ObjectCreate(ArrowName, OBJ_ARROW, 0, (long)LineTime, LinePrice);
   ObjectSet(ArrowName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(ArrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
   ObjectSet(ArrowName, OBJPROP_COLOR, LineColor);
   ChartRedraw(current_chart_id); 
}