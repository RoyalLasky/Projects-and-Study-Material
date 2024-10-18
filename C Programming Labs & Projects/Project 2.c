#include <stdio.h>

int main(){
	
	int num_loonies, num_quarters, num_dimes, num_nickles, num_pennies, remainder;
	double amount, tobepaid, fullnum;
	
	printf("Please enter the amount to be paid: $");
	scanf("%lf", &amount); 
	
	printf("GST: 1.13\n");
	tobepaid = amount * 1.13;
	
	printf("Balance owing: $%.2lf\n", tobepaid);
	
	remainder = tobepaid * 100; 
	tobepaid = remainder % 100;
	fullnum = remainder - tobepaid;
	num_loonies = fullnum / 100;
	tobepaid = tobepaid / 100;
	tobepaid= tobepaid + .005;
	
	printf("Loonies required: %i, balance owing $%.2lf\n", num_loonies, tobepaid);
	
	remainder = tobepaid * 100; 
	tobepaid = remainder % 25;
	fullnum = remainder - tobepaid;
	num_quarters = fullnum / 25;
	tobepaid = tobepaid / 100;
	tobepaid= tobepaid + .005;
	
	printf("Quarters required: %i, balance owing $%.2lf\n", num_quarters, tobepaid);
	
	
	remainder = tobepaid * 100; 
	tobepaid = remainder % 10;
	fullnum = remainder - tobepaid;
	num_dimes = fullnum / 10;
	tobepaid = tobepaid / 100;
	tobepaid= tobepaid + .005;
	
	printf("Dimes required: %i, balance owing $%.2lf\n", num_dimes, tobepaid);
	
	remainder = tobepaid * 100; 
	tobepaid = remainder % 5;
	fullnum = remainder - tobepaid;
	num_nickles = fullnum / 5;
	tobepaid = tobepaid / 100;
	tobepaid= tobepaid + .005;
	
	printf("Nickles required: %i, balance owing $%.2lf\n", num_nickles, tobepaid);
	
	num_pennies = tobepaid * 100;
	tobepaid = 0.00;
	
	printf("Pennies required: %i, balance owing $%.2lf\n", num_pennies, tobepaid);

	return 0;
	
}
