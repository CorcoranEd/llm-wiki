---
extends: Base
fields:
  - name: status
    id: 0d81116e-36f6-4c5d-becf-c759721b8812
    type: Select
    options:
      sourceType: ValuesList
      valuesList: { active: active, inactive: inactive }
---

fileClass for pages in `wiki/2-Areas/` (excluding `People/`, which uses the Person fileClass).
