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

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  Red
#property indicator_color2  Yellow
#property indicator_color3  Yellow

double TVigor[];
double Sup[];
double Inf[];

int period = 0;
double q1 = 0;
double i1 = 0;
int currentbar = 0;
int n = 70;
int buffers = 0;
int drawBegin = 0;

input double InpAlpha=0.07; // alpha

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping 
   initBuffer(TVigor, "TrendVigor", DRAW_LINE);
   initBuffer(Sup, "Sup", DRAW_LINE);
   initBuffer(Inf, "Inf", DRAW_LINE);

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
   double Amplitude, Slope, PriceA, PriceB;
   //--- last counted bar will be recounted
   int limit=rates_total-prev_calculated-1; // start index for calculations
   
   if(limit>rates_total-n) // adjust for last bars
      limit=rates_total-n;   
   
   if(limit>=0)
      ArraySetAsSeries(close,true);
   
   for(int i=limit;i>=0;i--) {
      if(++currentbar<70) continue;
   
      period=(int)iCustom(NULL,0,"Cycle_Period",InpAlpha,0,i);
      q1=iCustom(NULL,0,"Cycle_Period",InpAlpha,4,i);
      i1=iCustom(NULL,0,"Cycle_Period",InpAlpha,5,i);
      
      Amplitude = MathSqrt(MathPow(q1,2)+MathPow(i1,2));
      PriceA=iCustom(NULL,0,"InstantaneousTrendline",InpAlpha,0,i);
      PriceB=iCustom(NULL,0,"InstantaneousTrendline",InpAlpha,0,i+period);
      Slope = PriceA-PriceB;
      
      TVigor[i]=MathMax(MathMin(Slope/Amplitude,2),-2);
      Sup[i]=1; Inf[i]=-1;
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