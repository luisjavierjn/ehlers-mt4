//+------------------------------------------------------------------+
//|                                           TestChandelierExit.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

int n = 1;
int buffers = 0;
int drawBegin = 0;

double chandelierExitBelowCurrent;
double chandelierExitBelowPrevious;
double chandelierExitAboveCurrent;
double chandelierExitAbovePrevious;
double chandelierExitATR;
double chandelierExitCurrentDirection;
double chandelierExitPreviousDirection;

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
//---
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
      chandelierExitBelowCurrent = iCustom(NULL,0,"ChandelierExit",Range,Shift,InpAlpha,CycPart,ATRMultipl,0,i);
      chandelierExitBelowPrevious = iCustom(NULL,0,"ChandelierExit",Range,Shift,InpAlpha,CycPart,ATRMultipl,0,i+1);
      
      chandelierExitAboveCurrent = iCustom(NULL,0,"ChandelierExit",Range,Shift,InpAlpha,CycPart,ATRMultipl,1,i);
      chandelierExitAbovePrevious = iCustom(NULL,0,"ChandelierExit",Range,Shift,InpAlpha,CycPart,ATRMultipl,1,i+1);
      
      chandelierExitATR = iCustom(NULL,0,"ChandelierExit",Range,Shift,InpAlpha,CycPart,ATRMultipl,5,i);
      double space = chandelierExitATR / 2;
      
      double previousDirection = chandelierExitPreviousDirection;
      chandelierExitPreviousDirection = iCustom(NULL,0,"ChandelierExit",Range,Shift,InpAlpha,CycPart,ATRMultipl,4,i+1);
      chandelierExitCurrentDirection = iCustom(NULL,0,"ChandelierExit",Range,Shift,InpAlpha,CycPart,ATRMultipl,4,i);

      // ENTRY AND EXIT LONG      
      if(chandelierExitCurrentDirection > chandelierExitPreviousDirection &&
         chandelierExitAboveCurrent == EMPTY_VALUE) {
         DrawArrowUp("Up"+i,time[i],high[i]+space,Yellow);
      }

      // ENTRY AND EXIT SHORT      
      if(chandelierExitCurrentDirection < chandelierExitPreviousDirection &&
         chandelierExitBelowCurrent == EMPTY_VALUE) {
         DrawArrowDown("Down"+i,time[i],low[i]-space,Red);
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
   ObjectCreate(ArrowName, OBJ_ARROW, 0, LineTime, LinePrice);
   ObjectSet(ArrowName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(ArrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
   ObjectSet(ArrowName, OBJPROP_COLOR, LineColor);
   ChartRedraw(0); // 0 is current chart
}

void DrawArrowDown(string ArrowName,double LineTime,double LinePrice,color LineColor)
{
   ObjectCreate(ArrowName, OBJ_ARROW, 0, LineTime, LinePrice);
   ObjectSet(ArrowName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(ArrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
   ObjectSet(ArrowName, OBJPROP_COLOR, LineColor);
   ChartRedraw(0); // 0 is current chart 
}