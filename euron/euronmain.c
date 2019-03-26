#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <pthread.h>
#include <stdint.h>

#define NUM 2

// char const* command = "01234n+P56789E-+D+*G*1n-+S2ED+E1-+75+-BC";
char const* command = "01234n+P56789E-+D+*G*1n-+S2ED+E1-+75+-BC";

extern uint64_t euron(uint64_t n, char const *prog);


void* thread_function(void* number) {
  int id = *((int*) number);
  free(number);

  uint64_t result = euron(id, command);

  printf("I'm thread no. %d, the result is %ld\n", id, result);
}

int main() {

  pthread_t th[NUM];
  pthread_attr_t attr;
  int err, i;
  int* euron_num;

  if ((err = pthread_attr_init(&attr)) != 0) {
    printf("Attribute init error\n");
    return 1;
  }
  
  if ((err = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE)) != 0) {
    printf("Set joinable error\n");
    return 1;
  }

  for (i = 0; i < NUM; i++) {
    euron_num = malloc(sizeof(int));
    *euron_num = i;
    if ((err = pthread_create(&th[i], &attr, thread_function, euron_num)) != 0) {
      printf("Create thread error\n");
      return 1;
    }
    printf("Created euron no %d\n", i);

  }

  printf ("Main thread is waiting for workers\n");
  for (i = 0; i < NUM; i++) {
    if (err = pthread_join(th[i], NULL) != 0) {
      printf("Join error\n");
      return 1;
    }
    printf("%d thread(s) joined\n", i+1);
  }

  return 0;
}