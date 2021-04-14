//+------------------------------------------------------------------+
//|                                                ITrendToDaily.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1 
#property indicator_color1  Yellow
#property indicator_minimum -1.5
#property indicator_maximum 1.5

int currentbar = 0;
int n = 0;
int buffers = 0;
int drawBegin = 0;

input double InpAlpha=0.07; // alpha

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
   double ITrend, ITrigger, CCycle, CTrigger;
   //--- last counted bar will be recounted
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
      int j = iBarShift(NULL,PERIOD_D1,time[i]);
      
      ITrend=iCustom(NULL,PERIOD_D1,"InstantaneousTrendline",InpAlpha,0,j);
      ITrigger=iCustom(NULL,PERIOD_D1,"InstantaneousTrendline",InpAlpha,1,j);
      
      CCycle=iCustom(NULL,PERIOD_D1,"CyberCycle",InpAlpha,0,j);
      CTrigger=iCustom(NULL,PERIOD_D1,"CyberCycle",InpAlpha,1,j);      
      
      if(currentbar++<1) continue;

      LineBuffer[i]=LineBuffer[i+1];
      
      if(ITrigger>ITrend) {
         if(CCycle>CTrigger)
            LineBuffer[i]=1;
         else
            LineBuffer[i]=-0.5;
      }
      
      if(ITrigger<ITrend) {
         if(CCycle<CTrigger)
            LineBuffer[i]=-1;
         else
            LineBuffer[i]=0.5;
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
