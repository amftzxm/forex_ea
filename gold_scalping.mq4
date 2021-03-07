int orderAll;
double balance;
int breakeven = 540;
int trailing = 1500;
int takeprofit = 3000;
int stoploss = 1000;
int lock_balance = 1;

void OnInit(){
   ObjectsDeleteAll();
}

void OnTick(){
   
   orderAll = OrdersTotal();
   balance = AccountBalance();
   
   if(OrdersTotal()==0){
      if(false)){
         if(balance>lock_balance){
            buy();
         }
      }
      
      if(false){
         if(balance>lock_balance){
            sell();
         }
      }
    }
   
   if(orderAll){
      trailingProfit();
   }
}

void buy(){
   double sl = Bid-stoploss*Point;
   double tp = Ask+takeprofit*Point;
   
   int ticket = OrderSend(Symbol(), OP_BUY, 0.01, Ask, 1, sl, tp, "buy order", 0, 0, clrBlue); // try to send buy order
   // check if ordersend response any eror
   if(ticket<0){
      Print(GetLastError());
   }
}

void sell(){
   double sl = Bid+stoploss*Point;
   double tp = Bid-takeprofit*Point;
   
   int ticket = OrderSend(Symbol(), OP_SELL, 0.01, Bid, 1, sl, tp, "sell order", 0, 0, clrRed); // try to send sell order
   // check if ordersend response any eror
   if(ticket<0){
      Print(GetLastError());
   }
}

void trailingProfit(){
   int select = OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
   
   if(OrderType()==OP_BUY){
      breakEvenBuy();
      tralingBuy();
   }
   
   if(OrderType()==OP_SELL){
      breakEvenSell();
      tralingSell();
   }
}

void breakEvenBuy(){
   if(Bid-(breakeven*Point)>OrderOpenPrice()){
      // move  sl to breakeven
      if(OrderStopLoss()<OrderOpenPrice()){
         int modor = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, clrGold);
         if(modor<0){
            Print(GetLastError());
         }
      }
   }
}

void tralingBuy(){
   if(OrderStopLoss()>=OrderOpenPrice()){
      if(Bid-(trailing*Point)> OrderStopLoss()){
         int modor = OrderModify(OrderTicket(), OrderOpenPrice(), Bid-(trailing*Point), OrderTakeProfit(), 0, clrBlue);
         if(modor<0){
            Print(GetLastError());
         }   
      }
   }
}

void breakEvenSell(){
   if(Bid+(breakeven*Point)<OrderOpenPrice()){
      // move  sl to breakeven
      if(OrderStopLoss()>OrderOpenPrice()){
         int modor = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, clrGold);
         if(modor<0){
            Print(GetLastError());
         }
      }
   }
}

void tralingSell(){
   if(OrderStopLoss()<=OrderOpenPrice()){
      if(Bid+(trailing*Point)<OrderStopLoss()){
         int modor = OrderModify(OrderTicket(), OrderOpenPrice(), Bid+(trailing*Point), OrderTakeProfit(), 0, clrBlue);
         if(modor<0){
            Print(GetLastError());
         }   
      }
   }
}
