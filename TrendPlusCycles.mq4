//+------------------------------------------------------------------+
//|                                              TrendPlusCycles.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property description "CyclePeriod indicator - described by John F. Ehlers"
#property description "in \"Cybernetic Analysis for Stocks and Futures\""

#property indicator_buffers 1
#property indicator_plots 1
#property indicator_width1 1
#property indicator_type1   DRAW_LINE
#property indicator_color1  White
#property indicator_label1  "Smooth"

double Smooth[];

input double InpAlpha=0.07; // alpha

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   ArraySetAsSeries(Smooth,true);
   SetIndexBuffer(0,Smooth,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   return(0);   
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
   long tickCnt[1];
   int i;
   int ticks=CopyTickVolume(Symbol(), 0, 0, 1, tickCnt);
   if(ticks!=1) return(rates_total);
   double itrend,ccycle;

   Comment(tickCnt[0]);

   if(prev_calculated==0 || tickCnt[0]==1)
     {
      //--- last counted bar will be recounted
      int nLimit=rates_total-prev_calculated-1; // start index for calculations

      ArrayResize(Smooth,Bars(_Symbol,_Period));
      
      for(i=nLimit;i>=0 && !IsStopped();i--) 
      {
         itrend=iCustom(NULL,0,"InstantaneousTrendline",InpAlpha,0,i);
         ccycle=iCustom(NULL,0,"CyberCycle",InpAlpha,0,i);
         Smooth[i]=itrend+ccycle;
      }
     } 
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
