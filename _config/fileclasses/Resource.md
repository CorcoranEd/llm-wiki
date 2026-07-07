---
extends: Base
fields:
  - name: status
    id: 70e99d10-83ad-430c-a0cc-ca6ef6dd961b
    type: Select
    options:
      sourceType: ValuesList
      valuesList: { active: active, retired: retired }
---

fileClass for pages in `wiki/3-Resources/`.
