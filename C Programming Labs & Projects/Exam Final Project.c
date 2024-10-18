//Travis B.
//Student Number: *** *** 151

#define LINEAR 1
#define FORM 0
#define STOCK 1
#define CHECKOUT 0
#define MAX_QTY 999
#define SKU_MAX 999
#define SKU_MIN 100
#define MAX_ITEM_NO 500
#define DATAFILE "items.txt"
#include <stdio.h>
const double TAX = 0.13;

struct Item {
	double price;
	int sku;
	int isTaxed;
	int quantity;
	int minQuantity;
	char name[21];
};

//function prototype Milestone 1
void welcome(void);
void printTitle(void);
void printFooter(double gTotal);
void flushKeyboard(void);
void pause(void);
int getInt(void);
double getDouble(void);
int getIntLimited(int lowLimit, int upLimit);
double getDoubleLimited(double lowLimit, double upLimit);
int yes(void);
void GroceryInventorySystem(void);
int menu(void);

// function milestone 2:
double totalAfterTax(struct Item item);
int isLowQuantity(struct Item item);
struct Item itemEntry(int sku);
void displayItem(struct Item item, int linear);
void listItems(const struct Item item[], int NoOfItems);
int locateItem(const struct Item item[], int NoOfRecs, int sku, int* index);

// function milestone 3:
void search(const struct Item item[], int NoOfRecs);
void updateItem(struct Item* itemptr);
void addItem(struct Item item[], int *NoOfRecs, int sku);
void addOrUpdateItem(struct Item item[], int* NoOfRecs);
void adjustQuantity(struct Item item[], int NoOfRecs, int stock);

//function milestone 4:
void saveItem(struct Item item, FILE* dataFile);
int loadItem(struct Item* item, FILE* dataFile);
int saveItems(const struct Item item[], char fileName[], int NoOfRecs);
int loadItems(struct Item item[], char fileName[], int* NoOfRecsPtr);

int main(void) {
   GroceryInventorySystem();
   return 0;
}


//Function Milestone 1:
void welcome(void) {
	printf("---=== Grocery Inventory System ===---\n\n");
}
void printTitle(void) {
	printf("Row |SKU| Name               | Price  |Taxed| Qty | Min |   Total    |Atn\n");
	printf("----+---+--------------------+--------+-----+-----+-----+------------|---\n");
}
void printFooter(double gTotal) {
	printf("--------------------------------------------------------+----------------\n");
	if (gTotal > 0) {
		printf("                                           Grand Total: |%12.2lf\n", gTotal);
	}
}
void flushKeyboard(void) {
	while (getchar() != '\n') {}

}
void pause(void) {
	printf("Press <ENTER> to continue...");	
	flushKeyboard();
}
int getInt(void) {
	int value;
	char NL;
	do {
		scanf("%d%c", &value, &NL);
		if (NL != '\n') {
			printf("Invalid integer, please try again: ");
			flushKeyboard();
		}
	} while (NL != '\n');
	return value;
}
int getIntLimited(int lowerLimit, int upperLimit){
	int intvalue;
	do{
	intvalue = getInt();
	if(intvalue < lowerLimit || intvalue > upperLimit)
	printf("Invalid value, %d < value < %d: ", lowerLimit, upperLimit);
	}while(intvalue < lowerLimit || intvalue > upperLimit);
	return intvalue;
}
double getDouble(void) {
	double value;
	char NL;
	do {
		scanf("%lf%c", &value, &NL);
		if (NL != '\n') {
			printf("Invalid number, please try again: ");
			flushKeyboard();
		}
	} while (NL != '\n');
	return value;
}
double getDoubleLimited(double lowerLimit, double upperLimit){
	double doublevalue;
	do{
	doublevalue = getDouble();
	if(doublevalue < lowerLimit || doublevalue > upperLimit)
	printf("Invalid value, %lf < value < %lf: ", lowerLimit, upperLimit);
	}while(doublevalue < lowerLimit || doublevalue > upperLimit);
	return doublevalue;
}
int yes(void)
{
	char ch;
	int answer;
	do {
		scanf(" %c", &ch);
		flushKeyboard();
		if (ch != 'Y' && ch != 'y' && ch != 'N' && ch != 'n')
			printf("Only (Y)es or (N)o are acceptable: ");
	} while (ch != 'Y' && ch != 'y' && ch != 'N' && ch != 'n');

	if (ch == 'Y' || ch == 'y')
		answer = 1;
	else
		answer = 0;
	return answer;
}

