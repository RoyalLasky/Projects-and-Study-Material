#include <stdio.h>

int main(){
	int adults, children;
	float acost, ccost, atotal, ctotal, btaxes, ataxes;
	acost = 79.99;
	ccost = acost * 0.90;
	
	 printf("Enter the Amount of children: ");
	 scanf("%i", &children);
	 
	 printf("Enter the Amount of adults: ");
	 scanf("%i", &adults);
	 
	 atotal = adults * acost;
	 ctotal = children * ccost;
	 
	btaxes = atotal + ctotal;
	ataxes = btaxes * 1.15;
	 
	
	printf("Total before taxes: $%.2f\n", btaxes);
	printf("Total after taxes: $%.2f\n", ataxes);
	
	return 0;
}
