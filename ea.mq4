double monday_high, monday_low;
double tuesday_high, tuesday_low;
double wednesday_high, wednesday_low;
double thursday_high, thursday_low;
double friday_high, friday_low;
int current_day_of_week;
bool pinbar_detect;
int bullish_pinbar_amount;
int bearish_pinbar_amount;
int bar;
double ma20;
double ma200;
int ma_period = PERIOD_D1;
int move_sl_range = 7000 * Point;

int OnInit()
  {
   ObjectsDeleteAll();
   pinbar_detect = false;
   current_day_of_week = DayOfWeek();
   bullish_pinbar_amount = 0;
   bearish_pinbar_amount = 0;
   bar = Bars;
   
   return(INIT_SUCCEEDED);
  }
  
void OnTick()
{
   ma20 = iMA(Symbol(), 0, ma_period, 20, MODE_SMA, PRICE_CLOSE, 0);
   ma200 = iMA(Symbol(), 0, ma_period, 200, MODE_SMA, PRICE_CLOSE, 0);
   
   //this just check an hour change
   if(Bars>bar){
      //update price panel
      show_panel();
      
      //check open order
      if(OrdersTotal()){
         //loop select all order
         for(int i=0; i<OrdersTotal(); i++){
            //select each order by their index
            int select = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
            
            //check if bid price more than each order open price
            if(Bid-move_sl_range > OrderOpenPrice()){
               //move sl to the same with order open price
               int modify = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, clrYellow); 
            }
            
         }
      }
      
      //check for buy
      if(isPinbar(1) == "bullish_pinbar"){
         //price must higher than moving average
         if(Bid > ma20){
            if(ma20 > ma200){
               buy();
            }
         }
      }
      
      if(isPinbar(1) == "bearish_pinbar"){
         //price must higher than moving average
         if(Bid > ma20){
            if(ma20 > ma200){
               buy();
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
   
   //bullish
   if(open<close){
      //calculate candle up wick, body, and low wick
      up_wick = high - close;
      body = close - open;
      low_wick = open - low;
      
      //check if it is a pinbar
      if(low_wick > body && low_wick > up_wick && body > up_wick){
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
      
      //check if it is a pinbar
      if(low_wick > body && low_wick > up_wick && body > up_wick){
         bearish_pinbar_amount++;
         return "bearish_pinbar";
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
   "\nbearish_pinbar_amount: " + bearish_pinbar_amount
   );
}

void buy(){
   int buy = OrderSend(Symbol(), OP_BUY, 0.01, Ask, 3, Low[1], 0, "bullish pinbar", 112233, 0, clrBlue);
}