#!/bin/env python3

import string
import secrets
# On standard Linux systems, use a convenient dictionary file.
# Other platforms may need to provide their own word-list.
with open('/usr/share/dict/words') as f:
    words = [word.strip() for word in f]
    password = '_'.join(secrets.choice(words) for i in range(1))
    password += ''.join(secrets.choice(string.digits) for i in range(3))
f.close()

print(password)
