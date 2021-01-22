//+------------------------------------------------------------------+
//|                                                   CyberCycle.mq4 |
//|                                     Copyright 2021, luisjavierjn |
//|                                               https://caudas.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, luisjavierjn"
#property link      "https://caudas.com"
#property version   "1.00"

#property description "CyberCycle indicator - described by John F. Ehlers"
#property description "in \"Cybernetic Analysis for Stocks and Futures\""

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  Green
#property indicator_color2  Red

#define Price(k) ((high[k]+close[k]+low[k])/3.0)

double Smooth[];
double Cycle[];
double Trigger[];

int currentbar = 0;
int n = 4;
int buffers = 0;
int drawBegin = 8;

input double InpAlpha=0.07; // alpha
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping 
   initBuffer(Cycle, "Cycle", DRAW_LINE);
   initBuffer(Trigger, "Trigger", DRAW_LINE);
   initBuffer(Smooth);

//--- return value
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------
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
   int limit=rates_total-prev_calculated-1; // start index for calculations
   
   if(limit>rates_total-n) // adjust for last bars
      limit=rates_total-n;         

   if(limit>=0) {
      ArraySetAsSeries(high,true);
      ArraySetAsSeries(close,true);
      ArraySetAsSeries(low,true);
   
      ArrayResize(Cycle,Bars(_Symbol,_Period));
      ArrayResize(Trigger,Bars(_Symbol,_Period));
      ArrayResize(Smooth,Bars(_Symbol,_Period));   
   }
   
   for(int i=limit;i>=0;i--) {
      Smooth[i]=(Price(i)+2*Price(i+1)+2*Price(i+2)+Price(i+3))/6.0;

      Cycle[i]=(1.0-0.5*InpAlpha)*(1.0-0.5*InpAlpha)*(Smooth[i]-2.0*Smooth[i+1]+Smooth[i+2])
               +2.0*(1.0-InpAlpha)*Cycle[i+1]-(1.0-InpAlpha)*(1.0-InpAlpha)*Cycle[i+2];

      if(++currentbar<7)
         Cycle[i]=(Price(i)-2.0*Price(i+1)+Price(i+2))/4.0;

      Trigger[i]=Cycle[i+1];
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