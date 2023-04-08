int: money_limit;
set of int: menu_items = index_set(menu_prices); 
array[int] of int: menu_prices;
array[menu_items] of string: menu_names;
array[menu_items] of int: yumyum_factors; 
array[menu_items] of int: available;


array[menu_items] of var int: order;
var int: total_yumyum = sum([order[i] * yumyum_factors[i] | i in menu_items]);
var int: total_price = sum([order[i] * menu_prices[i] | i in menu_items]);


constraint forall([menu_prices[i] >= 0 | i in menu_items]);                 
constraint forall([order[i] >= 0 | i in menu_items]);                       
constraint forall([order[i] * menu_prices[i] >= 0 | i in menu_items]);      
constraint total_price <= money_limit;                                      
constraint total_price >=0;                                                 
constraint forall([order[i] <= available[i] | i in menu_items]);            

solve maximize total_yumyum ; 



output ["\(menu_names[i]): \(order[i])\n" | i in menu_items] ++ 
       ["- total price:\t\(total_price)/\(money_limit)\n"] ++
       ["- total yumyum:\t\(total_yumyum)"];
