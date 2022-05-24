double monday_high, monday_low;
double tuesday_high, tuesday_low;
double wednesday_high, wednesday_low;
double thursday_high, thursday_low;
double friday_high, friday_low;
int current_day_of_week;
bool pinbar_detect;
int bullish_pinbar_amount;
int bearish_pinbar_amount;
int doji_pinbar_amount;
int bar;
double ma20;
double ma100;
int ma_period = PERIOD_H1;
int move_sl_range = 2 *1000 * Point;
int max_sl = 5 * 1000 * Point;
double today_order_1;
double today_order_2;
int h1_bar;
int today_order;
int d1_bar;
int total_order_per_day = 5;
int total_order_pay_hour = 20;


int OnInit()
  {
   ObjectsDeleteAll();
   pinbar_detect = false;
   current_day_of_week = DayOfWeek();
   bullish_pinbar_amount = 0;
   bearish_pinbar_amount = 0;
   bar = Bars;
   d1_bar = iBars(Symbol(), PERIOD_D1);
   h1_bar = iBars(Symbol(), PERIOD_H1);
   
   
   
   return(INIT_SUCCEEDED);
  }
  
void OnTick()
{
   //check d1 change
   if(iBars(Symbol(), PERIOD_D1) > d1_bar){
      //today_order = 0;
      
      //d1_bar++;
   }
   
   //check an hour change
   if(iBars(Symbol(), PERIOD_H1) > h1_bar){
      today_order = 0; //reset order count per hour
      draw_hline(); //draw new vline for new hour
      
      h1_bar++; //increase bar count
   }
      
   //current timeframe change // maybe 5 minute chart
   if(Bars>bar){
      //update price panel
      show_panel();
      
      //check open order
      if(OrdersTotal()){
         //loop select all order
         for(int i=0; i<OrdersTotal(); i++){
            //select each order by their index
            int select = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
            
            //calculate half tp
            double tp_range = OrderTakeProfit() - OrderOpenPrice();
            double half_tp = tp_range / 2;
            
            //check if bid price more than each order open price
            if(Bid > OrderOpenPrice() + move_sl_range){
               //move sl to the same with order open price
               int modify = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, clrYellow); 
            }
            
         }
      }
      
      //check for buy 
      //pinbar entry area ***
      if(isPinbar(1) != "not_pinbar" && isPinbar(1) != "not_qaulify_pinbar"){
         
         //get pinbar type
         string pinbar_type = isPinbar(1);
         
         //some use variable
         string candle_type = "";
         
         //previous week
         double previous_week_open = iOpen(Symbol(), PERIOD_W1, 1);
         double previous_week_high = iHigh(Symbol(), PERIOD_W1, 1);
         double previous_week_low = iLow(Symbol(), PERIOD_W1, 1);
         double previous_week_close = iClose(Symbol(), PERIOD_W1, 1);
         
         //yesterday
         double yesterday_open = iOpen(Symbol(), PERIOD_D1, 1);
         double yesterday_high = iHigh(Symbol(), PERIOD_D1, 1);
         double yesterday_low = iLow(Symbol(), PERIOD_D1, 1);
         double yesterday_close = iClose(Symbol(), PERIOD_D1, 1);
         double yesterday_up_wick;
         double yesterday_low_wick;
         double yesterday_body;
         double half_day;
         
         //previous_hour
         double previous_hour_open = iOpen(Symbol(), PERIOD_H1, 1);
         double previous_hour_high = iHigh(Symbol(), PERIOD_H1, 1);
         double previous_hour_low = iLow(Symbol(), PERIOD_H1, 1);
         double previous_hour_close = iClose(Symbol(), PERIOD_H1, 1);
         double previous_hour_body;
         double previous_hour_up_wick;
         double previous_hour_low_wick;
         double previous_hour_half_body_price;
         
         //calculate body size
         if(previous_hour_close > previous_hour_open){
            //set candle type
            candle_type = "bullish";
            
            //set body size
            previous_hour_body = previous_hour_close - previous_hour_open;
            
            //use this for half candle body
            previous_hour_half_body_price = previous_hour_close - (previous_hour_body/2);
            
            //set up wick size
            previous_hour_up_wick = previous_hour_high - previous_hour_close;
         }
         
         //current hour candle
         double hour_open = iOpen(Symbol(), PERIOD_H1, 0);
         double hour_high = iHigh(Symbol(), PERIOD_H1, 0);
         double hour_low = iLow(Symbol(), PERIOD_H1, 0);
         double hour_close = iClose(Symbol(), PERIOD_H1, 0);
         
         //bullish
         if(yesterday_close > yesterday_open){
            yesterday_up_wick = yesterday_high - yesterday_close;
            yesterday_body = yesterday_close - yesterday_open;
            yesterday_low_wick = yesterday_open - yesterday_low;
            half_day = yesterday_close - (yesterday_body / 2);
         }
         
         //bearish
         if(yesterday_close < yesterday_open){
            yesterday_up_wick = yesterday_high - yesterday_open;
            yesterday_body = yesterday_open - yesterday_close;
            yesterday_low_wick = yesterday_close - yesterday_low;
         }
         
         
         
         //calculate profit
         double tp;
         double ok_tp = 10000 * Point;
         
         if(DayOfWeek() == 1){
            tp = iHigh(Symbol(), PERIOD_D1, 2) - 1000 * Point;
         }
         
         if(DayOfWeek() != 1 && DayOfWeek() != 6){
            tp = iHigh(Symbol(), PERIOD_D1, 1) - 1000 * Point;
         }
         
         double enter_price = Ask;
         double profit = tp - enter_price;
         
         //test
         /*if(previous_week_close > previous_week_open){
            //bullish week
            tp = previous_week_high;
         }
         
         if(previous_week_close < previous_week_open){
            //bullish week
            tp = previous_week_open;
         }*/
         
         //calculate lose
         double sl = Low[1] - 500 * Point;
         double loss = enter_price - sl;
         tp = Ask + NormalizeDouble(loss*2, 3);
         
         //check before open order //1h chart
         if(isLower(1,5)){
            if(today_order < total_order_per_day){
               if(loss < max_sl){
                  //buy(sl, Ask + NormalizeDouble(loss*2, 3));
               }
            }
         }
         
         //check before open 5 minute chart
         if(isLower(1, 5)){
            if(today_order < total_order_pay_hour){
               if(loss < max_sl){
                  if(pinbar_type == "bullish_pinbar" && candle_type == "bullish"){
                     if(Close[1] > previous_hour_half_body_price){
                        if(previous_hour_body > previous_hour_up_wick * 2){
                           buy(sl, 0);
                        }
                     }
                  }
               }
            }
         }
          
         //check profit vs loss
         if(loss < max_sl){
            if(1){
               if(1){
                  if(today_order < total_order_per_day){
                     if(isLower(1, 5)){
                        //monday
                        if(DayOfWeek() == 1){
                           //check ask price above high price of previous many day
                           if(Ask > friday_high || Ask > thursday_high || Ask > wednesday_high || Ask > tuesday_high){
                              if(Low[1] < friday_high || Low[1] <  thursday_high || Low[1] <  wednesday_high || Low[1] <  tuesday_high){
                                 //buy(sl, 0);
                              }
                           }
                        }
                        
                        //tuesday
                        if(DayOfWeek() == 2){
                           if(Ask > friday_high || Ask > thursday_high || Ask > wednesday_high || Ask > monday_high){
                              if(Low[1] < friday_high || Low[1] < thursday_high || Low[1] < wednesday_high || Low[1] < monday_high){
                                 //buy(sl, 0);
                              }
                           }
                        }
                        
                        //wednesday
                        if(DayOfWeek() == 3){
                           if(Ask > friday_high || Ask > thursday_high || Ask > monday_high || Ask > tuesday_high){
                              if(Low[1] < friday_high || Low[1] < thursday_high || Low[1] < monday_high || Low[1] < tuesday_high){
                                 //buy(sl, 0);
                              }
                           }
                        }
                        
                        //thursday
                        if(DayOfWeek() == 4){
                           if(Ask > friday_high || Ask > monday_high || Ask > wednesday_high || Ask > tuesday_high){
                              if(Low[1] < friday_high || Low[1] < monday_high || Low[1] < wednesday_high || Low[1] < tuesday_high){
                                 //buy(sl, 0);
                              }
                           }
                        }
                        
                        //friday
                        if(DayOfWeek() == 5){
                           if(Ask > monday_high || Ask > thursday_high || Ask > wednesday_high || Ask > tuesday_high){
                              if(Low[1] < monday_high || Low[1] < thursday_high || Low[1] < wednesday_high || Low[1] < tuesday_high){
                                 //buy(sl, 0);
                              }
                           }
                        }
                     }
                  }
               }
            }
         } 
    }
      
      //check for sell
       
      
      //increase bar count
      bar++;
   }
   
   //this is just check the day change
   if(DayOfWeek()!=current_day_of_week){
      
      //set day of week
      current_day_of_week = DayOfWeek();

      //reset all day high low except friday beacuase we need to use friday to compare with monday   
      /*monday_high = 0;
      monday_low = 0;
      tuesday_high = 0;
      tuesday_low = 0;
      wednesday_high = 0;
      wednesday_low = 0;
      thursday_high = 0;
      thursday_low = 0;*/

      //monday
      if(current_day_of_week == 1){
         //set friday
         friday_high = iHigh(Symbol(), PERIOD_D1, 2);
         friday_low = iLow(Symbol(), PERIOD_D1, 2);
      }
      
      //tuesday
      if(current_day_of_week == 2){
        //set monday
         monday_high = iHigh(Symbol(), PERIOD_D1, 1);
         monday_low = iLow(Symbol(), PERIOD_D1, 1);
      }
      
      //wednesday
      if(current_day_of_week == 3){
        //set tuesday
         tuesday_high = iHigh(Symbol(), PERIOD_D1, 1);
         tuesday_low = iLow(Symbol(), PERIOD_D1, 1);
      }
      
      //thursday
      if(current_day_of_week == 4){
        //set wednesday
         wednesday_high = iHigh(Symbol(), PERIOD_D1, 1);
         wednesday_low = iLow(Symbol(), PERIOD_D1, 1);
      }
      
      //friday
      if(current_day_of_week == 5){
        //set thursday
         thursday_high = iHigh(Symbol(), PERIOD_D1, 1);
         thursday_low = iLow(Symbol(), PERIOD_D1, 1);
      }
      
      //update panel price detail
      show_panel();
   }
   
      
}

