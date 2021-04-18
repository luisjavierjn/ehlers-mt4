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
double TrendVigor[];
double BandsSpread[];
double BandsTrigger[];
double CyberCycle[];
double CyberTrigger[];

//--- decision variables
double vigor_ant;
double vigor_act;
double bands_ant;
double bands_act;
double cyber_ant;
double cyber_act;
double vflag_act;
double bflag_act;

//--- variables
int buffers = 0;
int drawBegin = 0;
long current_chart_id;

//--- input parameters 
input double InpAlpha = 0.07;
input int CPeriod = 62;
input int Range = 6;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   IndicatorBuffers(5);
   initBuffer(TrendVigor);
   initBuffer(BandsSpread);
   initBuffer(BandsTrigger);
   initBuffer(CyberCycle);
   initBuffer(CyberTrigger);
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
   int n = Range + 1;
   double UpperBand, LowerBand;   
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
      TrendVigor[i] = iCustom(NULL,0,"TrendVigor",InpAlpha,0,i);
      UpperBand = iBands(NULL,0,CPeriod,2,0,PRICE_TYPICAL,MODE_UPPER,i);
      LowerBand = iBands(NULL,0,CPeriod,2,0,PRICE_TYPICAL,MODE_LOWER,i);
      BandsSpread[i] = (UpperBand-LowerBand);
      BandsTrigger[i] = BandsSpread[i + Range];
      CyberCycle[i]=iCustom(NULL,0,"CyberCycle",InpAlpha,0,i);
      CyberTrigger[i]=iCustom(NULL,0,"CyberCycle",InpAlpha,1,i);      
      
      vigor_ant = vigor_act;
      if(TrendVigor[i]>1) vigor_act = 1;
      else if(TrendVigor[i]<-1) vigor_act = -1;
      else vigor_act = 0;
      
      bands_ant = bands_act;
      if(BandsSpread[i]>BandsTrigger[i]) bands_act = 1;
      if(BandsSpread[i]<BandsTrigger[i]) bands_act = -1;
      
      cyber_ant = cyber_act;
      if(CyberCycle[i]>CyberTrigger[i]) cyber_act = 1;
      if(CyberCycle[i]<CyberTrigger[i]) cyber_act = -1;
      
      if(vigor_act!=0) vflag_act = vigor_act;
      if(bands_act<bands_ant) bflag_act = -1;
      
      if(vflag_act<0 && bflag_act<0 && cyber_act>cyber_ant) {
         DrawArrowUp("Up"+IntegerToString(i),time[i],high[i]+iATR(NULL,0,14,i),Yellow);
         bflag_act++;
      }
      
      if(vflag_act>0 && bflag_act<0 && cyber_act<cyber_ant) {
         DrawArrowDown("Down"+IntegerToString(i),time[i],low[i]-iATR(NULL,0,14,i),Red);
         bflag_act++;
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
   ObjectCreate(current_chart_id,ArrowName, OBJ_ARROW, 0, (long)LineTime, LinePrice);
   ObjectSet(ArrowName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(ArrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
   ObjectSet(ArrowName, OBJPROP_COLOR, LineColor);
   ChartRedraw(current_chart_id); 
}