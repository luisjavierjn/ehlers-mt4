//+------------------------------------------------------------------+
//|                                         BollingerBandsSpread.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Luis Jiménez, 2021."
#property link        "https://www.mql5.com"
#property version     "1.00"
#property description "UpperBand minus LowerBand"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  Green
#property indicator_color2  Red

double Spread[];
double Trigger[];

int buffers = 0;
int drawBegin = 0;

input double CPeriod = 62; // Period
input int Range = 6;
input bool ShowTrigger = true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(2);
   initBuffer(Spread, "Spread", DRAW_LINE);
   if(ShowTrigger)
      initBuffer(Trigger, "Trigger", DRAW_LINE);
   else
      initBuffer(Trigger);
         
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
   double n = Range + 1;
   double UpperBand, LowerBand;   
   //--- last counted bar will be recounted
   int limit=rates_total-prev_calculated; // start index for calculations
   if(prev_calculated>0) limit++;
   
   if(limit>rates_total-n) // adjust for last bars
      limit=rates_total-n;
   else limit--;
   
   for(int i=limit;i>=0;i--) {      
      UpperBand = iBands(NULL,0,CPeriod,2,0,PRICE_TYPICAL,MODE_UPPER,i);
      LowerBand = iBands(NULL,0,CPeriod,2,0,PRICE_TYPICAL,MODE_LOWER,i);
      Spread[i] = (UpperBand-LowerBand);
      Trigger[i] = Spread[i + Range];
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