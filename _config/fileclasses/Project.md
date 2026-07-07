---
extends: Base
fields:
  - name: status
    id: 00841390-2480-4237-9f0f-819ddd608e0c
    type: Select
    options:
      sourceType: ValuesList
      valuesList: { active: active, on-hold: on-hold, someday: someday, done: done }
---

fileClass for pages in `wiki/1-Projects/`.
