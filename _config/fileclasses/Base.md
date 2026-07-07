---
fields:
  - name: tags
    id: 0a26ffd7-4e81-449c-b5db-ab7a31d25d85
    type: Multi
    options:
      sourceType: ValuesFromDVQuery
      valuesFromDVQuery: "dv.pages().file.tags.values"
  - name: created
    id: 1df95c5e-06bd-4b28-a249-5c814576e189
    type: Date
    options: { dateFormat: YYYY-MM-DD }
  - name: updated
    id: 4760084c-74af-4b31-afb7-a9eefc628170
    type: Date
    options: { dateFormat: YYYY-MM-DD }
  - name: confidence
    id: 65f31b2d-8cb2-45ca-9920-4dab38846069
    type: Select
    options:
      sourceType: ValuesList
      valuesList: { high: high, medium: medium, low: low, unreviewed: unreviewed }
  - name: reviewed
    id: 8105d2bc-e8a9-46af-92c0-246d5ba35d53
    type: Date
    options: { dateFormat: YYYY-MM-DD }
  - name: superseded_by
    id: 2d336790-365f-4f68-93eb-39986a34a92b
    type: Input
  - name: supersedes
    id: 79e61058-cee8-4fbd-a71b-aff227bfed2c
    type: Multi
    options:
      sourceType: ValuesList
      valuesList: {}
  - name: sources
    id: dcb2cc84-332f-400f-8f08-966af4682500
    type: Multi
    options:
      sourceType: ValuesList
      valuesList: {}
  - name: priority
    id: 4909592f-eacb-4eed-b505-35e4217a1b8a
    type: Select
    options:
      sourceType: ValuesList
      valuesList: { high: high, medium: medium, low: low }
---

fileClass note — not assigned to content pages directly. Shared fields inherited by Project, Area, Resource, and Person.
