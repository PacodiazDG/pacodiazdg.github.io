#!/bin/bash

archivo="${1#content/posts/}"
grep -oP '\(/assets/blog/\K[^)]+(?=\))' "content/posts/$archivo"
