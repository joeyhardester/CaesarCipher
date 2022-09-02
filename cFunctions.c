// Joey Hardester - XD32736
// Thomas Moran - AE10376
// CMSC 313, Section 02
// This file is to help the main assembly file complete actions for the specified user input.

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>
#include <ctype.h>
#include <math.h>
#include <stdbool.h>

int clearBuffer(); // used to clear the input buffer to prevent any weird C things
void printArr(char ** arr); // used to display the messages 
int validate(char ** arr, int arrTrack, int amount); // used to validate any messages thar the user inputs
void stringDecrypt(char ** arr, int posTrack); // used for frequency decryption
void freeUp(char ** arr, int amount); // used to free dynamically allocated memory
int mosFre(int arr[], int p1, int p2, int p3, int p4); // used to get the most frequent characters in a string
void decPros(char * arr, int mF, int let); // helper for stringDecrypt, does the decryption process
void easterEggC(); // used to perform the easter egg

void printArr(char ** arr) {
  for(int i=0; i<10; ++i) {
    printf("Message[%d]: %s", i, arr[i]);
  }
}

int validate(char ** arr, int arrTrack, int amount) {
  int buffer = 256;
  int position = 0;

  char* cmd = malloc(sizeof(char) * buffer); // allocated for user input

  char cha; // will get current char, one at a time
  int cont = 1; // condition for while loop

  cha = fgetc(stdin); // gets unwanted character out of stdin
  cha = 0;
  while(cont == 1) {
    if(cha != 10) {
      cha = fgetc(stdin); // gets the value of the character
      if(cha == EOF || cha == '\n' || cha == '\r') { // if the value is at the end of the string
	cmd[position] = '\0';
	cont = 0; // while loop ends
      }
      if (position == 0) { //checks to see if the first character is uppercase
	if (cha < 65 || cha > 90) {
	  printf("invalid message, keeping current\n"); 
	  cont = 0;
	  free(cmd); // frees dynamically allocated memory
	  int temp = clearBuffer(); // clears buffer
	  return 0; // 0 is returned because string was not updated
	} else {
	  cmd[position] = cha; // character is stored in array
	}
       } else {
	cmd[position] = cha; // character is stored in array
      }
      position++; // moves to next position in array
      if (position >= buffer) { // if initial size was not enough
	buffer += 256; 
	cmd = realloc(cmd, buffer);
      }
    }   
  }

  int x = cmd[position-2]; // gets the value of second to last character
  if (x == 46 || x == 33 || x == 63) { // checks to see if value is valid punctuation
    char* toDel = arr[arrTrack]; // temp placeholder to delete dynamic memory from previous inputs
    arr[arrTrack] = cmd; // new string is stored in array
    if(amount == 10) {
      free(toDel); // frees previous dynamically allocated memory
    }
  } else {
    printf("invalid message, keeping current\n");
    free(cmd); // frees dynamically allocated memory
    return 0; // 0 is returned because string was not updated
  }
  
  return 1; // 1 is returned because string was updated
}
  

//clears the input buffer to prevent any mistakes
// reference: codegrepper.com/code-examples/c/how+to+clear+stdin+buffer+in+c
int clearBuffer() {
  char c;
  do {
    c = getchar();
  } while (c != '\n' && c != EOF);
  return 0;
}



void stringDecrypt(char ** arr, int posTrack) {
  char* toDec = arr[posTrack]; // gets string to decrypt

  int alp[26] = {0}; // used to track which characters are most frequent in string
  int curr; // used to get current char
  int i = 0; // used for position tracking
  int cont = 1; // used for while loop condition

  while(cont == 1) {
    curr = toDec[i]; // gets current value of string
    if(curr == '\n') { // used to check if at end of string
      cont = 0; // while loop ends
    } else {
      if(curr <= 90 && curr >= 65) { // if the current char is an uppercase letter
	curr = curr-65; // ex. B-65 = 1, position 1 is incremented
	alp[curr]++; // index for letter position is updated (a = 0, b = 1, etc.)
      } else if (curr <= 122 && curr >= 97) { // if the current char is an lowercase letter
	curr = curr-97; // ex. a-97 = 0, positon 0 is incremented
	alp[curr]++; // index for letter position is updated
      }
    }
    i++; // position is incremented
  }
  
  int mF1, mF2, mF3, mF4, mF5; // used for 5 most frequent characters
  mF1 = mosFre(alp, 0, 0, 0, 0); // process to get most frequent characters
  mF2 = mosFre(alp, mF1, 0, 0, 0);
  mF3 = mosFre(alp, mF1, mF2, 0, 0);
  mF4 = mosFre(alp, mF1, mF2, mF3, 0);
  mF5 = mosFre(alp, mF1, mF2, mF3, mF4);

  decPros(toDec, mF1, 101); // call to helper to compare most frequent to e
  printf("OR\n");
  decPros(toDec, mF2, 116); // call to helper to compare second most frequent to t
  printf("OR\n");
  decPros(toDec, mF3, 97); // call to helper to compare third most frequent to a
  printf("OR\n");
  decPros(toDec, mF4, 111); // call to helper to compare fourth most frequent to o
  printf("OR\n");
  decPros(toDec, mF5, 105); // call to helper to compare fifth most frequent to i
}

void freeUp(char ** arr, int amount) {
  // amount is used to prevent any uneeded frees
  for(int i=0; i<amount; ++i) {
    free(arr[i]); // frees dynamically allocated position in array
  }
}

