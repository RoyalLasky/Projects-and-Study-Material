#include <stdio.h>
#define MAX_BOOKS 10
#define MAX_TITLE_SIZE 20

struct Book {
    int isbn;
    float price;
    int year;
    char title[MAX_TITLE_SIZE];
    int qty;
};

void menu(void){
    printf("Please select from the following options:\n");
   		printf("1) Display the inventory.\n");
    	printf("2) Add a book to the inventory.\n");
    	printf("3) Check price.\n");
    	printf("0) Exit.\n\n");
    	printf("Select: ");
}

void displayInventory(const struct Book book[], const int size){
	int i;
	i = 0;
	if (size == 0) {
        printf("The inventory is empty!\n");
        printf("===================================================\n\n");
    }else{
        printf("\n\n");
        printf("Inventory\n");
        printf("===================================================\n");
        printf("ISBN      Title               Year Price  Quantity\n");
        printf("---------+-------------------+----+-------+--------\n");
        
            for (i = 0; i < size; i++) {
                printf("%-10.0d%-20s%-5d$%-8.2f%-8d\n", book[i].isbn,
                    book[i].title, book[i].year, book[i].price, book[i].qty);
                }
           printf("===================================================\n\n");
	}
}

int searchInventory(const struct Book book[], const int isbn,const int size){
	int i, out;
	out = -1;
    for (i = 0; i < size; i++) {
        if (book[i].isbn == isbn) {
            out = i;
            break;
        }
    }
    return out;
}

void addBook(struct Book book[], int *size){
	
	int i;
	int quant;
    if (*size == MAX_BOOKS) {
        printf("The inventory is full\n\n");
		} 
		printf("ISBN Number:");
        scanf("%d", &book[*size].isbn);
		i = searchInventory(book, book[*size].isbn, *size);
                 if (i != -1) {
                    printf("Quantity:");
                    scanf("%d", &quant);
            book[i].qty = book[i].qty + quant;
        
                printf("The book exists in the repository, quantity is updated.\n\n");
        }
        
		else{
		
		printf("Quantity:");
        scanf("%d", &book[*size].qty);
        
        printf("Title:");
        getchar();
        scanf("%[^\n]", book[*size].title);
        
		printf("Year:");
        scanf("%d", &book[*size].year);
        
		printf("Price:");
        scanf("%f", &book[*size].price);
         
        (*size)++;
        
        printf("The book is successfully added to the inventory.\n\n");
    }
}


void checkPrice(const struct Book book[], const int size){
	int number,i;
    printf("Please input the ISBN number of the book:\n\n");
    scanf("%d", &number);
    i = searchInventory(book, number, size);
        if (i == -1){
        printf("Book does not exist in the bookstore! Please try again.\n\n");
        } 
		 
		else{
        printf("Book %d costs $%.2f\n\n", number, book[i].price);
     }
}


int main(void){
struct Book book[MAX_BOOKS];
    int size = 0;
    int choice;
        printf("Welcome to the Book Store\n");
        printf("=========================\n");
        
        do{
        menu();
        scanf("%d", &choice);
        
        if(choice == 1){
        	displayInventory(book, size);
		}
        else if(choice == 2) {
        	addBook(book, &size);
		}   
		else if(choice == 3){
			checkPrice(book, size);
		}
		else if(choice == 0){
			break;
		}
		else{
			printf("Invalid input, try again:\n");
		}
		}while(choice != 1 || choice != 2 || choice != 3 || choice != 0);
		
        printf("Goodbye!");
        

	return 0;
}
