# Index

Catalog of every page in this wiki. Updated on every ingest. Read this first when answering a query.

## Status Board

### ⚡ Up Next

```dataviewjs
function taskPriority(text) {
  if (text.includes('🔺')) return 0;
  if (text.includes('⏫')) return 1;
  if (text.includes('🔼')) return 2;
  if (text.includes('🔽')) return 4;
  return 3;
}

function getTasksForProjectPriority(priority) {
  const pages = dv.pages('"wiki/1-Projects"')
    .where(p => p.priority === priority);
  const folders = [...new Set(pages.map(p => p.file.folder).array())];
  let tasks = [];
  for (const folder of folders) {
    for (const page of dv.pages(`"${folder}"`)) {
      page.file.tasks
        .where(t => !t.completed)
        .forEach(t => tasks.push(t));
    }
  }
  return tasks;
}

// Cascade: high → medium → low
let tasks = [];
let activeLevel = null;
for (const level of ['high', 'medium', 'low']) {
  tasks = getTasksForProjectPriority(level);
  if (tasks.length > 0) { activeLevel = level; break; }
}

tasks.sort((a, b) => taskPriority(a.text) - taskPriority(b.text));
const top5 = tasks.slice(0, 5);

if (top5.length === 0) {
  dv.paragraph("*No tasks found in any active projects.*");
} else {
  if (activeLevel !== 'high') dv.paragraph(`*No tasks in \`high\` projects — showing \`${activeLevel}\`.*`);
  dv.taskList(top5, true);
}
```

### Active Projects

```dataview
TABLE WITHOUT ID file.link AS Project, priority AS Priority, updated AS "Last Updated"
FROM "wiki/1-Projects"
WHERE status = "active" AND endswith(file.folder, file.name)
SORT choice(priority = "high", 1, choice(priority = "medium", 2, 3)) ASC, updated DESC
```

### Backlog

```dataview
TABLE WITHOUT ID file.link AS Project, status AS Status
FROM "wiki/1-Projects"
WHERE status = "someday"
SORT status ASC
```

### Needs Confidence Review

```dataview
TABLE WITHOUT ID file.link AS Page, created AS Created
FROM "wiki"
WHERE confidence = "unreviewed" AND created < date(today) - dur(30 days)
SORT created ASC
```

---

## 1-Projects

## 2-Areas

## 3-Resources

## 4-Archives