int menu(void){ 

	printf("1- List all items\n");
	printf("2- Search by SKU\n");
	printf("3- Checkout an item\n");
	printf("4- Stock an item\n");
	printf("5- Add new item or update item\n");
	printf("6- delete item\n");
	printf("7- Search by name\n");
	printf("0- Exit program\n");
	printf("> ");
	return 0;
}
void GroceryInventorySystem(void){
	int choice, exit;
	welcome();
	start:
	menu();
	start2:
	scanf("%d", &choice);
	if(choice == 1){
		//listItems;
		pause();
		flushKeyboard();
		goto start;
	}
	else if(choice == 2){
		//search;
		pause();
		flushKeyboard();
		goto start;
	}
	else if(choice == 3){
		//adjustQuantity;
		pause();
		flushKeyboard();
		goto start;
	}
	else if(choice == 4){
		//addItem;
		pause();
		flushKeyboard();
		goto start;
	}
	else if(choice == 5){
		//addOrUpdateItem;
		pause();
		flushKeyboard();
		goto start;
	}
	else if(choice == 6){
		printf("Not implemented!\n");
		pause();
		flushKeyboard();
		goto start;
	}
	else if(choice == 7){
		printf("Not implemented!\n");
		pause();
		flushKeyboard();
		goto start;
	}
	else if(choice == 0){
		printf("Exit the program? (Y)es/(N)o): ");
		exit = yes();
		printf("exit after yes: %d\n", exit);
		if(exit = 0){
			goto start;
			flushKeyboard();
		}
		
	}
	else{
		printf("Invalid value, 0 < value < 7: ");
		goto start2;
	}
	while(exit != 0);
}
// Function Implemention Milestone 2:

double totalAfterTax(struct Item item) {
	double Total = 0;
	Total = item.price * item.quantity;
	if (item.isTaxed != 0)
		Total += Total * TAX;
	return Total;
}

int isLowQuantity(struct Item item) {
	int flag = 0;
	if (item.quantity <= item.minQuantity)
		flag = 1; //low
	else
		flag = 0; //not low
	return flag;
}

struct Item itemEntry(int sku) {
	struct Item item;
	item.sku = sku;
	printf("        SKU: %d\n", sku);
	printf("       Name: ");
	scanf("%20[^\n]", item.name);
	flushKeyboard();
	printf("      Price: ");
	item.price = getDoubleLimited(0, 999);
	printf("   Quantity: ");
	item.quantity = getInt();
	printf("Minimum Qty: ");
	item.minQuantity = getInt();
	printf("   Is Taxed: ");
	item.isTaxed = yes();
	return item;
}

void displayItem(struct Item item, int linear) {
	
	        if (linear == 1) {
			printf("|%3d|%-20s|%8.2lf|%5s|%4d |%4d |%12.2lf|%s", item.sku, item.name, item.price, (item.isTaxed ? "Yes" : "No"), item.quantity, item.minQuantity, totalAfterTax(item), (isLowQuantity(item) ? "***" : ""));
		}
		if (linear == FORM) {
			printf("        SKU: %d\n", item.sku);
			printf("       Name: %s\n", item.name);
			printf("      Price: %.2lf\n", item.price);				     
			printf("   Quantity: %d\n", item.quantity);
			printf("Minimum Qty: %d\n", item.minQuantity);
			printf("   Is Taxed: %s", item.isTaxed ? "Yes" : "No");						         					             
		if (isLowQuantity(item)) { 
		printf("\nWARNING: Quantity low, please order ASAP!!!\n"); }
	   }			        
}
void listItems(const struct Item item[], int noOfItems){
	
	int i;
	double grandTotal = 0;
	printTitle();
	for (i = 0; i < noOfItems; i++) { 
		printf("%-4d", i + 1);
		displayItem(item[i], noOfItems);
		grandTotal += totalAfterTax(item[i]);
	}
	printFooter(grandTotal); 

}

int locateItem(const struct Item item[], int NoOfRecs, int sku, int* index){
	
	int i = 0, flag = 0;
	for (i = 0; i < NoOfRecs && flag == 0; i++)
	{
		if (item[i].sku == sku) {
			(*index) = i;
			flag = 1;

		}
	}
	return flag;
}

void search(const struct Item item[], int NoOfRecs){ 

	int SKU, index = 0, found = 0;
	printf("Please enter the SKU: ");
	SKU = getIntLimited(SKU_MIN, SKU_MAX); 
	found = locateItem(item, NoOfRecs, SKU, &index);
	if (found == 1)
		displayItem(item[index], FORM); 
	else
		printf("Item not found!\n");
}