int mosFre(int arr[], int p1, int p2, int p3, int p4) {
  int mFtemp = 0; // used to get value of most frequent
  int prev = 0; // used to get value at positon(number of times character appears)
  for(int i = 0; i < 26; i++) {
    if(arr[i] > prev && i+97 != p1 && i+97 != p2 && i+97 != p3 && i+97 != p4) { // makes sure value is not same as other letters
      mFtemp = i+97; //letter is updated
      prev = arr[i];
    }
  }
  return mFtemp; // most frequent is returned
}

void decPros(char * arr, int mF, int let) {
  int shiftVal = let-mF; //gets the value to shift by
  int arrLen = 0; //used for dynamic allocation
  int getArrLen = 1; // condtion for while loop
  while(getArrLen == 1) {
    if(arr[arrLen] == 10) {
      getArrLen = 0;
    }
    arrLen++;
  }

  char * tempStr = malloc(sizeof(char) * (arrLen+1)); //dynamically allocates for decryted string
  int cont = 1; // condition for while loop
  int currChar, oUCheck, overShift, underShift; // used for shift process
  int i = 0; // used for position tracking

  while(cont == 1) {
    currChar = arr[i];
    if(currChar == 10) { // if reached the end of the string
      cont = 0; 
    } else {
      if(currChar <= 90 && currChar >= 65) { // if the letter is uppercase, shift to lowercase
	currChar = currChar+32;
      }
      if(currChar <= 122 && currChar >= 97) { // if the letter is lowercase
	oUCheck = currChar+shiftVal; // used to check for over/under flow of char value
	if(oUCheck > 122) { // if shift went past upper bound, special case
	  overShift = 26-shiftVal;
	  currChar = currChar-overShift; // new value is applied to char
	} else if(oUCheck < 97) { // if shift went below lower bound, special case
	  underShift = 26+shiftVal;
	  currChar = currChar+underShift; // new value is applied to char
	} else {
	  currChar = currChar+shiftVal; // shift value is applied to char is normal case
	}
      }
    }
    tempStr[i] = currChar; // char value is put in proper spot in string
    i++; // positon is incremented
  }
  
  printf("%s", tempStr); // prints the decrypted string
  free(tempStr); // frees the dynamic memory
}

void easterEggC() {
  printf("Easter Egg Time!\n");
  int c = clearBuffer();

  char adj[] = "Enter an adjective: ";
  char noun[] = "Enter a noun: ";
  char num[] = "Enter a number: ";
  char food[] = "Enter a food: ";
  
  char adj1[30];
  printf("%s", adj);
  fgets(adj1, sizeof(adj1), stdin);
  // reference from stackoverflow.com/questions/2693776/removing-trailing-newline-character-from-fgets-input
  adj1[strcspn(adj1, "\n")] = 0;

  char nat[30];
  printf("Enter a nationality: ");
  fgets(nat, sizeof(nat), stdin);
  nat[strcspn(nat, "\n")] = 0;

  char per[30];
  printf("Enter a person: ");
  fgets(per, sizeof(per), stdin);
  per[strcspn(per, "\n")] = 0;

  char n1[30];
  printf("%s", noun);
  fgets(n1, sizeof(n1), stdin);
  n1[strcspn(n1, "\n")] = 0;

  char adj2[30];
  printf("%s", adj);
  fgets(adj2, sizeof(adj2), stdin);
  adj2[strcspn(adj2, "\n")] = 0;

  char n2[30];
  printf("%s", noun);
  fgets(n2, sizeof(n2), stdin);
  n2[strcspn(n2, "\n")] = 0;

  char adj3[30];
  printf("%s", adj);
  fgets(adj3, sizeof(adj3), stdin);
  adj3[strcspn(adj3, "\n")] = 0;

  char adj4[30];
  printf("%s", adj);
  fgets(adj4, sizeof(adj4), stdin);
  adj4[strcspn(adj4, "\n")] = 0;

  char pn[30];
  printf("Enter a plural noun: ");
  fgets(pn, sizeof(pn), stdin);
  pn[strcspn(pn, "\n")] = 0;

  char n3[30];
  printf("%s", noun);
  fgets(n3, sizeof(n3), stdin);
  n3[strcspn(n3, "\n")] = 0;

  char num1[30];
  printf("%s", num);
  fgets(num1, sizeof(num1), stdin);
  num1[strcspn(num1, "\n")] = 0;

  char sha[30];
  printf("Enter a shape(plural): ");
  fgets(sha, sizeof(sha), stdin);
  sha[strcspn(sha, "\n")] = 0;
  
  char f1[30];
  printf("%s", food);
  fgets(f1, sizeof(f1), stdin);
  f1[strcspn(f1, "\n")] = 0;

  char f2[30];
  printf("%s", food);
  fgets(f2, sizeof(f2), stdin);
  f2[strcspn(f2, "\n")] = 0;

  char num2[30];
  printf("%s", num);
  fgets(num2, sizeof(num2), stdin);
  num2[strcspn(num2, "\n")] = 0;

  printf("\t\t Pizza Pizza Madlib!\n");
  printf("Pizza was invented by a %s %s chef named\n", adj1, nat);
  printf("%s. To make pizza, you to take a lump of %s,\n", per, n1);
  printf("and make a thin, round %s %s. Then you cover it\n", adj2, n2);
  printf("with %s sauce, %s cheese, and fresh chopped %s.\n", adj3, adj4, pn);
  printf("Next you have to bake it in a very hot %s. When\n", n3);
  printf("it is done, cut it into %s %s. Some kids like\n", num1, sha);
  printf("%s pizza the best, but my favorite is the %s pizza.\n", f1, f2);
  printf("If I could, I would eat pizza %s times a day!\n", num2);
}
