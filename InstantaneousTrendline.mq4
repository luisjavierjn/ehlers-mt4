//+------------------------------------------------------------------+
//|                                       InstantaneousTrendline.mq4 |
//|                                                                  |
//| Instantaneous Trendline                                          |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
#property copyright "Coded by Witold Wozniak"
#property link      "www.mqlsoft.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

#property indicator_level1 0

double ITrend[];
double Trigger[];

extern double Alpha = 0.07;
extern bool ShowTrigger = true;

int buffers = 0;
int drawBegin = 0;

int init() {
    drawBegin = 8;      
    initBuffer(ITrend, "Instantaneous Trendline", DRAW_LINE);
    if(ShowTrigger)
      initBuffer(Trigger, "Trigger", DRAW_LINE);
    else
      initBuffer(Trigger);      
    IndicatorBuffers(buffers);
    IndicatorShortName("Instantaneous Trendline [" + DoubleToStr(Alpha, 2) + "]");
    return (0);
}
  
int start() {
    if (Bars <= drawBegin)  return (0);
    int countedBars = IndicatorCounted();
    if (countedBars < 0) return (-1);
    if (countedBars > 0) countedBars--;
    int s, limit = Bars - countedBars - 1;  
    for (s = limit; s >= 0; s--) {
        ITrend[s] = (Alpha - Alpha * Alpha / 4.0) * P(s)
            + 0.5 * Alpha * Alpha * P(s + 1) 
            - (Alpha - 0.75 * Alpha * Alpha) * P(s + 2)
            + 2.0 * (1.0 - Alpha) * ITrend[s + 1]
            - (1.0 - Alpha) * (1.0 - Alpha) * ITrend[s + 2];
        if (s > Bars - 8) {
            ITrend[s] = (P(s) + 2.0 * P(s + 1) + P(s + 2)) / 4.0;
        }
        Trigger[s] = 2.0 * ITrend[s] - ITrend[s + 2];
    }
    return (0);
}

double P(int index) {
    return ((High[index] + Close[index] + Low[index]) / 3.0);
}

void initBuffer(double array[], string label = "", int type = DRAW_NONE, int arrow = 0, int style = EMPTY, int width = EMPTY, color clr = CLR_NONE) {
    SetIndexBuffer(buffers, array);
    SetIndexLabel(buffers, label);
    SetIndexEmptyValue(buffers, EMPTY_VALUE);
    SetIndexDrawBegin(buffers, drawBegin);
    SetIndexShift(buffers, 0);
    SetIndexStyle(buffers, type, style, width);
    SetIndexArrow(buffers, arrow);
    buffers++;
}