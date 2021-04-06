//+------------------------------------------------------------------+
//|                                                    Amplitude.mq4 |
//|                                     Copyright 2021, luisjavierjn |
//|                                               https://caudas.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#property description "Amplitude indicator - described by John F. Ehlers"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  Red
#property indicator_color2  Blue

double AmplitudeMA[];
double Frontier[];
double Amplitude[];

int cp = 0;
double q1 = 0;
double i1 = 0;
int n = 1;
int buffers = 0;
int drawBegin = 0;

input double InpAlpha=0.07; // alpha
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   IndicatorBuffers(3);
   initBuffer(AmplitudeMA, "AmplitudeMA", DRAW_LINE);
   initBuffer(Frontier, "Frontier", DRAW_LINE);
   initBuffer(Amplitude);

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
      cp=(int)iCustom(NULL,0,"CyclePeriod",InpAlpha,0,i);
      q1=iCustom(NULL,0,"CyclePeriod",InpAlpha,4,i);
      i1=iCustom(NULL,0,"CyclePeriod",InpAlpha,5,i);         
      int period=(rates_total-1-i)<cp ? (rates_total-1-i) : cp;
      int half_period=0.5*period;
      if(half_period==0) half_period++;      
      Amplitude[i]=MathSqrt(MathPow(q1,2)+MathPow(i1,2));
      AmplitudeMA[i]=(iMAOnArray(Amplitude,0,half_period,0,MODE_SMA,i)-iATR(NULL,0,half_period,i));
      Frontier[i]=Ask-Bid;
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
