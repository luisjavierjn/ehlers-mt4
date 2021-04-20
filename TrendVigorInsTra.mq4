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
#property indicator_buffers 5
#property indicator_color1  Red
#property indicator_color2  Yellow
#property indicator_color3  Yellow

double TVigor[];
double Sup[];
double Inf[];
double Ampl[];
double AmplMA[];

int cp = 0;
int n = 62;
int buffers = 0;
int drawBegin = 0;

extern double InpAlpha=0.07; // alpha

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   IndicatorBuffers(5);
   initBuffer(TVigor, "TrendVigor", DRAW_LINE);
   initBuffer(Sup, "Sup", DRAW_LINE);
   initBuffer(Inf, "Inf", DRAW_LINE);
   initBuffer(Ampl);
   initBuffer(AmplMA);

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
   double Slope, CPeriod, PriceA, PriceB, IPriceA, IPriceB;
   //--- last counted bar will be recounted
   int limit=rates_total-prev_calculated; // start index for calculations
   if(prev_calculated>0) limit++;
   
   if(limit>rates_total-n) // adjust for last bars
      limit=rates_total-n;
   else limit--;     
   
   for(int i=limit-1;i>=0;i--) {
      cp=(int)iCustom(NULL,0,"CyclePeriod",InpAlpha,0,i);
      PriceA=iMA(NULL,0,62,0,MODE_SMA,PRICE_TYPICAL,i);
      IPriceA=iCustom(NULL,0,"InstantaneousTrendline",InpAlpha,0,i);
      CPeriod=(rates_total-1-i)<cp ? (rates_total-1-i) : cp;
      PriceB=iMA(NULL,0,62,0,MODE_SMA,PRICE_TYPICAL,i+CPeriod);
      IPriceB=iCustom(NULL,0,"InstantaneousTrendline",InpAlpha,0,i+CPeriod);
      Ampl[i]=MathAbs(IPriceA-IPriceB);
      AmplMA[i]=iMAOnArray(Ampl,0,CPeriod,0,MODE_SMA,i);
      Slope = PriceA-PriceB;
      
      TVigor[i]=MathMax(MathMin(Slope/AmplMA[i],2),-2);
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