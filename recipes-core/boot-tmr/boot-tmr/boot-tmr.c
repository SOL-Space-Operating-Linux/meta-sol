#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char **argv) {

  // Get the file size and offset
  int size   = atoi(argv[1]);
  printf("Performing TMR. Size = %d\n", size);

  // Allocate memory for each of the three files. Use b1 for the final 
  // result to save space
  char* b1 = malloc(sizeof(char) * size);
  char* b2 = malloc(sizeof(char) * size);
  char* b3 = malloc(sizeof(char) * size);

  // Open the files
  int fd1 = open(argv[2], O_RDONLY);
  int fd2 = open(argv[3], O_RDONLY);
  int fd3 = open(argv[4], O_RDONLY);
  int fdout = open(argv[5], O_WRONLY | O_CREAT);

  // Read the files in 
  if (read(fd1, b1, size) != size){
    printf("Could not read in file1!\n");  
    goto done;
  }
  if (read(fd2, b2, size) != size){
    printf("Could not read in file2!\n");
    goto done;
  }
  if (read(fd3, b3, size) != size){ 
    printf("Could not read in file3!\n");
    goto done;
  }

  // Loop over all bytes, using b1 as the voted-on version
  for(int i = 0; i < size; i++)
    b1[i] = (b1[i] & b2[i]) | (b2[i] & b3[i]) | (b3[i] & b1[i]);

  // Write the resulting file
  write(fdout, b1, size);

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