string isPinbar(int candle){
   //set specific candle open, high, low, close price
   double open = Open[candle];
   double high = High[candle];
   double low = Low[candle];
   double close = Close[candle];
   
   double up_wick;
   double body;
   double low_wick;
   
   double ok_low_wick = 1000 * Point;
   
   //bullish
   if(open<close){
      //calculate candle up wick, body, and low wick
      up_wick = high - close;
      body = close - open;
      low_wick = open - low;
      
      //check wick length qaulify
      if(low_wick < ok_low_wick){
         return "not_qaulify_pinbar";
      }
      
      //check if it is a qaulify pinbar
      if(low_wick > body && low_wick > up_wick * 2){
         bullish_pinbar_amount++;
         return "bullish_pinbar";
      }
   }
   
   //bearish
   if(open>close){
      //calculate candle up wick, body, and low wick
      up_wick = high - open;
      body = open - close;
      low_wick = close - low;
      
      //check wick length qaulify
      if(low_wick < ok_low_wick){
         return "not_qaulify_pinbar";
      }
      
      //check if it is a qaulify pinbar
      if(low_wick > body && low_wick > up_wick * 2){
         bearish_pinbar_amount++;
         return "bearish_pinbar";
      }
   }
   
   //doji
   if(open == close){
      //calculate candle up wick, and low wick
      up_wick = high - open;
      low_wick = close - low;
      
      //check wick length qaulify
      if(low_wick < ok_low_wick){
         return "not_qaulify_pinbar";
      }
      
      //check if it is a pinbar
      if(low_wick > up_wick){
         doji_pinbar_amount++;
         return "doji_pinbar";
      }
   }
   
   return "not_pinbar";
}