void updateItem(struct Item* itemptr){ 
	struct Item item; 
	int blah = 0;
	printf("Enter new data:\n");
	item = itemEntry((*itemptr).sku); 
	printf("Overwrite old data? (Y)es/(N)o: ");
	blah = yes(); 
	if (blah == 1) {
		*itemptr = item; 
		printf("--== Updated! ==--\n");
	}
	else
		printf("--== Aborted! ==--\n");
}

void addItem(struct Item item[], int *NoOfRecs, int sku) {
	struct Item tempItem;
	int answer;
	if ((*NoOfRecs) == MAX_ITEM_NO) {
		printf("Can not add new item; Storage Full!\n");
	}	
	else {
		tempItem = itemEntry(sku);
		printf("Add Item? (Y)es/(N)o: ");
		answer = yes();
		if (answer == 1) {
			item[*NoOfRecs] = tempItem;						     
		printf("--== Added! ==--\n");
		        (*NoOfRecs)++;
		}
		else {
			printf("--== Aborted! ==--\n");
		}
	}
}

void addOrUpdateItem(struct Item item[], int* NoOfRecs){
	int sku, found, foundIndex, answer;
	printf("Please enter the SKU: ");
        sku = getIntLimited(SKU_MIN, SKU_MAX);
	found = locateItem(item, *NoOfRecs, sku, &foundIndex);
	if (found == 1) {
		displayItem(item[foundIndex], FORM);
		printf("Item already exists, Update? (Y)es/(N)o: ");
		answer = yes();
		if (answer == 1) {
			updateItem(&item[foundIndex]);
		}
		else {
			printf("--== Aborted! ==--\n");
		}
	}		               
		else {
	addItem(item, NoOfRecs, sku);
	}
}
void adjustQuantity(struct Item item[], int NoOfRecs, int stock){
	int sku, found, i, manager;
	printf("Please enter the SKU: ");
	sku = getIntLimited(SKU_MIN, SKU_MAX);
	found = locateItem(item, NoOfRecs, sku, &i);
	if (found) {
		displayItem(item[i], FORM);
		printf("Please enter the quantity %s; Maximum of %d or 0 to abort: ", (stock == STOCK ? "to stock" : "to checkout"), (stock == STOCK ? MAX_QTY - item[i].quantity : item[i].quantity));
		if (stock == STOCK) {
			manager = getIntLimited(0, MAX_QTY - item[i].quantity);
		}
		if (stock == CHECKOUT) {
			manager = getIntLimited(0, item[i].quantity);
		}
		if (manager == 0) {
			printf("--== Aborted! ==--\n");
		}
		else {	
		item[i].quantity = (stock == STOCK) ? (item[i].quantity + manager) : (item[i].quantity - manager);
		printf("%s", (stock == STOCK) ? ("--== Stocked! ==--\n") : ("--== Checked out! ==--\n"));
		printf("%s", isLowQuantity(item[found]) == 1 ? "Quantity is low, please reorder ASAP!!!\n" : "");
		}
	}
	else {
		printf("SKU not found in storage!\n");
	}
}

void saveItem(struct Item item, FILE* dataFile) {
	if (dataFile != NULL) {
		fprintf(dataFile, "%d,%d,%d,%.2lf,%d,%s\n", item.sku, item.quantity, item.minQuantity, item.price, item.isTaxed, item.name);
	}
}
int loadItem(struct Item* item, FILE* dataFile) {
	int load;
	if (dataFile != NULL) {
		if (fscanf(dataFile, "%d,%d,%d,%lf,%d,%21[^\n]", &item->sku, &item->quantity, &item->minQuantity, &item->price, &item->isTaxed, item->name) == 6)							              
	       		load = 1;
		else load = 0;
	}
	return load;
}
int saveItems(const struct Item item[], char fileName[], int NoOfRecs) {
	int i, blah = 0;
	FILE *fp;
	fp = fopen(fileName, "w");
	if (fp != NULL) {
		blah = 1;
		for (i = 0; i < NoOfRecs; i++)
		{
			saveItem(item[i], fp);
		}
		fclose(fp);
	}
	return blah;
}
int loadItems(struct Item item[], char fileName[], int* NoOfRecsPtr) {
	int blah = 0;
	FILE *fp;
	fp = fopen(fileName, "r");
	if (fp) {
		blah = 1;
		(*NoOfRecsPtr) = 0;
		while (loadItem(&item[*NoOfRecsPtr], fp) == 1) {
			(*NoOfRecsPtr)++;
		}
		fclose(fp);
	}
	return blah;
}
