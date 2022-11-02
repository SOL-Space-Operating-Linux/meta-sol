#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char **argv) {

  printf("TMR Started\n");
  // Get the file size and offset
  int size   = atoi(argv[1]);
  printf("Performing TMR. Size = %d\n", size);

  // Allocate memory for each of the three files. Use b1 for the final 
  // result to save space
  char* b1 = malloc(sizeof(char) * 10000000);
  char* b2 = malloc(sizeof(char) * 10000000);
  char* b3 = malloc(sizeof(char) * 10000000);

  // Open the files
  int fd1 = open(argv[2], O_RDONLY);
  int fd2 = open(argv[3], O_RDONLY);
  int fd3 = open(argv[4], O_RDONLY);
  int fdout = open(argv[5], O_WRONLY | O_CREAT | O_TRUNC);

  // Read the files in 
  for(int count = 0; count < size / 10000000 + 1; count++) {
    int amount = 10000000;
    if (count == size / 10000000){
      amount = size % 10000000;
      if (amount == 0) {
        goto done;
      }
    }
    if (read(fd1, b1, amount) != amount){
      printf("Could not read in file1!\n");  
      goto done;
    }
    if (read(fd2, b2, amount) != amount){
      printf("Could not read in file2!\n");
      goto done;
    }
    if (read(fd3, b3, amount) != amount){ 
      printf("Could not read in file3!\n");
      goto done;
    }

    // Loop over all bytes, using b1 as the voted-on version
    for(int i = 0; i < amount; i++)
      b1[i] = (b1[i] & b2[i]) | (b2[i] & b3[i]) | (b3[i] & b1[i]);

    // Write the resulting file
    write(fdout, b1, amount);
  }

  // Close the files
  done:
  close(fd1);
  close(fd2);
  close(fd3);
  close(fdout);

  // Free the memory
  free(b1);
  free(b2);
  free(b3);
}