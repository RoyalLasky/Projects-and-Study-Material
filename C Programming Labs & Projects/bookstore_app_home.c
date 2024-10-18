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

void menu(void);
void displayInventory(const struct Book book[], const int size);
void addBook(struct Book book[], int *size);
int searchInventory(const struct Book book[], const int isbn,const int size);
void checkPrice(const struct Book book[], const int size);

int main(void)
{
    struct Book book[MAX_BOOKS];
    int size = 0;
    int choice;
        printf("Welcome to the Book Store\n");
        printf("=========================\n");

    do{
        menu();
        scanf("%d", &choice);
                
         switch (choice) {
         case 1:
             displayInventory(book, size);
             break;
                 case 2:
             addBook(book, &size);
             break;
                 case 3:
             checkPrice(book, size);
             break;
                 case 0:
                          printf("Goodbye!\n");
              break;
                 default:
               printf("Invalid input, try again:\n");
               }
          }
      while (choice !=0);
      return 0;
}

void menu(void)
{
    printf("Please select from the following options:\n");
   		"1) Display the inventory.\n";
    	"2) Add a book to the inventory.\n";
    	"3) Check price.\n";
    	"0) Exit.\n\n";
    	"select: ";
}

void displayInventory(const struct Book book[], const int size)
{
    int n;
    if (size == 0) {
        printf("The inventory is empty!\n");
        printf("===================================================\n\n");
    }else{
        printf("\n\n");
        printf("Inventory\n");
        printf("===================================================\n");
        printf("ISBN      Title               Year Price  Quantity\n");
        printf("---------+-------------------+----+-------+--------\n");
        
            for (n = 0; n < size; n++) {
                printf("%-10.0d%-20s%-5d$%-8.2f%-8d\n", book[n].isbn,
                    book[n].title, book[n].year, book[n].price,
                        book[n].qty);
                }
           printf("===================================================\n\n");

         }
}
void addBook(struct Book book[], int *size)
{
    int qty;
    int key;
        printf("ISBN Number:");
        scanf("%d", &book[*size].isbn);
            key = searchInventory(book, book[*size].isbn, *size);
                if (key != -1) {
                    printf("Quantity:");
                    scanf("%d", &qty);
            book[key].qty = book[key].qty + qty;
        
                printf("The book exists in the repository, quantity is updated.\n\n");
        } else if (*size == MAX_BOOKS) {
        
        printf("The inventory is full\n\n");

    } else {
        
        printf("Quantity:");
        scanf("%d", &book[*size].qty);
        
        printf("Title:");
        
        getchar();
        
        scanf("%[^\n]", book[*size].title);
        printf("Year:");
        
        scanf("%d", &book[*size].year);
        printf("Price:");
        
        scanf("%f", &book[*size].price);
        printf("The book is successfully added to the inventory.\n\n");
        
        (*size)++;
    }
}

int searchInventory(const struct Book book[], const int isbn,
           const int size)
{
    int n;
    int outCome = -1;
    for (n =0;n < size; n++) {
        if (book[n].isbn == isbn) {
            outCome = n;
            break;
        }
    }
    return outCome;
}

void checkPrice(const struct Book book[], const int size)
{
    int _isbn,key;
    printf("Please input the ISBN number of the book:\n\n");
    scanf("%d", &_isbn);
    key = searchInventory(book, _isbn, size);
        if (key == -1) {
        printf("Book does not exist in the bookstore! Please try again.\n\n");
         } else {
        printf("Book %d costs $%.2f\n\n", _isbn, book[key].price);
     }
}
