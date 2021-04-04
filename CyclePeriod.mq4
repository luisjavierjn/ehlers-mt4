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
#property indicator_buffers 2
#property indicator_color1  Green
#property indicator_color2  Red

#define Price(k) ((high[k]+close[k]+low[k])/3.0)

double Smooth[];
double Cycle[];
double Trigger[];
double Q1[]; // Quadrature component
double I1[]; // InPhase component
double DeltaPhase[];
double InstPeriod[];
double CyclePeriod[];

int currentbar = 0;
int n = 4;
int buffers = 0;
int drawBegin = 0;

input double InpAlpha=0.07; // alpha
input bool ShowTrigger = true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping 
   IndicatorBuffers(8);
   initBuffer(CyclePeriod, "CyclePeriod", DRAW_LINE);
   if(ShowTrigger)
      initBuffer(Trigger, "Trigger", DRAW_LINE);
   else
      initBuffer(Trigger);
   initBuffer(Smooth);
   initBuffer(Cycle);
   initBuffer(Q1);
   initBuffer(I1);
   initBuffer(DeltaPhase);
   initBuffer(InstPeriod);   

//--- return value
   return(0);
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
   double DC, MedianDelta;
   //--- last counted bar will be recounted
   int limit=rates_total-prev_calculated; // start index for calculations   
   if(prev_calculated>0) limit++;
   
   if(limit>rates_total-n) // adjust for last bars
      limit=rates_total-n;
   else limit--;        

   if(limit>=0) {
      ArraySetAsSeries(high,true);
      ArraySetAsSeries(close,true);
      ArraySetAsSeries(low,true);
   }
   
   for(int i=limit;i>=0;i--) {
      Smooth[i]=(Price(i)+2*Price(i+1)+2*Price(i+2)+Price(i+3))/6.0;

      Cycle[i]=(1.0-0.5*InpAlpha)*(1.0-0.5*InpAlpha)*(Smooth[i]-2.0*Smooth[i+1]+Smooth[i+2])
               +2.0*(1.0-InpAlpha)*Cycle[i+1]-(1.0-InpAlpha)*(1.0-InpAlpha)*Cycle[i+2];

      if(++currentbar<7) {
         Cycle[i]=(Price(i)-2.0*Price(i+1)+Price(i+2))/4.0;
         continue;
      }
         
      Q1[i] = (0.0962*Cycle[i]+0.5769*Cycle[i+2]-0.5769*Cycle[i+4]-0.0962*Cycle[i+6])*(0.5+0.08*InstPeriod[i+1]);
      I1[i] = Cycle[i+3];

      if (Q1[i]!=0.0 && Q1[i+1]!=0.0) 
         DeltaPhase[i] = (I1[i]/Q1[i]-I1[i+1]/Q1[i+1])/(1.0+I1[i]*I1[i+1]/(Q1[i]*Q1[i+1]));
      if (DeltaPhase[i] < 0.1)
         DeltaPhase[i] = 0.1;
      if (DeltaPhase[i] > 0.9)
         DeltaPhase[i] = 0.9;
     
      MedianDelta = median(DeltaPhase, i, 5);
      
      if (MedianDelta == 0.0)
         DC = 15.0;
      else
         DC = (6.28318/MedianDelta) + 0.5;
     
      InstPeriod[i] = 0.33 * DC + 0.67 * InstPeriod[i+1];
      CyclePeriod[i] = 0.15 * InstPeriod[i] + 0.85 * CyclePeriod[i+1];
      Trigger[i] = CyclePeriod[i+1];
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

double median(double& arr[], int idx, int m_len) {
   double MedianArr[];
   int copied;
   double result = 0.0;
   
   ArraySetAsSeries(MedianArr, true);
   ArrayResize(MedianArr, m_len);
   
   copied = ArrayCopy(MedianArr, arr, 0, idx, m_len);
   if (copied == m_len) {
      ArraySort(MedianArr);
      if (m_len %2 == 0) 
         result = (MedianArr[m_len/2] + MedianArr[(m_len/2)+1])/2.0;
      else
         result = MedianArr[m_len / 2];      
   }
   else Print(__FILE__+__FUNCTION__+"median error - wrong number of elements copied."); 
   return result; 
}