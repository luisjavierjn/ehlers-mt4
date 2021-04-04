//+------------------------------------------------------------------+
//|                                              TrendPlusCycles.mq4 |
//|                                     Copyright 2021, luisjavierjn |
//|                                               https://caudas.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#property description "CyclePeriod indicator - described by John F. Ehlers"
#property description "in \"Cybernetic Analysis for Stocks and Futures\""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  Yellow
#property indicator_color2  Blue

double Smooth[];
double ITrend[];

double itrend = 0;
double ccycle = 0;
int buffers = 0;
int drawBegin = 0;

input double InpAlpha=0.07; // alpha
input bool ShowITrend = true;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping 
   IndicatorBuffers(2);
   initBuffer(Smooth, "Smooth", DRAW_LINE);
   if(ShowITrend)
      initBuffer(ITrend, "ITrend", DRAW_LINE);   
   else
      initBuffer(ITrend);   

//--- return value
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
                const int &spread[]) {
//---
   //--- last counted bar will be recounted
   int limit=rates_total-prev_calculated; // start index for calculations
   if(prev_calculated>0) limit++;
   
   for(int i=limit-1;i>=0;i--) {
      itrend=iCustom(NULL,0,"InstantaneousTrendline",InpAlpha,0,i);
      ccycle=iCustom(NULL,0,"CyberCycle",InpAlpha,0,i);
      Smooth[i]=itrend+ccycle;
      ITrend[i]=itrend;
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