void show_panel(){
   //show current day and high,low price
   Comment("current day: " + IntegerToString(current_day_of_week) +
   "\n monday_high: " + DoubleToStr(monday_high, 3) + "\n monday_low: " + DoubleToStr(monday_low, 3)+
   "\n tuesday_high: " + DoubleToStr(tuesday_high, 3) + "\n tuesday_low: " + DoubleToStr(tuesday_low, 3)+
   "\n wednesday_high: " + DoubleToStr(wednesday_high, 3) + "\n wednesday_low: " + DoubleToStr(wednesday_low, 3)+
   "\n thursday_high: " + DoubleToStr(thursday_high, 3) + "\n thursday_low: " + DoubleToStr(thursday_low, 3)+
   "\n friday_high: " + DoubleToStr(friday_high, 3) + "\n friday_low: " + DoubleToStr(friday_low, 3)+
   "\npinbar: "+isPinbar(1)+
   "\nbullish_pinbar_amount: " + bullish_pinbar_amount+
   "\nbearish_pinbar_amount: " + bearish_pinbar_amount+
   "\ndoji_pinbar_amount: " + doji_pinbar_amount
   );
}

void buy(double sl, double tp){
   //calculate tp from previous h4 high - x point
   //double h4_high = iHigh(Symbol(), PERIOD_H4, 1);
   //double tp = h4_high - 3000*Point;
   //double tp = iHigh(Symbol(), PERIOD_D1, 0);
   
   
   int buy = OrderSend(Symbol(), OP_BUY, 0.01, Ask, 3, sl, tp, "pinbar", 112233, 0, clrBlue);
   today_order++;
}

void draw_hline(){  
   ObjectCreate(0, "hline"+TimeCurrent(), OBJ_VLINE, 0, Time[0], 0);
   ObjectSetInteger(0, "hline"+TimeCurrent(), OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, "hline"+TimeCurrent(), OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, "hline"+TimeCurrent(), OBJPROP_BACK, true);
}

bool isLower(int candle, int range){
   //loop check low of pinbar is lower than any candle in 10 previous candle range
   for(int i = 1; i <= range; i++){
      //check candle is lower than another
      if(Low[candle] > Low[i]){
         return false;
      }
   }
   //if candle lower than another return true
   return true;
}
