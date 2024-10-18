#include <stdio.h>
#define NUMS 4

int main()
{
	int daynum = 0, high = 0, htotal = 0, low = 0, ltotal = 0, highest = 0, highestd = 0, lowest = 0, lowestd = 0;
	double avg = 0;
	printf("---=== IPC Temperature Analyzer ===---");
	 do{ 
	 daynum++;
		printf("\nEnter the high value for day %d: ", daynum);
		scanf("%d", &high);
		printf("\nEnter the low value for day %d: ", daynum);
		scanf("%d", &low);
		if(high < low || high >= 41 || low <= -41) { 
		printf("\nIncorrect values, temperatures must be in the range -40 to 40, high must be greater than low.\n");
		printf("\nEnter the high value for day %d: ", daynum);
		scanf("%d", &high);
		printf("\nEnter the low value for day %d: ", daynum);
		scanf("%d", &low);
		}
	htotal = htotal + high; 
	ltotal = ltotal + low;
	if (high > highest) { 
			highest = high;
			highestd = daynum; 
		}
	if (low < lowest) { 
			lowest = low;
			lowestd = daynum;
		}
	}while(high < low || high >= 41 || low <= -41 || daynum < NUMS);
	avg = htotal + ltotal;
	avg = avg / 8;
	printf("\nThe avg (mean) temperature was: %.2lf", avg);

	printf("\nThe highest temperature was %d, on day %d", highest, highestd);
	
	printf("\nThe lowest temperature was %d, on day %d\n", lowest, lowestd);
	return 0;
}
