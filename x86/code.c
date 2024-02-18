#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void ellipsecut(void *img, int width, int height, unsigned int color);

int main(int argc, char *argv[])
{
    printf("Name of bmp file: %s\n", argv[1]);
    char *end;
    unsigned int color = strtoul(argv[2], &end, 16);
    printf("Specified color: %x\n", color);
    char *img = argv[1];
    strcat(img, ".bmp");
    FILE *file = fopen(img, "rb");
    if (file == NULL){
        perror("Error opening file");
        return 1;
    }

    char *file_header = (char *)malloc(54);
    fread(file_header, 1, 54, file);
    int offset = *(int *)(file_header + 10);
    int width = *(int *)(file_header + 18);
    int height = *(int *)(file_header + 22);
    int bpp = *(int *)(file_header + 28);
    int row_padded = (width * 3 + 3) & (~3);
    unsigned char* pixelData = malloc(height * row_padded);

    fseek(file, offset, SEEK_SET);
    fread(pixelData, sizeof(unsigned char), height * row_padded, file);
    printf("Width: %d, Height: %d, Size: %d, offset: %d, bpp: %d\n",
            width, height, height * row_padded, offset, bpp);
    fclose(file);
    printf("Line before ellipsecut\n");

    ellipsecut(pixelData, width, height, color);

    printf("Line after ellipsecut\n");
    file = fopen("output.bmp", "wb");
    if (file == NULL){
        perror("Error opening file");
        return 1;
    }
    fwrite(file_header, 1, 54, file);
    fwrite(pixelData, 1, height * row_padded, file);

    return 0;
}
