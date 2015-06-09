#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define JSMN_STRICT
#include "jsmn/jsmn.h"

int down(int tok_len, int i) {
  int r = i+1;
  assert(r < tok_len);
  return r;
}

int next(jsmntok_t *tokens, int tok_len, int i) {
  int cnt;

  for(cnt=1; cnt>0; cnt--, i++) {
    assert(i < tok_len);
    cnt += tokens[i].size;
  }
  return i;
}

#define LINE_LEN (1024*1024)

int main() {
  jsmn_parser p;
  int tok_size = 16;
  jsmntok_t *tokens;
  jsmnerr_t token_cnt;
  char *line;
  int i;

  line = malloc(LINE_LEN);
  tokens = malloc(tok_size * sizeof(jsmntok_t));

  while(NULL != fgets(line, LINE_LEN, stdin)) {
    int len = strlen(line);
    puts(line);
    if (len<=2) {
      continue;
    }
    while (1) {
      jsmn_init(&p);
      token_cnt = jsmn_parse(&p, line, strlen(line), tokens, tok_size);
      if (token_cnt > 0) {
        break;
      }
      printf("token_cnt: %d\n", token_cnt);
      assert(token_cnt == JSMN_ERROR_NOMEM);
      tok_size *= 2;
      free(tokens);
      tokens = malloc(tok_size * sizeof(jsmntok_t));
      printf("malloc tokens: %d\n", tok_size);
    }
    for(i = 1; i < token_cnt; i = next(tokens, token_cnt, i)) {
      printf("i: %d\n", i);
      printf("type: %d\n", tokens[i].type);
      printf("size: %d\n", tokens[i].size);
      printf("text: %.*s\n", tokens[i].end - tokens[i].start, line + tokens[i].start);
    }
  }

  return 0;
}
