//Travis Bradbury *** *** 151 
#define mdays 10
#define avgs 32765
#include <stdio.h>
int main() {
	int i, c;
	float high[mdays], low[mdays];
	
	printf("---=== IPC Temperature Analyzer V2.0 ===---\n");
	printf("Please enter the number of days between 3 and 10, inclusive: ");
	do{
	scanf("%d", &c);
	if(c < 3 || c > 10){
		printf("\nInvalid entry, please enter a number between 3 and 10, inclusive: ");
	}
} while(c < 3 || c > 10);
		printf("\n");
	for(i = 1; i <= c; i++){
		do{
		printf("Day %d - High: ", i);
		scanf("%f", &high[i]);

		printf("Day %d - Low: ", i);
		scanf("%f", &low[i]);
		
		if(high[i] > 40 || low[i] < -40 || high[i] < low[i])
		{
		printf("Incorrect values, temperatures must be in the range -40 to 40, high must be greater than low\n");
		}
	}
	while(i > c || high[i] > 40 || low[i] < -40 || high[i] < low[i]);
	}
	i = 0.00;
	printf("\n");
		printf("Day\tHi\tLow\n");
		do{
			i++;
		printf("%d\t%.0f\t%.0f\n", i, high[i], low[i]);
		}
	while(i < c);
	int enter, blah;
	float avg[avgs];
	float avgtotal;
	do{
	printf("Enter a number between 1 and 4 to see the average temperature for the entered number of days, enter a negative number to exit: \n");
	do{
	scanf("%d", &enter);
	if(enter > 4){
		printf("Invalid entry, please enter a number between 1 and 4, inclusive: ");
		}
	}while(enter > 4);
	if(enter > 1 || enter < 4){
		if(enter == 1){
				i = 1;
				avgtotal = (high[i] + low[i]) /2;
				printf("The average temperature up to day %d is: %.2f\n", enter, avgtotal);		
		}
		else if(enter == 2){
			i = 1;
			for(i = 1; i < enter+1; i++){
				
				avg[i] = (high[i] + low[i]) /2;
				
				}

				avgtotal = (avg[1] + avg[2]) / 2;
				printf("The average temperature up to day %d is: %.2f\n\n", enter, avgtotal);
		}
		else if(enter == 3){
			i = 1;
			for(i = 1; i < enter+1; i++){
				
				avg[i] = (high[i] + low[i]) /2;
				
				}

				avgtotal = (avg[1] + avg[2]+ avg[3]) / 3;
				printf("The average temperature up to day %d is: %.2f\n\n", enter, avgtotal);
		}
		else if(enter == 4){
			i = 1;
			for(i = 1; i < enter+1; i++){
				
				avg[i] = (high[i] + low[i]) /2;
				
				}

				avgtotal = (avg[1] + avg[2]+ avg[3] + avg[4]) / 4;
				printf("The average temperature up to day %d is: %.2f\n\n", enter, avgtotal);
		}
	}
	
	}
	while(enter > -1);
 printf("\nGoodbye!\n");
	return 0;
}
