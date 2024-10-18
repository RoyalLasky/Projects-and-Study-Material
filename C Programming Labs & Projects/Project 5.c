#include <stdio.h>

// Define Number of Employees
#define NumEmploy 2

// Declare Struct Employee 
struct Employee{
	int id, age;
	double salary;
};

/* main program */
int main(void) {
	int i = 0;
	int empamount = 0;
	int emp[NumEmploy] = {0};
	int id[NumEmploy] = {0};
	int age[NumEmploy] = {0};
	double salary[NumEmploy] = {0};
	int option = 0;
	printf("---=== EMPLOYEE DATA ===---\n\n");

	// Declare a struct Employee array "emp" with SIZE elements 
	// and initialize all elements to zero

	do {
		// Print the option list
		printf("1. Display Employee Information\n");
		printf("2. Add Employee\n");
		printf("0. Exit\n\n");
		printf("Please select from the above options: ");
		
		// Capture input to option variable
		scanf("%d",&option);
		printf("\n");
		
		switch (option) {
		case 0:	// Exit the program
			
			break;
		case 1: // Display Employee Data
				// @IN-LAB

			printf("EMP ID  EMP AGE EMP SALARY\n");
			printf("======  ======= ==========\n");
			for(i = 0; i < NumEmploy; i++){
				printf("%d\t%d\t%.2lf", id[i], age[i], salary[i]);
				printf("\n");
			}

			// Use "%6d%9d%11.2lf" formatting in a   
			// printf statement to display
			// employee id, age and salary of 
			// all  employees using a loop construct 
			
			// The loop construct will be run for SIZE times 
			// and will only display Employee data 
			// where the EmployeeID is > 0

			break;
		case 2:	// Adding Employee
				// @IN-LAB
				
			printf("Adding Employee\n");
			printf("===============\n");
			if(empamount < NumEmploy){
				printf("Enter Employee ID: ");
				scanf("%d", &id[i]);
				printf("Enter Employee Age:  ");
				scanf("%d", &age[i]);
				printf("Enter Employee Salary: ");
				scanf("%lf", &salary[i]);
				i++;
				empamount++;
				
			} else{
				printf("\nERROR!!! Maximum Number of Employees Reached\n\n");
			}

			// Check for limits on the array and add employee 
			// data accordingly. 



			break;
		default:
			printf("ERROR: Incorrect Option: Try Again\n\n");
		}

	} while (option != 0);


	return 0; 
}
