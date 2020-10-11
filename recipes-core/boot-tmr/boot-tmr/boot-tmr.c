#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char **argv) {
    int fd1 = open(argv[3], O_RDONLY);
    int fd2 = open(argv[4], O_RDONLY);
    int fd3 = open(argv[5], O_RDONLY);
    int fd4 = open(argv[3], O_WRONLY);
    int fd5 = open(argv[4], O_WRONLY);
    int fd6 = open(argv[5], O_WRONLY);

    lseek(fd1, atoi(argv[2])*512, SEEK_SET);
    lseek(fd2, atoi(argv[2])*512, SEEK_SET);
    lseek(fd3, atoi(argv[2])*512, SEEK_SET);
    lseek(fd4, atoi(argv[2])*512, SEEK_SET);
    lseek(fd5, atoi(argv[2])*512, SEEK_SET);
    lseek(fd6, atoi(argv[2])*512, SEEK_SET);

    unsigned char b1[1], b2[1], b3[1];
    unsigned char b[1];
    int num;
    
    for(int count = 0; count < atoi(argv[1]); count++) {
        if(read(fd1, b1, 1) != 1) exit(1);
        if(read(fd2, b2, 1) != 1) exit(1);
        if(read(fd3, b3, 1) != 1) exit(1);

        if (num <= 0) {
            exit(1);
        }

        for (int i = 0; i < num; i ++){
		    b[i] = (b1[i] & b2[i]) | (b2[i] & b3[i]) | (b3[i] & b1[i]);
        }
		write(fd4, b, num);
        write(fd5, b, num);
        write(fd6, b, num);
	}
}