#include <stdio.h>
#include <stdlib.h>

typedef struct {
  int size;
  int alloc;
  void *data;
} DArray;

DArray* darray_new() {
  DArray *result;

  result = malloc(sizeof(DArray));
  result->size = 0;
  result->alloc = 0;
  result->data = NULL;
  return result;
}

void darray_set_size(DArray *a, int new_size) {
  if (new_size > a->alloc) {
    a->alloc = new_size*2;
    a->data = realloc(a->data, a->alloc);
  }
  a->size = new_size;
}

int main() {
  return 0;
}
