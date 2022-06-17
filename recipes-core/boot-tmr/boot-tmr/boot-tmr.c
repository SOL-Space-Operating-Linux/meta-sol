#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char **argv) {
    int fd1 = open(argv[3], O_RDONLY);
    int fd2 = open(argv[4], O_RDONLY);
    int fd3 = open(argv[5], O_RDONLY);
    int fdout = open(argv[6], O_WRONLY);

    lseek(fd1, atoi(argv[2])*512, SEEK_SET);
    lseek(fd2, atoi(argv[2])*512, SEEK_SET);
    lseek(fd3, atoi(argv[2])*512, SEEK_SET);

    unsigned char b1[1], b2[1], b3[1];
    unsigned char b[1];
    
    for(int count = 0; count < atoi(argv[1]); count++) {
        if(read(fd1, b1, 1) != 1) exit(1);
        if(read(fd2, b2, 1) != 1) exit(1);
        if(read(fd3, b3, 1) != 1) exit(1);

        b[0] = (b1[0] & b2[0]) | (b2[0] & b3[0]) | (b3[0] & b1[0]);
		write(fdout, b, 1);
	}
}